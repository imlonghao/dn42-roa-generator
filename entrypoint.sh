#!/bin/sh

if [ ! -d /root/.ssh ]
then
mkdir /root/.ssh
fi

if [ ! -f /root/.ssh/config ]
then
cat << EOF > /root/.ssh/config
Host github.com
	StrictHostKeyChecking no
EOF
fi

if [ ! -f /root/.ssh/id_ed25519 ]
then
cp /run/secrets/id_ed25519 /root/.ssh/id_ed25519
chmod 0400 /root/.ssh/id_ed25519
fi

if [ ! -d /data/registry ]
then
git clone https://git.dn42.us/dn42/registry /data/registry
fi

if [ ! -d /data/dn42-roa-generator ]
then
git clone git@github.com:imlonghao/dn42-roa-generator.git /data/dn42-roa-generator
cd /data/dn42-roa-generator
git checkout roas
fi

while /bin/true
do

cd /data/registry
git pull

/app -path /data/registry -type 4 > /data/dn42-roa-generator/roa4.conf
/app -path /data/registry -type 6 > /data/dn42-roa-generator/roa6.conf

cd /data/dn42-roa-generator
git add roa4.conf roa6.conf
git commit -m "Auto Update @ $(date -u "+%Y-%m-%dT%H:%M:%S")"
git push

sleep 30m

done
