## 介绍
yapi是api 文档管理系统，基于nodejs和mongodb。官方没有提供标准的docker镜像都是自己搞的。我也来搞一个
## 制作yapi docker镜像
yapi容器使用非root权限，使用默认node账号，使用node:11-alpine作为基础镜像，使用多阶段构建
## 编写entrypoint,sh
因为config.json这个配置，通过环境变量来配置比较方便，所以我们写一个entrypoint.sh文件，主要使用sed方法，用环境变量来替换json字段。具体如下，另外再加一个启动yapi的语句。
```shell
#!/bin/sh
#update config file with env var
if [ $YAPI_SERVER_PORT ]; then
    sed -i 2c\"port\":\"$YAPI_SERVER_PORT\", ../config.json
fi
if [ $YAPI_ADMINACCOUNT ]; then
    sed -i 3c\"adminAccount\":\"$YAPI_ADMINACCOUNT\", ../config.json
fi
if [ $YAPI_TIMEOUT ]; then
    sed -i 4c\"timeout\":\"$YAPI_TIMEOUT\", ../config.json
fi
if [ $YAPI_DB_SERVERNAME ]; then
    sed -i 6c\"servername\":\"$YAPI_DB_SERVERNAME\", ../config.json
fi
if [ $YAPI_DB_DATABASE ]; then
    sed -i 7c\"DATABASE\":\"$YAPI_DB_DATABASE\", ../config.json
fi
if [ $YAPI_DB_PORT ]; then
    sed -i 8c\"port\":\"$YAPI_DB_PORT\", ../config.json
fi
if [ $YAPI_DB_USER ]; then
    sed -i 9c\"user\":\"$YAPI_DB_USER\", ../config.json
fi
if [ $YAPI_DB_PASS ]; then
    sed -i 10c\"pass\":\"$YAPI_DB_PASS\", ../config.json
fi
if [ $YAPI_DB_AUTHSOURCE ]; then
    sed -i 11c\"authSource\":\"$YAPI_DB_AUTHSOURCE\" ../config.json
fi
if [ $YAPI_MAIL_ENABLE ]; then
    sed -i 13c\"mail\":\"$YAPI_MAIL_ENABLE\", ../config.json
fi
if [ $YAPI_MAIL_HOST ]; then
    sed -i 14c\"enable\":\"$YAPI_MAIL_HOST\", ../config.json
fi
if [ $YAPI_MAIL_PORT ]; then
    sed -i 15c\"host\":\"$YAPI_MAIL_PORT\", ../config.json
fi
if [ $YAPI_MAIL_FROM ]; then
    sed -i 16c\"port\":\"$YAPI_MAIL_FROM\", ../config.json
fi
if [ $YAPI_MAIL_AUTH ]; then
    sed -i 17c\"from\":\"$YAPI_MAIL_AUTH\", ../config.json
fi
if [ $YAPI_MAIL_USER ]; then
    sed -i 18c\"auth\":\"$YAPI_MAIL_USER\", ../config.json
fi
if [ $YAPI_MAIL_PASS ]; then
    sed -i 19c\"user\":\"$YAPI_MAIL_PASS\" ../config.json
fi
#start yapi
node server/app.js
```
## 编写yapi的dockerfile
基础镜像是node:11-alpine,因为这个镜像没有nodejs编译需要的python make，所以需要加进来。
把entrypoint.sh从本人github下载下来，加入到镜像中，修改node可以运行的权限
```dockerfile
FROM node:11-alpine as builder
WORKDIR /home/node
RUN wget https://github.com/YMFE/yapi/archive/refs/tags/v1.9.2.tar.gz
RUN tar -zxvf v1.9.2.tar.gz
RUN mv yapi-1.9.2 vendors
WORKDIR /home/node/vendors
RUN apk add python make
RUN npm install --production
RUN wget https://raw.githubusercontent.com/xie-shujian/k3s/main/yapi/entrypoint.sh
RUN chmod a+x entrypoint.sh

FROM node:11-alpine
LABEL maintainer="xiesj@live.com"
USER node
ENV TZ="Asia/Shanghai"
WORKDIR /home/node/vendors
COPY --from=builder /home/node/vendors /home/node/vendors
RUN cp config_example.json ../config.json
EXPOSE 3000
ENTRYPOINT ["sh", "entrypoint.sh"]
```

这里使用了多重镜像，使用 copy --from 命令，第一个镜像作为builder镜像，把第一个镜像的builder结果，复制到第二个镜像里
## 制作成镜像
docker build -t xieshujian/yapi:1.9.2 .
##镜像大小大概是164m，还是很小的
为了安全我们使用非root账号，为了安全我们不新建账号，直接使用node账号
## k8s部署yaml文件
* 创建secret
* 创建部署
编写环境变量，包含mongodb的连接信息
编写探针
* 创建service
service端口是80，容器端口是3000
```yaml
---

apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: yapi-secret
stringData:
  YAPI_DB_PASS: yapipassword

---

apiVersion: apps/v1
kind: Deployment
metadata:
  name: yapi
  labels:
    app: yapi
spec:
  replicas: 1
  selector:
    matchLabels:
      app: yapi
  template:
    metadata:
      labels:
        app: yapi
    spec:
      containers:
      - name: yapi
        image: xieshujian/yapi:1.9.2
        env:
        - name: YAPI_DB_SERVERNAME
          value: mongodb
        - name: YAPI_DB_DATABASE
          value: yapidb
        - name: YAPI_DB_USER
          value: yapiuser
        - name: YAPI_DB_PASS
          valueFrom:
            secretKeyRef:
              name: yapi-secret
              key: YAPI_DB_PASS
        - name: YAPI_DB_AUTHSOURCE
          value: yapidb
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 3000
        livenessProbe:
          httpGet:
            path: /
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 5

---
apiVersion: v1
kind: Service
metadata:
  name: yapi
spec:
  selector:
    app: yapi
  ports:
    - protocol: TCP
      port: 80
      targetPort: 3000

```
## config.json
```json
{
  "port": "3000",
  "adminAccount": "admin@admin.com",
  "timeout":120000,
  "db": {
    "servername": "mongodb",
    "DATABASE": "yapidb",
    "port": 27017,
    "user": "yapiuser",
    "pass": "yapipassword",
    "authSource": "yapidb"
  },
  "mail": {
    "enable": false,
    "host": "smtp.163.com",
    "port": 465,
    "from": "***@163.com",
    "auth": {
      "user": "***@163.com",
      "pass": "*****"
    }
  }
}
```
我们会用mongodb，servername就是service name就叫mongodb
## 探针，这里使用http探针，5秒跑一次
## 建立service叫yapi
## 创建命名空间
kubectl create ns yapi
## 安装mongodb
把mongodb chart下载解压，找到values.yaml,打开，修改里面的rootPassword的值改为taihu123
另外把useStatefulSet设置成true，我们使用statefull
执行下面命令安装mongodb
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install mongodb bitnami/mongodb -n yapi -f values.yaml
安装完毕之后进入容器，执行下面命令，新建普通账号，和数据库
```mongodb
mongo -u root -p taihu123
use yapidb
db.createUser({user: "yapiuser",pwd: "yapipassword",roles: [ { role: "dbOwner", db: "yapidb" } ]} )
```
## 安装yapi
kubectl apply -f yapi.yaml -n yapi
安装完毕之后，进入其中一个pod
执行下面命令
npm run install-server
初始化数据库
接下来就可以登录yapi了，账号是admin@admin.com,密码是ymfe.org
## k3s界面
![image.png](https://upload-images.jianshu.io/upload_images/22408736-6cb86dea6a87c237.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![image.png](https://upload-images.jianshu.io/upload_images/22408736-fe27b124022fc42d.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![image.png](https://upload-images.jianshu.io/upload_images/22408736-18ef838b40e2b71d.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
![image.png](https://upload-images.jianshu.io/upload_images/22408736-7886ea93e3f96f6f.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
![image.png](https://upload-images.jianshu.io/upload_images/22408736-8b2c4afcfe267754.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
## yapi界面
![image.png](https://upload-images.jianshu.io/upload_images/22408736-d0d3da7018b042ca.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
