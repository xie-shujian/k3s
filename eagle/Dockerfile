FROM openjdk:8u292-buster as builder
WORKDIR /eagle
RUN wget https://github.com/smartloli/kafka-eagle-bin/archive/v2.0.5.tar.gz
RUN tar zxvf v2.0.5.tar.gz
RUN tar zxvf kafka-eagle-bin-2.0.5/kafka-eagle-web-2.0.5-bin.tar.gz
WORKDIR /eagle/kafka-eagle-web-2.0.5/bin
RUN wget https://raw.githubusercontent.com/xie-shujian/k3s/main/eagle/eagle/bin/entrypoint.sh

FROM openjdk:8u292-buster
LABEL maintainer="shujian@mail.io"
WORKDIR /eagle
COPY --from=builder /eagle/kafka-eagle-web-2.0.5 /eagle
ENV TZ="Asia/Shanghai"
ENV KE_HOME=/eagle
ENV PATH=$PATH:$KE_HOME/bin
RUN chmod +x /eagle/bin/ke.sh
RUN mkdir -p /hadoop/kafka-eagle/db
EXPOSE 8048
CMD ["sh","/eagle/bin/entrypoint.sh"]
