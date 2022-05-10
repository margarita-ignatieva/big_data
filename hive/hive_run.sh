#!/bin/bash

/usr/local/hadoop/bin/hdfs dfs -mkdir /tmp
/usr/local/hadoop/bin/hdfs dfs -chmod g+w /tmp
/usr/local/hadoop/bin/hdfs dfs -mkdir -p /user/hive/warehouse
/usr/local/hadoop/bin/hdfs dfs -chmod g+w /user/hive/warehouse

cd /usr/local/apache-hive-${HIVE_VERSION}-bin && ${HIVE_HOME}/bin/schematool -dbType derby -initSchema

tail -f /dev/null

