FROM node:11-alpine as builder
WORKDIR /yapi
RUN wget https://github.com/YMFE/yapi/archive/refs/tags/v1.9.2.tar.gz
RUN tar -zxvf v1.9.2.tar.gz
RUN mv yapi-1.9.2 vendors
WORKDIR /yapi/vendors
RUN apk add python make
RUN npm install --production
RUN wget https://raw.githubusercontent.com/xie-shujian/k3s/main/yapi/entrypoint.sh

FROM node:11-alpine
LABEL maintainer="xiesj@live.com"
ENV TZ="Asia/Shanghai"
WORKDIR /yapi/vendors
COPY --from=builder /yapi/vendors /yapi/vendors
RUN cp config_example.json /yapi/config.json
EXPOSE 3000
ENTRYPOINT ["sh", "entrypoint.sh"]
