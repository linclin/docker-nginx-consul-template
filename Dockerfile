#sudo docker build --no-cache -t  192.168.19.252/library/nginx-consul-template .
FROM nginx:1.13.2-alpine

MAINTAINER Linc "13579443@qq.com" 
ENV LC_ALL en_US.UTF-8，ENV TZ=Asia/Shanghai
RUN apk add  --no-cache  --update --virtual tobedeleted  unzip; \
    apk add --no-cache  --update  curl bash tree tzdata   ; \
    echo "Asia/Shanghai" > /etc/timezone ; \
    cp -r -f /usr/share/zoneinfo/Asia/Shanghai /etc/localtime ; \
    apk del --purge tobedeleted ; \
    rm -rf  /tmp/*   /var/tmp/*  
    

COPY . /app/

RUN unzip /app/consul-template_0.18.3_linux_amd64.zip -d /usr/local/bin ; \
    rm /app/consul-template_0.18.3_linux_amd64.zip

EXPOSE 80 443

CMD ["/app/run.sh"]
