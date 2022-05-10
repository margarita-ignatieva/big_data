FROM hadoop-base

#according to https://phoenixnap.com/kb/install-hive-on-ubuntu

ENV HIVE_VERSION 3.1.2

#todo rename to short hive folder with mv command
RUN sudo wget https://downloads.apache.org/hive/hive-${HIVE_VERSION}/apache-hive-${HIVE_VERSION}-bin.tar.gz && \
    sudo tar xzf apache-hive-${HIVE_VERSION}-bin.tar.gz && sudo  rm apache-hive-${HIVE_VERSION}-bin.tar.gz

#todo maybe need another user to run hive explicitly
RUN  sudo chown -R $HDFS_USER:hadoop /usr/local/apache-hive-${HIVE_VERSION}-bin && \
sudo  chmod -R 777 /usr/local/apache-hive-${HIVE_VERSION}-bin

ENV HIVE_HOME /usr/local/apache-hive-${HIVE_VERSION}-bin

RUN echo 'export HIVE_HOME=/usr/local/apache-hive-${HIVE_VERSION}-bin' >> ~/.bashrc
RUN echo 'export PATH=$PATH:$HIVE_HOME/bin' >> ~/.bashrc
RUN . ~/.bashrc

RUN chmod +x ${HIVE_HOME}/bin/hive-config.sh
RUN echo 'export HADOOP_HOME=/usr/local/hadoop' >>  $HIVE_HOME/bin/hive-config.sh

ADD hive-site.xml $HIVE_HOME/conf
ADD hive_run.sh /usr/local
RUN sudo chmod +x /usr/local/hive_run.sh
#RUN ./bootstrap_hadoop.sh
#RUN ./hive_run.sh

#RUN cd apache-hive-${HIVE_VERSION}-bin && $HIVE_HOME/bin/schematool -dbType derby -initSchema

#for following commands running hdfs needed -- alter to not hardcoded
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["./bootstrap_hadoop.sh", "./hive_run.sh"]

