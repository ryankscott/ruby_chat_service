
function createChatWebsocket(port_number) {
    this.wsURI = "ws://localhost:" + port_number;
    console.log("Trying to create WS at " + this.wsURI);
    var ws = new WebSocket(this.wsURI);

    ws.onmessage = function(evt) {
        console.log("Message received: " + evt.data);
        var message = $.parseJSON(evt.data);
        console.log(message);
        /* Here we should do some validation of the message
			- Do we have the right fields?
			- Is the message for me?
			- Is the timestamp plausible? etc
        */

        $("#chatMessages").append('<li>' + message.timeSent + "- \t" + message.sender + ": \t" + message.messageText + '</li>');
    };

    ws.onerror = function()
    {
    	console.log("Error creating socket");
    };

    ws.onclose = function() {
        console.log("Socket closed");
    };

    ws.onopen = function() {
        console.log("Socket open");
    };

    return ws;
};

function sendMessage(msg, recipient, attendee_id, chatSocket) {
    console.log("Sending message: " + msg);
    var time = new Date();
    var messageText = {
    	timeSent: time.toISOString(),
    	sender: attendee_id,
    	recipient: recipient,
    	messageText: msg
    };
    var messageTextJson = JSON.stringify(messageText);
    console.log(messageTextJson);
    chatSocket.send(messageTextJson);
};

$(document).ready(function() {

	var attendee_id = 123;
    var chatWs = null;
    var url = "http://localhost:4567/register?attendee_id=" + attendee_id;
    // Register with the service
    /*
		This call has to be async because it's JSONP, we may have the possibility that the ajax doesn't return 
		before someone tries to send a message. Need to look into Promises?
    */
    $.ajax({
        type: 'GET',
        url: url,
        contentType: "application/json",
        dataType: 'jsonp',
        success: function(json) {
            result = $.parseJSON(json);
            chatWs = createChatWebsocket(result.chat_id);
		},
        error: function(e) {
            console.log(e.message);
            return null;
        },
    });   


    $("#sendMessageBtn").click(function() {
        console.log($("#chatText").val());
        sendMessage($("#chatText").val(), 456, 123, chatWs);
        $("#chatText").val('');
    });


    $('#messageText').keypress(function(event) {
        if (event.keyCode == '13') {
            console.log($("#chatText").val());
            sendMessage($("#chatText").val(), 456, 123, chatWs);
            $("#chatText").val('');
        }
    });
});




