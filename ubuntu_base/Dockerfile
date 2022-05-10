FROM ubuntu:bionic AS base

ARG NOTEBOOK_TOKEN=my_secret

RUN apt-get update -y && \
    apt-get install --no-install-recommends sudo -y && \
    apt-get install --no-install-recommends nano -y && \
    apt-get install --no-install-recommends openssh-server openssh-client -y && \
    apt-get install --no-install-recommends wget -y && \
    rm -rf /var/lib/apt/lists/*

#allow running ssh without password asking
RUN sudo echo -e "Host *\nStrictHostKeyChecking no\nUserKnownHostsFile=/dev/null" >>  /etc/ssh/ssh_config
#disable ipv6 -- needed for hadoop
RUN sudo echo -e 'net.ipv6.conf.all.disable_ipv6=1\nnet.ipv6.conf.default_ipv6=1\nnet.ipv6.conf.lo.disable_ipv6=1' >> /etc/sysctl.conf

RUN mkdir ~/.ssh
# =============================================================================
# ========== Create SSH keys
# =============================================================================
FROM ubuntu:bionic AS ssh_keys

RUN mkdir keys && apt-get update -y && apt-get install --no-install-recommends openssh-server -y

#add hdfs user to hadoop group with root privilages
RUN  ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && \
     cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
     chmod 0600 ~/.ssh/authorized_keys && \
     chmod +x ~/.ssh

RUN cp -r ~/.ssh/* /keys

# =============================================================================
# ========== Download python and jupyter
# =============================================================================
FROM base 

RUN mkdir /skripts

#sh to add user 
#echo -e  "adduser --ingroup hadoop $HDFS_USER <<EOF\n$PASS\n$PASS\nEOF"  >  addnewuser.sh 
# sh to add permissisons of user particular to folder
# sh to add ssh permissions
# sh to add remote kernel has parameteres as host
# start ssh service at startup in every cont 
#sh to safely reload hdfs
# add sh to alter xml parameters - as in europe docker -hive

RUN ln -sf /bin/bash /bin/sh

# copy keys to ssh
COPY --from=ssh_keys /keys/*  /root/.ssh/


#expose Jupyter notebook default port
EXPOSE 8888


