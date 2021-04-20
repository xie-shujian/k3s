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

