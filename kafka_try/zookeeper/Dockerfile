
# =============================================================================
# ========== Create SPARK user 
# =============================================================================
FROM ubuntu:bionic AS base

ENV SPARK_USER spark_user
ENV PASS spark

RUN ln -sf /bin/bash /bin/sh 

#add python version to vars
RUN apt-get update && \
    apt-get -y install sudo &&  \
    sudo apt-get -y install --no-install-recommends python3.8   && \
    sudo apt-get -y install --no-install-recommends python3-pip && \
    pip3 install ipython

#add hdfs user to hadoop group with root privilages
#add code to grant hdfs privilages to all its locations -- too hadoop folder -- no hadoop folder exists
#better create all users in jupyter base image and add all them to sudo group with hadoop folder permissions - create hadoop folder in advance
RUN sudo addgroup spark && sudo echo -e  "adduser --ingroup spark $SPARK_USER <<EOF\n$PASS\n$PASS\nEOF"  >  addnewuser.sh && \
    chmod +x addnewuser.sh && ./addnewuser.sh && usermod -aG sudo $SPARK_USER && \
    echo "$SPARK_USER ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers

# =============================================================================
# ========== Download jre and scala
# =============================================================================
#taken from here https://github.com/kristinjeanna/docker-ubuntu-jre8/blob/main/Dockerfile
FROM base AS spark_prep

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get -y install --no-install-recommends default-jre-headless && \
    apt-get -y install --no-install-recommends scala && \
    apt-get clean && \
    sudo rm -rf /var/lib/apt/lists/*

##from here we just need copy scala and jre dirs

# =============================================================================
# ========== Download spark
# =============================================================================
ARG JAVA_VERSION
ARG HADOOP_VERSION

FROM spark_prep

USER  $SPARK_USER
WORKDIR /usr/local
ENV HADOOP_VERSION 3.3.1

RUN sudo apt-get update && \
    DEBIAN_FRONTEND=noninteractive \    
    sudo apt-get -y install --no-install-recommends wget && \
    sudo wget https://downloads.apache.org/spark/spark-3.2.1/spark-3.2.1-bin-hadoop3.2.tgz && \
    sudo tar xvf spark-* && sudo mv spark-3.2.1-bin-hadoop3.2 /usr/local/spark && \
    sudo rm spark-3.2.1-bin-hadoop3.2.tgz && \
    sudo chown -R $SPARK_USER:spark /usr/local/spark && \
    sudo chmod -R 777 /usr/local/spark
    sudo apt-get clean && \
    sudo rm -rf /var/lib/apt/lists/*  

RUN printf 'export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64\n\ 
export PATH=$PATH:$JAVA_HOME/bin\n\ 
export SCALA=/usr/share/scala-2.11\n\ 
export PATH=$PATH:$SCALA/bin\n\ 
export SPARK_HOME=/usr/local/spark\n\
export PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin\n\
export PYSPARK_PYTHON=/usr/bin/python3' >> ~/.bashrc && . ~/.bashrc 

ENTRYPOINT ["start-all.sh"]

EXPOSE 8080 7077



