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
    var chatService = chatService = new ChatService(attendee_id, function(message){
             $("#chatMessages").append('<li>' + message.sent_at + "- \t" + message.sender + ": \t" + message.message + '</li>');
            });

    // Get online users then poll ever 5s
    getUsers();
    window.setInterval(function(){getUsers()}, 5000);
    


    $("#sendMessageBtn").click(function() {
        console.log($("#chatText").val());
        chatService.sendRequest($("#chatText").val(), $("#userSelect").val(), attendee_id, function() {console.log("callback")});
        $("#chatText").val('');
    });


    $('#messageText').keypress(function(event) {
        if (event.keyCode == '13') {
            console.log($("#chatText").val());
            chatService.sendRequest($("#chatText").val(), $("#userSelect").val(), attendee_id, function() {console.log("callback")});
            $("#chatText").val('');

        }
    });
});




