FROM openjdk:8-jdk-alpine

MAINTAINER serhii.hokhkalenko@gmail.com

USER root
WORKDIR /home/app

RUN apk update
#install node
RUN apk -y add curl gnupg
RUN apk add bash
#RUN curl -sL https://deb.nodesource.com/setup_11.x  | bash -
RUN apk -y add nodejs

#install Wetty
RUN apk add --no-cache git
RUN apk add openssh
RUN git config --global http.sslVerify false
RUN git clone https://github.com/krishnasrinivas/wetty
#install ssl
RUN openssl req -x509 -newkey rsa:2048 -keyout key.pem -out cert.pem -days 30000 -nodes

RUN npm install
RUN apk update
RUN apk install -y vim
RUN useradd -d /home/term -m -s /bin/bash term
RUN echo 'term:yourpassword' | chpasswd
RUN mkdir /home/term/.ssh
COPY id_rsa /home/term/.ssh/id_rsa
RUN chmod 600 /home/term/.ssh/id_rsa && chown -Rf term /home/term/.ssh
EXPOSE 3000
ENTRYPOINT ["node"]
CMD ["app.js", "--sslkey", "key.pem", "--sslcert", "cert.pem", "-p", "3000"]