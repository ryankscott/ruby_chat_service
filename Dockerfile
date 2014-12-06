FROM ubuntu:14.10

RUN apt-get update

# Install pre-requisite applications 
RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get upgrade -y && \
  DEBIAN_FRONTEND=noninteractive apt-get -y install \
    build-essential \
    curl \
    git \
	vim \
	rabbitmq-server \
	ruby \
	ruby-dev

RUN apt-get install -y sqlite3 libsqlite3-dev



# Install required gems
RUN gem install sinatra-jsonp
RUN gem install bunny
RUN gem install sqlite3
RUN gem install em-websocket
RUN gem install data_mapper
RUN gem install dm-sqlite-adapter
RUN gem install thin --no-ri --no-rdoc

# Clone the repo
RUN git clone https://github.com/ryankscott/ruby_chat_service.git /home/

# Expose the right ports
EXPOSE 4567
EXPOSE 3001
EXPOSE 3002
EXPOSE 3003
EXPOSE 3004
EXPOSE 3005
EXPOSE 80
EXPOSE 8080
EXPOSE 22


# Start rabbitmq
CMD ["rabbitmq-server -detached"]

# Run the end-point
CMD ["ruby /home/ruby_chat_service/ChatServiceEndpoint.rb"]
		