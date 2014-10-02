local server = require "nginx.websocket.server"
local redis = require "nginx.redis"

local wb, err = server:new{
    timeout = 5000,  -- in milliseconds
    max_payload_len = 65535,
}
if not wb then
    ngx.log(ngx.ERR, "failed to new websocket: ", err)
    return ngx.exit(444)
end

local rd = redis:new()
local ok, err = rd:connect('127.0.0.1', 6379)
if not ok then
    ngx.log(ngx.ERR, "failed to redis connect: ", err)
    return ngx.exit(444)
end

while true do
    local data, typ, err = wb:recv_frame()

    local url_list = "urltimeline-".. ngx.var.remote_user
    local res, err = rd:lpop(url_list)
    while res ~= ngx.null do
        bytes, err = wb:send_text(res)
        if not bytes then
            ngx.log(ngx.ERR, "failed to send a text frame: ", err)
            return ngx.exit(444)
        end
        res, err = rd:lpop(url_list)
    end

    if wb.fatal then
        ngx.log(ngx.ERR, "failed to receive frame: ", err)
        return ngx.exit(444)
    end
    if not data then
        local bytes, err = wb:send_ping()
        if not bytes then
            ngx.log(ngx.ERR, "failed to send ping: ", err)
            return ngx.exit(444)
        end
    elseif typ == "close" then
        wb:send_close()
        rd:close()
        break
    elseif typ == "ping" then
        local bytes, err = wb:send_pong()
        if not bytes then
            ngx.log(ngx.ERR, "failed to send pong: ", err)
            return ngx.exit(444)
        end
    elseif typ == "pong" then
        ngx.log(ngx.INFO, "client ponged")
    elseif typ == "text" then
        local bytes, err = wb:send_text(data)
        if not bytes then
            ngx.log(ngx.ERR, "failed to send text: ", err)
            return ngx.exit(444)
        end
    end
end

wb:send_close()
rd:close()
