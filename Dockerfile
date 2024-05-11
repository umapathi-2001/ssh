FROM ubuntu:latest

RUN apt update -y > /dev/null 2>&1 && \
    apt upgrade -y > /dev/null 2>&1 && \
    apt install locales -y && \
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

ENV LANG en_US.utf8
ARG NGROKID
ARG PASSWORD
ENV Password=${PASSWORD}
ENV Ngrokid=${NGROKID}

RUN apt install ssh wget unzip -y > /dev/null 2>&1 && \
    wget -O ngrok.zip https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.zip > /dev/null 2>&1 && \
    unzip ngrok.zip

RUN echo "./ngrok config add-authtoken ${Ngrokid} &&" >>/1.sh && \
    echo "./ngrok tcp 22 &>/dev/null &" >>/1.sh && \
    echo "mkdir -p /run/sshd" >> /1.sh && \
    echo '/usr/sbin/sshd -D' >>/1.sh && \
    echo 'PermitRootLogin yes' >>  /etc/ssh/sshd_config && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config && \
    echo "root:${Password}" | chpasswd

RUN service ssh start

RUN chmod 755 /1.sh

EXPOSE 8080

CMD /1.sh
