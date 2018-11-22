FROM ubuntu:18.04
RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

RUN apt-get update && apt-get install -y curl git unzip wget python3-minimal python-minimal zip

#Install Kubectl
RUN apt-get install -y apt-transport-https gnupg2 && \
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list && \
apt-get update && \
apt-get install -y kubectl

#Install aws-iam-authenticator
RUN curl -o aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-07-26/bin/linux/amd64/aws-iam-authenticator && \
mv aws-iam-authenticator /usr/local/bin/ && chmod +x /usr/local/bin/aws-iam-authenticator

#Install aws cli
RUN curl -O https://bootstrap.pypa.io/get-pip.py && python get-pip.py --user && ~/.local/bin/pip install awscli --upgrade --user && echo "export PATH=$PATH:~/.local/bin" >> ~/.bashrc && echo "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:~/.local/bin" > /etc/environment

#Install heptio ark
RUN wget https://github.com/heptio/ark/releases/download/v0.9.7/ark-v0.9.7-linux-amd64.tar.gz && tar -xvf ark-v0.9.7-linux-amd64.tar.gz && mv ark /usr/local/bin/
