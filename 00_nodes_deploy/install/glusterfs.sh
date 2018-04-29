apt install -y glusterfs-server
systemctl start glusterfs-server

sfdisk /dev/sdb << EOF
;
EOF

mkfs.xfs /dev/sdb1
mkdir -p /gluster/data /swarm/volumes
mount /dev/sdb1 /gluster/data/
