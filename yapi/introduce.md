[YMFE/yapi: YApi 是一个可本地部署的、打通前后端及QA的、可视化的接口管理平台 (github.com)](https://github.com/YMFE/yapi)
[YApi 接口管理平台 (hellosean1025.github.io)](https://hellosean1025.github.io/yapi/)
[顶尖 API 文档管理工具 (YAPI) - 简书 (jianshu.com)](https://www.jianshu.com/p/a97d2efb23c5)
#介绍

##安全方面
yapi容器使用非root权限
mongodb使用非root账号

#首先我们创建一个dockerfile
```dockerfile
FROM node:11-alpine as builder
WORKDIR /home/node
RUN wget https://github.com/YMFE/yapi/archive/refs/tags/v1.9.2.tar.gz
RUN tar -zxvf v1.9.2.tar.gz
RUN mv yapi-1.9.2 vendors
WORKDIR /home/node/vendors
RUN apk add python make
RUN npm install --production --registry https://registry.npm.taobao.org

FROM node:11-alpine
LABEL maintainer="xiesj@live.com"
WORKDIR /home/node/vendors
COPY --from=builder /home/node/vendors /home/node/vendors
USER node
ENV TZ="Asia/Shanghai"
EXPOSE 3000
CMD ["node","server/app.js"]
```
我们使用node11-alpine，需要额外安装python和make
这里使用了多重镜像，使用 copy --from 命令，第一个镜像作为builder镜像，把第一个镜像的builder结果，复制到第二个镜像里
#制作成镜像
docker build -t xieshujian/yapi:1.9.2 .
##镜像大小大概是164m，还是很小的
## 为了安全我们使用非root账号，为了安全我们不新建账号，直接使用node账号
#k8s部署yaml文件
```yaml
---

apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: yapi-secret
data:
  config.json: |
    ewogICJwb3J0IjogIjMwMDAiLAogICJhZG1pbkFjY291bnQiOiAiYWRtaW5AYWRtaW4uY29tIiwK
    ICAidGltZW91dCI6MTIwMDAwLAogICJkYiI6IHsKICAgICJzZXJ2ZXJuYW1lIjogIm1vbmdvZGIi
    LAogICAgIkRBVEFCQVNFIjogIm1vbmdvZGIiLAogICAgInBvcnQiOiAyNzAxNywKICAgICJ1c2Vy
    IjogInJvb3QiLAogICAgInBhc3MiOiAidGFpaHUxMjMiLAogICAgImF1dGhTb3VyY2UiOiAiYWRt
    aW4iCiAgfSwKICAibWFpbCI6IHsKICAgICJlbmFibGUiOiBmYWxzZSwKICAgICJob3N0IjogInNt
    dHAuMTYzLmNvbSIsCiAgICAicG9ydCI6IDQ2NSwKICAgICJmcm9tIjogIioqKkAxNjMuY29tIiwK
    ICAgICJhdXRoIjogewogICAgICAidXNlciI6ICIqKipAMTYzLmNvbSIsCiAgICAgICJwYXNzIjog
    IioqKioqIgogICAgfQogIH0KfQo=



---


apiVersion: apps/v1
kind: Deployment
metadata:
  name: yapi
  labels:
    app: yapi
spec:
  replicas: 2
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
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 3000
        livenessProbe:
          httpGet:
            path: /
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 5
        volumeMounts:
        - name: config
          mountPath: "/home/node/config.json"
          subPath: "config.json"
      volumes:
      - name: config
        secret:
          secretName: yapi-secret
          items:
          - key: config.json
            path: config.json



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
## 我们把config.json这个文件制作成k8s secret文件，这里是用了base64,原始文件如下
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
这里采用文件挂载，使用subPath，注意path要写到config.json,因为/yapi是非空目录，不是挂载整个目录，是挂载单个文件，坑1
##探针，这里使用http探针，5秒跑一次
##建立service叫yapi
#创建命名空间
kubectl create ns yapi
##安装mongodb
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
#安装yapi
kubectl apply -f yapi yapi.yaml -n yapi
安装完毕之后，进入其中一个pod
执行下面命令
npm run install-server
初始化数据库
接下来就可以登录yapi了，账号是admin@admin.com,密码是ymfe.org
#k3s界面
![image.png](https://upload-images.jianshu.io/upload_images/22408736-6cb86dea6a87c237.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![image.png](https://upload-images.jianshu.io/upload_images/22408736-fe27b124022fc42d.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![image.png](https://upload-images.jianshu.io/upload_images/22408736-18ef838b40e2b71d.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
![image.png](https://upload-images.jianshu.io/upload_images/22408736-7886ea93e3f96f6f.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
![image.png](https://upload-images.jianshu.io/upload_images/22408736-8b2c4afcfe267754.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
#yapi界面
![image.png](https://upload-images.jianshu.io/upload_images/22408736-d0d3da7018b042ca.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
