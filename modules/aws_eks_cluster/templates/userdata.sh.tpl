#!/bin/bash -xe

# Custom monitoring scripts
# Install prerequisites
yum update -y
yum -y install  perl-Switch perl-DateTime perl-Sys-Syslog perl-LWP-Protocol-https perl-Digest-SHA

# Donwload and unzip monitoring scripts
curl http://aws-cloudwatch.s3.amazonaws.com/downloads/CloudWatchMonitoringScripts-1.2.1.zip > /home/ec2-user/CloudWatchMonitoringScripts-1.2.1.zip
unzip /home/ec2-user/CloudWatchMonitoringScripts-1.2.1.zip -d /home/ec2-user/
rm /home/ec2-user/CloudWatchMonitoringScripts-1.2.1.zip
chown ec2-user:ec2-user /home/ec2-user/aws-scripts-mon

# Configure cron to run monitoring scripts
echo "*/5 * * * * /home/ec2-user/aws-scripts-mon/mon-put-instance-data.pl --mem-util --mem-used --mem-avail" >> /var/spool/cron/ec2-user

# Allow user supplied pre userdata code
${pre_userdata}

# Bootstrap and join the cluster
/etc/eks/bootstrap.sh --b64-cluster-ca '${cluster_auth_base64}' --apiserver-endpoint '${endpoint}' --kubelet-extra-args '${kubelet_extra_args}' '${cluster_name}'

# Allow user supplied userdata code
${additional_userdata}

# Install ssm agent
mkdir /tmp/ssm
cd /tmp/ssm
yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

