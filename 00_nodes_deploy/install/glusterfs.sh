apt install -y glusterfs-server
apt install -y xfsprogs
systemctl start glusterfs-server

sfdisk /dev/sdb << EOF
;
EOF

mkfs.xfs /dev/sdb1
mkdir -p /gluster/data /swarm/volumes
mount /dev/sdb1 /gluster/data/
