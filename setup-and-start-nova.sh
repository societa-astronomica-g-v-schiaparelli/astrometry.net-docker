#!/bin/bash

##############
# ssh server #
##############

# edit the ssh server port if already used
SSH_SERVER_PORT=2222

sed -i "s/#Port 22/Port $SSH_SERVER_PORT/g" /etc/ssh/sshd_config
sed -i "s/#PasswordAuthentication yes/PasswordAuthentication no/g" /etc/ssh/sshd_config
service ssh start

##############
# ssh client #
##############

mkdir -p /root/.ssh
ssh-keygen -t rsa -f /root/.ssh/id_rsa -q -P ""
PUBLIC_SSH_KEY=$(cat /root/.ssh/id_rsa.pub)
echo "command=\"cd /home/solve/nova/solver; ../net/testscript-astro\",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty $PUBLIC_SSH_KEY" > /root/.ssh/authorized_keys
echo -e "Host an-test\nHostname localhost\nUser root\nPort $SSH_SERVER_PORT\nIdentityFile ~/.ssh/id_rsa\nStrictHostKeyChecking=no" > /root/.ssh/config

################
# path patches #
################

mkdir -p /home/solve/
ln -s /src/astrometry /home/solve/nova
ln -s /src/astrometry /root/nova
ln -s $(which astrometry-engine) /src/astrometry/solver/backend
ln -s /src/astrometry/plot/plotann.py /usr/local/bin

########################
# indexes and settings #
########################

ln -s /data1/INDEXES /usr/local/data
mkdir -p /data1/{nova/tmp,tmp}
mkdir -p /data2/nova
for file in $(ls -p /data1/INDEXES/ | grep -v /); do
    ln -s /data1/INDEXES/$file /data2/nova/$file
done

# edit the index type
# - "2MASS" to use 2MASS data
# - any other word to use GAIA and TYCHO data
INDEX_TYPE="2MASS"

# edit the default min and max field width
minwidth="0.05"
maxwidth="5"

if [ "$INDEX_TYPE" == "2MASS" ]; then
    echo -e "add_path /data1/INDEXES/4200\nautoindex\ninparallel\nminwidth $minwidth\nmaxwidth $maxwidth" > /root/nova/net/nova.cfg
    echo -e "add_path /data1/INDEXES/4200\nautoindex\ninparallel\nminwidth $minwidth\nmaxwidth $maxwidth" > /usr/local/etc/astrometry.cfg
else
    echo -e "add_path /data1/INDEXES/4100\nadd_path /data1/INDEXES/5000\nautoindex\ninparallel\nminwidth $minwidth\nmaxwidth $maxwidth" > /root/nova/net/nova.cfg
    echo -e "add_path /data1/INDEXES/4100\nadd_path /data1/INDEXES/5000\nautoindex\ninparallel\nminwidth $minwidth\nmaxwidth $maxwidth" > /usr/local/etc/astrometry.cfg
fi

sed -i "s/SCALE_PRESET_SETTINGS = {'1':(0.1,180),/SCALE_PRESET_SETTINGS = {'1':($minwidth,$maxwidth),/g" /src/astrometry/net/views/submission.py
sed -i "s/('1','default (0.1 to 180 degrees)'),/('1','default ($minwidth to $maxwidth degrees)'),/g" /src/astrometry/net/views/submission.py

#############################
# start process_submissions #
#############################

screen -dmS "process_submissions" bash -c 'cd /src/astrometry/net; while true; do python -u process_submissions.py --jobthreads=16 --subthreads=8 < /dev/null >> proc.log 2>&1; done'

###################
# start webserver #
###################

python manage.py runserver
