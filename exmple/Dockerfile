

# =============================================================================
# ========== Create HDFS user 
# =============================================================================
FROM jupyter-base AS base

ENV HDFS_USER some
ENV PASS some

RUN ln -sf /bin/bash /bin/sh 

#add hdfs user to hadoop group with root privilages
RUN sudo addgroup hadoop && sudo echo -e  "adduser --ingroup hadoop $HDFS_USER <<EOF\n$PASS\n$PASS\nEOF"  >  addnewuser.sh && \
    chmod +x addnewuser.sh && ./addnewuser.sh && usermod -aG sudo $HDFS_USER && \
    echo "$HDFS_USER ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers

RUN mkdir /home/${HDFS_USER}/.ssh
RUN cp -r /root/.ssh/* /home/${HDFS_USER}/.ssh

USER  $HDFS_USER

RUN sudo chown -R $HDFS_USER:hadoop ~/.ssh && sudo chmod -R 777 ~/.ssh && \
     chmod 0600 ~/.ssh/authorized_keys && \
     chmod 700 ~/.ssh && chmod 600 ~/.ssh/*


