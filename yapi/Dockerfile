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
