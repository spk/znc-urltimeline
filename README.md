# ZNC urltimeline

## What?

A ZNC module that sends URLs from IRC channels to your Browser through a
[WebSocket](https://github.com/openresty/lua-resty-websocket).

## Installation

~~~ console
aptitude install ansible make
make install
~~~

### ZNC

Add in your `znc.conf`:

~~~
LoadModule = modpython
LoadModule = urltimeline
~~~

### htpasswd

You need to generate a password for the ZNC user, the list used is based on the
ZNC user name (urltimeline-ZNC_USER)

~~~ console
ZNC_USER="spk"
PASSWORD="PASSWORD"
SALT="$(openssl rand -base64 3)"
SHA1=$(printf "$PASSWORD$SALT" | openssl dgst -binary -sha1 | sed 's#$#'"$SALT"'#' | base64)
printf "${ZNC_USER}:{SSHA}$SHA1\n" >> nginx/htpasswd
~~~

Goto <http://urltimeline.local/>

## Tests

~~~ console
redis-cli rpush urltimeline-$ZNC_USER '{"timestamp":"2014-08-24T19:59:48.513890", "channel":"#test","nick":"USER","url":"https://github.com/openresty/lua-nginx-module#ngxthreadspawn"}'
~~~

## Resources

* <https://github.com/KSDaemon/wiola/blob/dev/src/wiola/handler.lua>
* <http://wiki.znc.in/Modpython>

## License

DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE

Copyright (c) 2014 Laurent Arnoud <laurent@spkdev.net>
