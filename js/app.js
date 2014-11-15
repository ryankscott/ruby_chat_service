
function createChatWebsocket(port_number) {
    var wsURI = "ws://localhost:" + port_number;
    console.log("Trying to create WS at " + wsURI);
    var ws = new WebSocket(wsURI);

    ws.onmessage = function(evt) {
        console.log("Message received: " + evt.data);
        var message = $.parseJSON(evt.data);
        console.log(message);
        /* Here we should do some validation of the message
			- Do we have the right fields?
			- Is the message for me?
			- Is the timestamp plausible? etc
        */

        $("#chatMessages").append('<li>' + message.sent_at + "- \t" + message.sender + ": \t" + message.message + '</li>');
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
}

function sendMessage(msg, recipient, attendee_id, chatSocket) {
    console.log("Sending message: " + msg);
    var time = new Date();
    var messageText = {
    	sent_at: time.toISOString(),
    	sender: attendee_id,
    	recipient: recipient,
    	message: msg
    };
    var messageTextJson = JSON.stringify(messageText);
    console.log(messageTextJson);
    chatSocket.send(messageTextJson);
}


function getUsers()
{
     // Get all users
      $.ajax({
        type: 'GET',
        url: "http://localhost:4567/status",
        contentType: "application/json",
        dataType: 'jsonp',
        success: function(userArray) {
            $("#userList").html("");
            $("#userSelect").html("");
            for (var user in userArray) {
                result = userArray[user];
                if (result.status == "online") {
                    $("#userList").append('<li>' + result.attendee_id + "- \t" + result.status + '</li>');
                    $("#userSelect").append('<option>' + result.attendee_id + '</option>');
                }
            }
        },
        error: function(e) {
            console.log(e.message);
        },
    });   


}





$(document).ready(function() {

	var attendee_id = Math.floor((Math.random() * 100) + 1);
    console.log("Attendee id: " + attendee_id);
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
        },
    });   

    // Get online users then poll ever 5s
    getUsers();
    window.setInterval(function(){getUsers()}, 5000);




    $("#sendMessageBtn").click(function() {
        console.log($("#chatText").val());
        sendMessage($("#chatText").val(), $("#userSelect").val(), attendee_id, chatWs);
        $("#chatText").val('');
    });


    $('#messageText').keypress(function(event) {
        if (event.keyCode == '13') {
            console.log($("#chatText").val());
            sendMessage($("#chatText").val(), $("#userSelect").val(), attendee_id, chatWs);
            $("#chatText").val('');
        }
    });
});




