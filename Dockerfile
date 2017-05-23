#docker build -t  192.168.151.252/library/nginx-consul-template .
FROM nginx:1.13.0-alpine

MAINTAINER Linc "13579443@qq.com" 

RUN apk add  --no-cache  --update --virtual tobedeleted   unzip curl bash tree tzdata ; \
    echo "Asia/Shanghai" > /etc/timezone ; \
    cp -r -f /usr/share/zoneinfo/Asia/Shanghai /etc/localtime ; \
    apk del --purge tobedeleted ; \
    rm -rf  /tmp/* /var/cache/*  /var/tmp/*  
    

COPY . /app/

RUN unzip /app/consul-template_0.18.3_linux_amd64.zip -d /usr/local/bin ; \
    rm /app/consul-template_0.18.3_linux_amd64.zip

EXPOSE 80 443

CMD ["/app/run.sh"]
