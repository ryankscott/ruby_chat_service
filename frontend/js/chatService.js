'use strict';
function ChatService(port_number, attendee_id, messageCallback) {
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

	function getHistory(recipient_id, cb)
	{
	// Get all messages
      $.ajax({
        type: 'GET',
        url: "http://localhost:4567/history?attendee_id="+attendeeId+"&recipient_id="+recipient_id,
        contentType: "application/json",
        dataType: 'jsonp',
        success: function(messageHistory) {
        	return cb(messageHistory)
        },
        error: function(e) {
            console.log(e.message);
        },
    });

	}

	service.sendRequest = sendRequest;
	return service;
}