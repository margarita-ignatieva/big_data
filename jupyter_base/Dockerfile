FROM ubuntu:bionic AS base

ARG NOTEBOOK_TOKEN=my_secret

RUN apt-get update -y && \
    apt-get install --no-install-recommends sudo -y && \
    apt-get install --no-install-recommends nano -y && \
    apt-get install --no-install-recommends openssh-server openssh-client -y && \
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

RUN mkdir keys && apt-get update -y && apt-get install --no-install-recommends openssh-server openssh-client -y

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

RUN ln -sf /bin/bash /bin/sh

# copy keys to ssh
COPY --from=ssh_keys /keys/*  /root/.ssh/

RUN mkdir src
# todo wee need so many python?
RUN sudo apt-get update && apt-get install --no-install-recommends  -y build-essential python3.6 python3-pip python3-dev && \
    pip3 install remote_ikernel && \
    sudo apt clean && \
    sudo rm -rf /var/lib/apt/lists/*

RUN echo 'export PATH=$PATH:/home/root/.local/bin' >> ~/.bashrc && . ~/.bashrc

WORKDIR src/

RUN pip3 install jupyter && pip3 install virtualenv && mkdir tasks

#CMD ["jupyter", "notebook", "--port=8888", "--no-browser", "--ip=0.0.0.0", "--allow-root", "--NotebookApp.token='${NOTEBOOK_TOKEN}'"]

#expose Jupyter notebook default port
EXPOSE 8888


