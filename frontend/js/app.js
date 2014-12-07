


$(document).ready(function() {

    var attendee_id = Math.floor((Math.random() * 100) + 1);
    console.log("Attendee id: " + attendee_id);
    var chatService = chatService = new ChatService("192.168.59.103", "4567", attendee_id, function(message){
             $("#chatMessages").append('<li>' + message.sent_at + "- \t" + message.sender + ": \t" + message.message + '</li>');
            });

    // Get online users then poll every 5s
    window.setInterval(function(){chatService.getUsers(function (allUsers){
            $("#userList").html("");
            $("#userSelect").html("");
            for (var user in allUsers) {
                result = allUsers[user];
                if (result.status == "online") {
                    $("#userList").append('<li>' + result.attendee_id + "- \t" + result.status + '</li>');
                    $("#userSelect").append('<option>' + result.attendee_id + '</option>');
                }
            }
    })}, 5000);



    $("#sendMessageBtn").click(function() {
        console.log($("#chatText").val());
        chatService.sendMessge($("#chatText").val(), $("#userSelect").val(), attendee_id, function() {console.log("callback")});
        $("#chatText").val('');
    });


    $('#messageText').keypress(function(event) {
        if (event.keyCode == '13') {
            console.log($("#chatText").val());
            chatService.sendMessge($("#chatText").val(), $("#userSelect").val(), attendee_id, function() {console.log("callback")});
            $("#chatText").val('');

        }
    });
});




