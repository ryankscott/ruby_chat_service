 function chatService(url, port)
 {

 	this.wsURI = "ws://" + url + ":" + port;
 	console.log("Creating chat service at " + this.wsURI);	
 	this.ws = new WebSocket(this.wsURI);
 	

 	this.ws.onmessage = function(evt) {
 		console.log("message received");
 		console.log(evt.data);
 		$("#chatMessages").append('<li>' + evt.data + '</li>');
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

 	 this.sendMessage = function(msg) {
 		console.log("Sending message: " + msg);
 		this.ws.send(msg);
 		return;
 	};

 }

 $(document).ready(function(){
 	var c = new chatService("localhost", "3000");


 	$("#sendMessageBtn").click(function() {
 		console.log($("#messageText").val());
 		c.sendMessage($("#messageText").val());
 		$("#messageText").val('');
 		return;
	});


	$('#messageText').keypress(function(event) {
        if (event.keyCode == '13') { 
        	c.sendMessage($("#messageText").val());
        	$("#messageText").val('');
        }
      });


 });



