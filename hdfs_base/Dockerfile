ARG JAVA_VERSION=8u322b06
ARG JAVA_VERSION_URL=jdk8u322-b06
ARG JAVA_SYMLINK_NAME=jre-8
ARG HDFS_USER=hdfs_user
ARG NOTEBOOK_USER=JUPY

# todo ------------------------------------------------------------------------------------------- todo 
#
# -----   use separate image only to compile hadoop disto with no native code and docks ------
#
# todo-----------------------------------------------------------------------------------------  todo

# =============================================================================
# ========== Download all the dependencies to build hadoop tar.gz
# =============================================================================

# =============================================================================
# ========== Create HDFS user 
# =============================================================================
FROM ubuntu_base AS base

ENV HDFS_USER hdfs_user
ENV PASS hdfs

RUN ln -sf /bin/bash /bin/sh 

#add hdfs user to hadoop group with root privilages
RUN sudo addgroup hadoop && sudo echo -e  "adduser --ingroup hadoop $HDFS_USER <<EOF\n$PASS\n$PASS\nEOF"  >  addnewuser.sh && \
    chmod +x addnewuser.sh && ./addnewuser.sh && usermod -aG sudo $HDFS_USER && \
    echo "$HDFS_USER ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers

# =============================================================================
# ========== Download jre
# =============================================================================
#taken from here https://github.com/kristinjeanna/docker-ubuntu-jre8/blob/main/Dockerfile
FROM ubuntu:bionic AS jre-downloader

USER root

# JRE8 args
ARG JAVA_VERSION
ARG JAVA_VERSION_URL
ARG JAVA_RELEASE_URL=https://github.com/adoptium/temurin8-binaries/releases/download/${JAVA_VERSION_URL}
ARG JAVA_FILENAME=OpenJDK8U-jre_x64_linux_hotspot_${JAVA_VERSION}.tar.gz
ARG JAVA_EXTRACT_DIR=jre${JAVA_VERSION}
ARG JAVA_SYMLINK_NAME

# download JRE or simly use jre headless??????????????? sudo apt install default-jre
#we need check this checksum
RUN mkdir /opt/${JAVA_EXTRACT_DIR} && \
	cd /opt && \
	apt-get update && \
	DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y wget && \
	wget --no-check-certificate ${JAVA_RELEASE_URL}/${JAVA_FILENAME} && \
	tar -xzv -C ${JAVA_EXTRACT_DIR} -f ${JAVA_FILENAME} --strip-components=1 && \
	ln -s ${JAVA_EXTRACT_DIR} ${JAVA_SYMLINK_NAME} && \
	rm ${JAVA_FILENAME} && \
    rm -rf /var/lib/apt/lists/*

# =============================================================================
# ========== Assemble the final docker image
# =============================================================================
FROM base AS base_jre

ARG JAVA_VERSION
ARG JAVA_SYMLINK_NAME

LABEL "java.version"="${JAVA_VERSION}"

ENV JAVA_HOME=/opt/${JAVA_SYMLINK_NAME}
ENV PATH=${JAVA_HOME}/bin:${PATH}

# copy the downloaded Java JRE
COPY --from=jre-downloader /opt /opt


# =============================================================================
# ========== Download hadoop 
# =============================================================================
ARG JAVA_VERSION
ARG HADOOP_VERSION

FROM base_jre AS hadoop_install

ENV HDFS_USER hdfs_user

RUN mkdir /home/${HDFS_USER}/.ssh && cp -r /root/.ssh/* /home/${HDFS_USER}/.ssh

USER  $HDFS_USER
WORKDIR /usr/local
ENV JAVA_SYMLINK_NAME jre-8
ENV HADOOP_VERSION 3.3.1

RUN sudo apt-get update && sudo apt-get install --no-install-recommends -y wget && \
    sudo wget --no-check-certificate  https://downloads.apache.org/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz && \
    sudo tar zxvf hadoop-${HADOOP_VERSION}.tar.gz &&  sudo rm hadoop-${HADOOP_VERSION}.tar.gz && \
    sudo mv hadoop-${HADOOP_VERSION} hadoop && sudo chown -R $HDFS_USER:hadoop /usr/local/hadoop && \
    sudo chmod -R 777 /usr/local/hadoop && \
    sudo chown -R $HDFS_USER:hadoop ~/.ssh && sudo chmod -R 777 ~/.ssh && \
    sudo chmod 0600 ~/.ssh/authorized_keys && \
    sudo chmod 700 ~/.ssh && chmod 600 ~/.ssh/* && \
    sudo chmod 700 /src && chmod 600 /src && \
    sudo apt clean && \
    sudo rm -rf /var/lib/apt/lists/*

#adding hadoop and java environment variable
#todo add new variables with a sh script
# this added to one run command
# not sure we need them so much
RUN printf 'export JAVA_HOME=/opt/${JAVA_SYMLINK_NAME}\n\ 
export PATH=$PATH:$JAVA_HOME/bin\n\
export HADOOP_VERSION=3.3.1\n\ 
export HDFS_USER=hdfs_user\n\ 
export HADOOP_HOME=/usr/local/hadoop\n\ 
export HADOOP_CONF_DIR=/usr/local/hadoop/etc/hadoop\n\ 
export HADOOP_MAPRED_HOME=/usr/local/hadoop\n\ 
export HADOOP_COMMON_HOME=/usr/local/hadoop\n\ 
export HADOOP_HDFS_HOME=/usr/local/hadoop\n\ 
export YARN_HOME=/usr/local/hadoop\n\ 
export PATH=$PATH:/usr/local/hadoop/bin\n\ 
export PATH=$PATH:/usr/local/hadoop/sbin\n\ 
export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native\n\ 
export HADOOP_OPTS="-Djava.library.path=$HADOOP_HOME/lib"' >> ~/.bashrc && . ~/.bashrc

RUN printf 'export HADOOP_OPTS=-Djava.net.preferIPv4Stack=true\n 
export JAVA_HOME=/opt/jre-8\n 
export HADOOP_OPTS="$HADOOP_OPTS -Djava.net.preferIPv4Stack=true -Djava.security.krb5.realm= -Djava.security.krb5.kdc="\n 
export HADOOP_HOME_WARN_SUPPRESS="TRUE" ' >> /usr/local/hadoop/etc/hadoop/hadoop-env.sh

#copy config files and startup file to destination
#TODO - implement sh script to update those values like here
# https://github.com/Marcel-Jan/docker-hadoop-spark/blob/master/base/entrypoint.sh
#add proxy users to core sites  as from here https://docs.cloudera.com/documentation/enterprise/6/6.3/topics/admin_hdfs_proxy_users.html#:~:text=Hadoop%20allows%20you%20to%20configure%20proxy%20users%20to,than%20those%20of%20a%20superuser%20%28such%20as%20hdfs%29.
COPY core-site.xml /usr/local/hadoop/etc/hadoop/
COPY hdfs-site.xml /usr/local/hadoop/etc/hadoop/
COPY yarn-site.xml /usr/local/hadoop/etc/hadoop/
COPY mapred-site.xml /usr/local/hadoop/etc/hadoop/
COPY bootstrap_hadoop.sh /usr/local/

# add this to ssh to kernel remotely
 
#remote_ikernel manage --add \
#    --name="test-kernel" \
#    --kernel_cmd="ipython kernel -f {connection_file} && echo "HEy"" \
#    --interface=ssh \
#    --host=some@exam

RUN sudo chmod +x /usr/local/bootstrap_hadoop.sh

CMD ["bash"]

# Hdfs ports
EXPOSE 50010 50020 50070 50075 50090 8020 9000 9870
# Mapred ports
EXPOSE 10020 19888
#Yarn ports
EXPOSE 8030 8031 8032 8033 8040 8042 8088
#Other ports
EXPOSE 49707 2122 22 8899



