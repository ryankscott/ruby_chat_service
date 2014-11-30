'use strict';
function ChatService(attendee_id, messageCallback) {
	var service = {};
	var currentMessageId = 0;
	var ws;
	var preConnectionRequests = [];
	var connected = false;
	var attendeeId = attendee_id
	var messageListener = messageCallback;

	function init() {
		service = {};
		currentMessageId = 0;
		preConnectionRequests = [];
		connected = false;

		// Register the attendee with the chat service
		console.log("Registering with the service for attendee: " + attendeeId)
		 $.ajax({
        type: 'GET',
        url: "http://192.168.59.103:49156/register?attendee_id=" + attendee_id,
        contentType: "application/json",
        dataType: 'jsonp'
	    }).done(function(json){
	    	var result = $.parseJSON(json);
	    	var port_number = result.chat_id;
	    	console.log("Registered with service at: " + port_number)
	    	ws = new WebSocket("ws://" + "localhost:" + port_number)
			ws.onopen = function () {
				connected = true;
				console.log("Connected to WebSocket at: " + window.location.hostname + port_number);
				console.log('Sending (%d) requests', preConnectionRequests.length);
				for (var i = 0, c = preConnectionRequests.length; i < c; i++) {
					ws.send(JSON.stringify(preConnectionRequests[i]));
				}
				preConnectionRequests = [];
			};
			ws.onclose = function() {
				connected = false;
			};
			ws.onmessage = function (message) {
				messageListener(JSON.parse(message.data));
			};
	    }); 
	}
	init();

	function sendRequest(msg, recipient_id) {
		// websocket closing / closed, reconnect
		if(ws && ~[2,3].indexOf(ws.readyState)) {
			connected = false;
			init();
		}
		var time = new Date();
	    var messageText = {
	    	sent_at: time.toISOString(),
	    	sender: attendeeId,
	    	recipient: recipient_id,
	    	message: msg
	    };
		if (!connected) {
			preConnectionRequests.push(messageText);
		} else {
			ws.send(JSON.stringify(messageText));
		}
	}

	function getHistory(recipient_id, cb) {
	// Get all messages
      $.ajax({
        type: 'GET',
        url: "http://localhost:4567/history?attendee_id="+attendeeId+"&recipient_id="+recipient_id,
        contentType: "application/json",
        dataType: 'jsonp'
    }).done(function (messageHistory){
        	return cb(messageHistory)
    }).fail(function (e) {
    	throw e
    });
	}

	function getUsers(cb) {
	 // Get all users
      $.ajax({
        type: 'GET',
        url: "http://localhost:4567/status",
        contentType: "application/json",
        dataType: 'jsonp'
    }).done(function (userArray) {
    	return cb(userArray)
    }).fail(function (e){
    	throw e
    })
    };
        
	service.sendRequest = sendRequest;
	service.getUsers = getUsers;
	service.getHistory = getHistory;
	return service;
}
