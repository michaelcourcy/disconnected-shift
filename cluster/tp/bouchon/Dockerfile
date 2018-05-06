FROM ubuntu:16.04

EXPOSE 8080

RUN apt-get update
RUN apt-get install -y netcat && rm -rf /var/lib/apt/lists/*
COPY start.sh start.sh

CMD ["./start.sh"]
