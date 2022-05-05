ARG JAVA_VERSION=8u332b09
ARG JAVA_VERSION_URL=jdk8u332-b09
ARG JAVA_SYMLINK_NAME=jre-8
ARG HDFS_USER=hdfs_user
ARG NOTEBOOK_USER=JUPY
# todo ------------------------------------------------------------------------------------------- todo 
#
# -----   use separate image only to compile hadoop disto with no native code and docks ------
#
# todo-----------------------------------------------------------------------------------------  todo


#FROM ubuntu:bionic AS jre-downloader
#
#USER root
#
#RUN mkdir /opt/jre-8 && \
#	cd /opt && \
#	apt-get update -y && \
#	apt-get install --no-install-recommends openjdk-8-jre-headless -y && \
#    apt clean && \
#    rm -rf /var/lib/apt/lists/*



FROM ubuntu:bionic AS jre-downloader

USER root

# JRE8 args
ARG JAVA_VERSION
ARG JAVA_VERSION_URL
ARG JAVA_RELEASE_URL=https://github.com/adoptium/temurin8-binaries/releases/download/${JAVA_VERSION_URL}
ARG JAVA_FILENAME=OpenJDK8U-jre_arm_linux_hotspot_${JAVA_VERSION}.tar.gz
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
    apt clean && \
    rm -rf /var/lib/apt/lists/*
#

