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
