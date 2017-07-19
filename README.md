# Docker consul-template&nginx reverse proxy

 
This solution is intended to be used with [Swarm Mode](https://docs.docker.com/engine/swarm/)   
[Consul-Template](https://github.com/hashicorp/consul-template) is used for listening [Consul](https://github.com/hashicorp/consul) events and generating nginx config   

## Usage
 

When requirements are satisfied, run this:

```bash
sudo docker run -d --privileged  --restart always  --name proxy  -p 80:80  -e CONSUL_ADDR={consul IP}  192.168.19.252/library/nginx-consul-template 
```

An image exposes as 80, as 443(https)

### Environment variables

- `CONSUL_ADDR` - ip address of Consul location
- `CONSUL_PORT` - Consul port. By default 8500
- `IS_HTTPS` - set as "1" if you want to use https. Also required `CERT` variable to be set
- `CERT` - name of certificate. For instance, if `test.com` is set, it will try to use `/etc/nginx/certs/test.com.crt` and `/etc/nginx/certs/test.com.key`. And of course you need to volume them or COPY before run 

### docker stack
```bash
#all manager node
mkdir -p /data/swarm_consul/config && mkdir -p /data/swarm_consul/data && chmod 777 -R /data/swarm_consul/
docker stack deploy -c docker-nginx-consul-template.yml  proxy 
```
 
### Consul services
```bash
curl -X PUT -d '{"id": "test1.m.juanpi.org","name": "test1.m.juanpi.org","address": "test1-m-juanpi-com","port": 80,"tags": ["swarmkit-service","domain"]}' http://192.168.149.61:8500/v1/agent/service/register
 
```
```bash
docker stack deploy -c docker-consul.yml consul
```

docker service create --replicas 2 --network proxy_proxy --name nginx1  nginx


### CMD Create consul&nginx service
```bash
docker network create --driver overlay   consul
 
docker service create -e 'CONSUL_BIND_INTERFACE=eth0' -e 'CONSUL_LOCAL_CONFIG={"leave_on_terminate": true,"skip_leave_on_interrupt": true}' --name consul_server --network consul   --publish  mode=host,target=8500,published=8500    --mode global --constraint 'node.role == manager'   consul agent -server -datacenter=swarm -ui -bootstrap-expect=3  -client=0.0.0.0     -retry-join=consul_server -retry-join=consul_server -retry-join=consul_server  -retry-interval=5s -rejoin -disable-host-node-id  

docker service create -e 'CONSUL_BIND_INTERFACE=eth0' -e 'CONSUL_LOCAL_CONFIG={"leave_on_terminate": true,"skip_leave_on_interrupt": true}' --publish  mode=host,target=8500,published=8500 --mode global --network consul --name consul_agent --constraint 'node.role != manager' consul agent -retry-join=consul_server retry-interval=5s -rejoin -client 0.0.0.0 -disable-host-node-id 
 
docker network create --driver overlay   proxy_nginx

docker service create -e 'CONSUL_ADDR=consul_server' -e 'CONSUL_PORT=8500' -e 'IS_HTTPS=0' -e 'CERT=proxy' --publish  mode=host,target=80,published=80 --mode global --network consul --network proxy --name proxy_nginx   192.168.19.252/library/nginx-consul-template
 
```