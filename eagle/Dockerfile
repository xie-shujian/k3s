FROM openjdk:8-jdk-alpine
COPY eagle /eagle
ENV  KE_HOME=/eagle
ENV PATH=$PATH:$KE_HOME/bin
EXPOSE 8048
CMD ["sh","/eagle/bin/entrypoint.sh"]

