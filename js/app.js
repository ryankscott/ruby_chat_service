var myAttendeeId;
var myChatService;




 function ChatWebSocket(port_number)
 {
 		this.wsURI = "ws://localhost:" + port_number;
		console.log("Trying to create WS at " + this.wsURI);
	 	this.ws = new WebSocket(this.wsURI);

	 	  this.ws.onmessage = function(evt) {
		 		console.log("message received");
		 		console.log(evt.data);
		 		var message = $.parseJSON(evt.data);
		 		console.log(message);
		 		$("#chatMessages").append('<li>' + message.timeSent + "- \t" + message.sender + ": \t"  + message.messageText +  '</li>');
		 		return;
		 	};


		 	this.ws.onclose = function () {
		 		console.log("socket closed");
		 		return;
		 	};

		 	this.ws.onopen = function() {
		 		console.log("socket open");
		 		return;
		 	};
	
 	
 }

function ChatService(attendee_id)
{
	this.attendee_id = attendee_id;
	this.chatSocket;

	var url = "http://localhost:4567/register?attendee_id=" + this.attendee_id;
		// Register with the service
	 	 $.ajax({
	       type: 'GET',
	        url: url,
	        async: false,
	        contentType: "application/json",
	        dataType: 'jsonp',
	    	success: function(json) {
	    		console.log("success method called")
				result = $.parseJSON(json);
		       // Create the new chat service
	 			this.chatSocket = new ChatWebSocket(result.chat_id);
	 			//console.log(this.chatSocket);
		     	return;
	    	},
	    	error: function(e) {
	       		console.log(e.message);
	       		return;
	    	}
		})
		return;

	this.sendMessage = function (msg, recipient) {
		console.log(this.chatSocket);
		console.log("Sending message: " + msg);
 		var time = new Date();
		var messageText = {}
		messageText["timeSent"] = time.toISOString();
		messageText["sender"] = this.attendee_id;
		messageText["recipient"] = recipient;
		messageText["messageText"] = msg;
		var messageTextJson = JSON.stringify(messageText);
		console.log(messageTextJson);
 		this.chatSocket.send(messageTextJson);
 		return;

	}

	return;
};


 $(document).ready(function(){

 	this.chatService = new ChatService(Math.floor((Math.random() * 100) + 1));
 	console.log(this.chatService);
 	
 	 // TODO: Need to think about multiple chats also?
 
 	$("#sendMessageBtn").click(function() {
 		console.log(this.chatService);
 		console.log($("#chatText").val());
 		this.chatService.sendMessage($("#chatText").val());
 		$("#chatText").val('');
 	
 		return;
	});


	$('#messageText').keypress(function(event) {
        if (event.keyCode == '13') { 
 			console.log($("#chatText").val());
 			this.chatService.sendMessage($("#chatText").val());
 			$("#chatText").val('');
        }
      });
 	
    });
