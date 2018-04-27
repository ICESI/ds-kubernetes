### Glusterfs (Inicialización)

En el nodo maestro
```
sudo gluster peer probe node2
sudo gluster peer probe node3
gluster pool list
sudo gluster volume create swarm-vols replica 3 node1:/gluster/data node2:/gluster/data node3:/gluster/data force
sudo gluster volume set swarm-vols auth.allow 127.0.0.1
sudo gluster volume start swarm-vols
```

En todos los nodos
```
sudo mount.glusterfs localhost:/swarm-vols /swarm/volumes
```

### Ejemplo Docker Swarm y Glusterfs

```
# ip=$(hostname -I | awk '{print $2}')
# docker swarm init --advertise-addr $ip
```

```
sudo docker node update --label-add nodename=node1 node1
sudo docker node update --label-add nodename=node2 node2
sudo docker node update --label-add nodename=node3 node3
mkdir /swarm/volumes/testvol
sudo docker service create --name testcon --constraint 'node.labels.nodename == node1' --mount type=bind,source=/swarm/volumes/testvol,target=/mnt/testvol busybox /bin/touch /mnt/testvol/testfile1.txt
sudo docker service ls
sudo docker service ps testcon
sudo docker service rm testcon
sudo docker service create --name testcon --constraint 'node.labels.nodename == node3' --mount type=bind,source=/swarm/volumes/testvol,target=/mnt/testvol busybox /bin/touch /mnt/testvol/testfile3.txt
sudo docker service ps testcon
ls -l /swarm/volumes/testvol/
```

### Ejemplo Kubernetes y Glusterfs

En el nodo maestro
```
kubeadm init --apiserver-advertise-address $(hostname -I | awk '{print $2}')
```

### Instalación Manual de Kubernetes

```
RELEASE="$(curl -sSL https://dl.k8s.io/release/stable.txt)"

mkdir -p /opt/bin
cd /opt/bin
curl -L --remote-name-all https://storage.googleapis.com/kubernetes-release/release/${RELEASE}/bin/linux/amd64/{kubeadm,kubelet,kubectl}
chmod +x {kubeadm,kubelet,kubectl}

curl -sSL "https://raw.githubusercontent.com/kubernetes/kubernetes/master/build/debs/kubelet.service" | sed "s:/usr/bin:/usr/local/bin:g" > /etc/systemd/system/kubelet.service
mkdir -p /etc/systemd/system/kubelet.service.d
curl -sSL "https://raw.githubusercontent.com/kubernetes/kubernetes/master/build/debs/10-kubeadm.conf" | sed "s:/usr/bin:/usr/local/bin:g" > /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
```

### References
* http://embaby.com/blog/using-glusterfs-docker-swarm-cluster/
* https://docs.gluster.org/en/latest/Quick-Start-Guide/Quickstart/
* https://github.com/kubernetes/examples/tree/master/staging/volumes/glusterfs
* https://kubernetes.io/docs/concepts/storage/persistent-volumes/
* https://kubernetes.io/docs/tutorials/stateful-application/basic-stateful-set/
* https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/
* https://kubernetes.io/docs/setup/independent/install-kubeadm/

* https://gist.github.com/d4n13lbc/5c54262b76fa3b41f44331b243765fc3
* https://gist.github.com/d4n13lbc/cf63ef0baf2280ceaf3cab8dd157e658
* https://kubernetes.io/docs/tutorials/

* http://ask.xmodulo.com/create-mount-xfs-file-system-linux.html
* https://www.cyberciti.biz/faq/linux-how-to-delete-a-partition-with-fdisk-command/

* https://support.rackspace.com/how-to/getting-started-with-glusterfs-considerations-and-installation/

* https://everythingshouldbevirtual.com/virtualization/vagrant-adding-a-second-hard-drive/
