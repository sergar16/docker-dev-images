FROM openjdk:8-jdk-alpine

MAINTAINER serhii.hokhkalenko@gmail.com

USER root
WORKDIR /home/app/wetty

RUN apk --update add bash \
        python \
        make \
        build-base \
        gcc \
        nodejs \
        nodejs-npm \
        yarn \
        openssh \
        openssl \
        curl \
        gnupg \
        git \
        vim

#install Wetty
RUN cd .. && git clone https://github.com/krishnasrinivas/wetty

#install ssl
RUN openssl req -x509 -newkey rsa:2048 -keyout key.pem -out cert.pem -days 30000 -nodes \
    -subj "/C=UK/ST=Warwickshire/L=Leamington/O=OrgName/OU=IT Department/CN=example.com"

RUN yarn && \
    yarn build && \
    yarn install --production --ignore-scripts --prefer-offline
RUN apk add -U openssh-client sshpass
RUN ls -lt
# Bundle app source
RUN adduser -S -h /home/term -s /bin/bash term
RUN echo 'term:yourpassword' | chpasswd
RUN mkdir /home/term/.ssh
COPY id_rsa /home/term/.ssh/id_rsa
RUN chmod 600 /home/term/.ssh/id_rsa && chown -Rf term /home/term/.ssh
#Check versions
RUN node -v
RUN npm -v
RUN java -version

RUN mkdir ~/.ssh
RUN ssh-keyscan -H wetty-ssh >> ~/.ssh/known_hosts
EXPOSE 3000
ENTRYPOINT ["node"]