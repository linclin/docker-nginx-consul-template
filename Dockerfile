#sudo docker build --no-cache -t  nginx-consul-template .
#sudo docker tag nginx-consul-template 192.168.19.252/library/nginx-consul-template  
#sudo docker push 192.168.19.252/library/nginx-consul-template  
FROM nginx:1.13.2-alpine

MAINTAINER Linc "13579443@qq.com" 
 
ENV LC_ALL en_US.UTF-8，ENV TZ=Asia/Shanghai
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories ; \
    apk update ; \
    apk add --no-cache  --update s6  bash  tzdata   ; \
    echo "Asia/Shanghai" > /etc/timezone ; \
    cp -r -f /usr/share/zoneinfo/Asia/Shanghai /etc/localtime ; \
    rm -rf /var/cache/apk/*  /tmp/*   /var/tmp/*  
COPY files/ /etc/
COPY consul-template /usr/local/bin/
EXPOSE 80 443

ENTRYPOINT ["/bin/s6-svscan", "/etc/services.d"]
