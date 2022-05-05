#!/bin/bash

jps_proc=$(jps)

#port and server should be passed as env variables
server=localhost
port=22
connection_timeout=5

check_ssh_connection() {
timeout $connect_timeout bash -c "</dev/tcp/$server/$port"
if [ $? == 0 ];then
   echo "SSH Connection to $server over port $port is possible"
else
#todo add if check - if key already exists
   echo "Trying to establish SSH connection to $server over port $port"
        if [ ! "$(ls -A ~/.ssh/authorized_keys)" ]
            then 
                ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && \
                cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
                chmod 0600 ~/.ssh/authorized_keys
        fi
        #start ssh
        sudo service ssh start
fi
}

start_hadoop_services() {
if [ ! -d "${HADOOP_HOME}/data/dfs/datanode" ]
then 
    mkdir -p ${HADOOP_HOME}/data/dfs/datanode
fi

if [ ! -d "${HADOOP_HOME}/data/dfs/namenode" ]
then 
    mkdir -p ${HADOOP_HOME}/data/dfs/namenode
fi

#check if datanode directory is empty
if [ ! "$(ls -A ${HADOOP_HOME}/data/dfs/datanode)" ]
then
    #incompitable cluster ids https://www.its404.com/article/taotoxht/42713103 temp workaround
    rm -Rf /tmp/hadoop-${HDFS_USER}/*

    #format namenode
    #add check if some data exists in hdfs - not the first run
    /usr/local/hadoop/bin/hdfs namenode -format
fi

#start hadoop cluster
/usr/local/hadoop/sbin/start-dfs.sh
/usr/local/hadoop/sbin/start-yarn.sh
}

## todo check which ones are running ----
if [[ jps_proc =~ .*NameNode.* ]] && [[ jps_proc =~ .*DataNode.* ]] && [[ jps_proc =~ .*ResourceManager.* ]] && [[ jps_proc =~ .*NodeManager.* ]] && [[ jps_proc =~ .*SecondaryNameNode.* ]]
then
    echo "Following processes are running: SecondaryNameNode, NodeManager, NameNode, ResourceManager, DataNode"
else
        check_ssh_connection ; start_hadoop_services 
fi

tail -f /dev/null

