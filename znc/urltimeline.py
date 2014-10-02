import znc
import re
import json
import os
from datetime import datetime

class urltimeline(znc.Module):
    description = "Put urls on redis urltimeline list"
    module_type = [znc.CModInfo.NetworkModule]

    def OnLoad(self, args, message):
        self.urlList = 'urltimeline-' + self.GetUser().GetNick()
        self.urlRegexp = '(https?://\S+)'
        return True

    def _JsonDateHandler(self, obj):
        return obj.isoformat() if hasattr(obj, 'isoformat') else obj

    def _BuildJsonString(self, channel, nick, url):
        return json.dumps({
            'timestamp': datetime.now(),
            'channel': channel,
            'nick': nick,
            'url': url
            }, separators=(',', ':'), default=self._JsonDateHandler)

    def _SendToRedis(self, nick, channel, message):
        res = re.findall(re.compile(self.urlRegexp), message)
        if res:
            result = ["'" + self._BuildJsonString(channel, nick, url) + "'" for url in res]
            command = "redis-cli rpush " + self.urlList + ' ' + ' '.join(result)
            os.system(command)

    # Called when we receive a private message from IRC.
    def OnPrivMsg(self, nick, message):
        self._SendToRedis(nick.GetNick(), "&PrivMsg", message.s)
        return znc.CONTINUE

    # Called when we receive a channel message from IRC.
    def OnChanMsg(self, nick, channel, message):
        self._SendToRedis(nick.GetNick(), channel.GetName(), message.s)
        return znc.CONTINUE

    # This module hook is called when a user sends a normal IRC message.
    def OnUserMsg(self, target, message):
        self._SendToRedis(self.GetUser().GetNick(), target.s, message.s)
        return znc.CONTINUE
