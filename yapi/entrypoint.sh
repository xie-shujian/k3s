#!/bin/sh
#update config file with env var
conf_file=/yapi/config.json
if [ $YAPI_SERVER_PORT ]; then
    sed -i 2c\"port\":\"$YAPI_SERVER_PORT\", $conf_file
fi
if [ $YAPI_ADMINACCOUNT ]; then
    sed -i 3c\"adminAccount\":\"$YAPI_ADMINACCOUNT\", $conf_file
fi
if [ $YAPI_TIMEOUT ]; then
    sed -i 4c\"timeout\":\"$YAPI_TIMEOUT\", $conf_file
fi
if [ $YAPI_DB_SERVERNAME ]; then
    sed -i 6c\"servername\":\"$YAPI_DB_SERVERNAME\", $conf_file
fi
if [ $YAPI_DB_DATABASE ]; then
    sed -i 7c\"DATABASE\":\"$YAPI_DB_DATABASE\", $conf_file
fi
if [ $YAPI_DB_PORT ]; then
    sed -i 8c\"port\":\"$YAPI_DB_PORT\", $conf_file
fi
if [ $YAPI_DB_USER ]; then
    sed -i 9c\"user\":\"$YAPI_DB_USER\", $conf_file
fi
if [ $YAPI_DB_PASS ]; then
    sed -i 10c\"pass\":\"$YAPI_DB_PASS\", $conf_file
fi
if [ $YAPI_DB_AUTHSOURCE ]; then
    sed -i 11c\"authSource\":\"$YAPI_DB_AUTHSOURCE\" $conf_file
fi
if [ $YAPI_MAIL_ENABLE ]; then
    sed -i 14c\"enable\":$YAPI_MAIL_ENABLE, $conf_file
fi
if [ $YAPI_MAIL_HOST ]; then
    sed -i 15c\"host\":\"$YAPI_MAIL_HOST\", $conf_file
fi
if [ $YAPI_MAIL_PORT ]; then
    sed -i 16c\"port\":$YAPI_MAIL_PORT, $conf_file
fi
if [ $YAPI_MAIL_FROM ]; then
    sed -i 17c\"from\":\"$YAPI_MAIL_FROM\", $conf_file
fi
if [ $YAPI_MAIL_USER ]; then
    sed -i 19c\"user\":\"$YAPI_MAIL_USER\", $conf_file
fi
if [ $YAPI_MAIL_PASS ]; then
    sed -i 20c\"pass\":\"$YAPI_MAIL_PASS\" $conf_file
fi
#start yapi
node server/app.js
