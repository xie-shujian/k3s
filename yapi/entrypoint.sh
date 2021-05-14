#!/bin/sh
sed -i 2c\"port\": \"$YAPI_PORT\", config.json
sed -i 3c\"adminAccount\": \"$YAPI_ADMINACCOUNT\", config.json
sed -i 4c\"timeout\": \"$YAPI_TIMEOUT\", config.json
sed -i 6c\"servername\": \"$YAPI_DB_SERVERNAME\", config.json
sed -i 7c\"DATABASE\": \"$YAPI_DB_DATABASE\", config.json
sed -i 8c\"port\": \"$YAPI_DB_PORT\", config.json
sed -i 9c\"user\": \"$YAPI_DB_USER\", config.json
sed -i 10c\"pass\": \"$YAPI_DB_PASS\", config.json
sed -i 11c\"authSource\": \"$YAPI_DB_AUTHSOURCE\" config.json
sed -i 13c\"mail\": \"$YAPI_MAIL_ENABLE\", config.json
sed -i 14c\"enable\": \"$YAPI_MAIL_HOST\", config.json
sed -i 15c\"host\": \"$YAPI_MAIL_PORT\", config.json
sed -i 16c\"port\": \"$YAPI_MAIL_FROM\", config.json
sed -i 17c\"from\": \"$YAPI_MAIL_AUTH\", config.json
sed -i 18c\"auth\": \"$YAPI_MAIL_USER\", config.json
sed -i 19c\"user\": \"$YAPI_MAIL_PASS\" config.json
node server/app.js