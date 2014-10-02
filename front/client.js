$(document).ready(function() {
    // Create SocketIO instance, connect
    var socket = new WebSocket('ws://'+ window.location.hostname + '/s');

    socket.onmessage = function(event) {
        messages = $('#messages')
        data = JSON.parse(event.data);
        timestamp = moment(data['timestamp']).fromNow();
        channel = data['channel'];
        nick = data['nick'];
        url = '<a href="' + data['url'] + '" target="_blank">'+ data['url'] + '</a>';
        messages.append($('<li>').html(
                timestamp + ' | ' +
                channel + ' | ' +
                nick + ' | ' + url));
        document.title = '*(' + messages.children().length + ')' + ' ZNC urltimeline';
    };

    window.onload = function() {
        window.onfocus = function() { document.title = document.title.replace('*', ''); };
    };
});
