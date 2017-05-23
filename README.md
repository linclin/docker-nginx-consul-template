# Docker consul-template&nginx reverse proxy

 
This solution is intended to be used with [Swarm Mode](https://docs.docker.com/engine/swarm/)   
[Consul-Template](https://github.com/hashicorp/consul-template) is used for listening [Consul](https://github.com/hashicorp/consul) events and generating nginx config   

## Usage
 

When requirements are satisfied, run this:

```bash
docker run -d \
    --privileged \
    --restart always \
    --name proxy \
    -p 80:80 \
    -e CONSUL_ADDR={consul IP} \
    docker-nginx-consul-template 
```

An image exposes as 80, as 443(https)

### Environment variables

- `CONSUL_ADDR` - ip address of Consul location
- `CONSUL_PORT` - Consul port. By default 8500
- `IS_HTTPS` - set as "1" if you want to use https. Also required `CERT` variable to be set
- `CERT` - name of certificate. For instance, if `test.com` is set, it will try to use `/etc/nginx/certs/test.com.crt` and `/etc/nginx/certs/test.com.key`. And of course you need to volume them or COPY before run 

### Running services

```yaml
version: '3'
services:
  nginx:
    image: 192.168.151.252/library/nginx-consul-template
    ports:
      - 80:80 
    deploy:
      mode: global 
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3
        window: 120s
      update_config:
        parallelism: 1
        delay: 30s 
```
### Consul services
```json
{
"service": {
"name": "example.com",
"tags": ["proxy_nginx"],
"address":"192.168.149.61",
"port": 2375,
"checks":[
{
"http":"http://192.168.149.61:2375/info",
"interval":"5s"
}
]
}
}
 ```
