WebSocket ChatService
=================

#To run using Docker:

1) Pull the docker image
```
    docker pull ruby_chat_service
```
2) Run the image and expose the ports (Expose 300x for the number of chats, 5 exposed)
```
    docker run -i -t -p 3000:3000 -p 3001:3001 -p 4567:4567 -P ruby_chat_service /bin/bash
```
3) Start rabbit-mq
```
    rabbitmq-server -detached
```
4) Pull the latest code
```
    git -C /home/ pull
```
5) Start the end point
```
    ruby /home/ChatServiceEndpoint.rb
```


