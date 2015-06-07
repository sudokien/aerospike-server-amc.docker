# aerospike-server-amc.docker
Docker image with Aerospike server and Aerospike Management Console

To start the container, run:

```
docker run -d --name aerospike -p 3000:3000 -p 3001:3001 -p 3002:3002 -p 3003:3003 -p 8081:8081 solidfoxrock/aerospike
```