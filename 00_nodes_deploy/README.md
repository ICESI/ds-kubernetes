### Glusterfs (Inicialización)

En el nodo maestro
```
sudo gluster peer probe node1
sudo gluster peer probe node2
sudo gluster peer probe node3
gluster pool list
sudo gluster volume create swarm-vols replica 3 node0:/gluster/data node1:/gluster/data node2:/gluster/data node3:/gluster/data force
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
sudo kubeadm init --pod-network-cidr=192.168.0.0/16 --ignore-preflight-errors CRI --apiserver-advertise-address $(hostname -I | awk '{print $2}') --ignore-preflight-errors=SystemVerification
```

Ejecutar como el usuario vagrant ( si se ha hecho un kubeadm reset ejecutar primero rm -rf ~/.kube )
```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

Instalar una instancia de etcd
```
kubectl apply -f \
https://docs.projectcalico.org/v3.2/getting-started/kubernetes/installation/hosted/etcd.yaml
```

Instalar los roles RBAC
```
kubectl apply -f \
https://docs.projectcalico.org/v3.2/getting-started/kubernetes/installation/rbac.yaml
```

Instalar calico (aqui uso la rama master, para evitar inconvenientes podria fijar una version, ejemplo: 3.2)
```
kubectl apply -f \
https://docs.projectcalico.org/master/getting-started/kubernetes/installation/hosted/calico.yaml
```

Permitir el despliegue de contenedores en el nodo maestro
```
kubectl taint nodes --all node-role.kubernetes.io/master-
```

Esperar a que los pods de red esten en ejecución
```
kubectl get pods --all-namespaces
```

Unir los nodos, ( si se ha hecho un kubeadm reset ejecutar primero rm -rf ~/.kube ) 
```
kubeadm join 192.168.56.101:6443 --token pgmop3.hyakc1edre6tl1l7 --discovery-token-ca-cert-hash sha256:9ab154a9d87b8ae05c871e19dae210f445fda1a4006b3b672424849399e32bbd
mkdir -p $HOME/.kube
sudo scp root@192.168.56.101:/etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
kubectl get nodes
```

### Comandos útiles

Conocer el servicio que usa un puerto (port)
```
lsof -i :port -S
```

Diagnosticar fallas de kubernetes
```
journalctl -xeu kubelet
```

Ver los logs de los pods del sistema (CrashLoopBackOff)
```
kubectl -n kube-system describe pod calico-node-mjvr8
```

Chequear el liveness probe check
```
netstat -anp | grep "LISTEN" | grep 9099
```

Install calicoctl and test
```
curl -O -L https://github.com/projectcalico/calicoctl/releases/download/v3.2.3/calicoctl
chmod +x calicoctl
export ETCD_ENDPOINTS=http://10.96.232.136:6666
./calicoctl get nodes
```

Otros comandos

```
kubectl get nodes
kubectl create -f pod-nginx.yaml
kubectl delete pod nginx
kubectl label nodes node1 nodetype=development
kubectl get pods -o wide
kubectl get endpoints
kubectl get pods --all-namespaces -o wide
kubectl logs -n kube-system <weave-net-pod> weave
kubectl delete -f calico.yaml
```

### Activities
* Despliegue un cluster de kubernetes y verifique la estabilidad de los contenedores en los nodos (todos en running)
* Despliegue un ejemplo que haga uso de los nodos

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

* https://github.com/kubernetes/kubernetes/issues/33671

* https://kubernetes.io/docs/concepts/configuration/assign-pod-node/  

* https://docs.projectcalico.org/v3.2/getting-started/kubernetes/
* https://github.com/kubernetes/kubernetes/issues/50295       


### Pasos DEPRECATED

Esto lo hice la primera vez pero ya no lo estoy usando
```
kubeadm init --apiserver-advertise-address $(hostname -I | awk '{print $2}') --pod-network-cidr=192.168.0.0/16
kubectl taint nodes --all node-role.kubernetes.io/master-
mv  $HOME/.kube $HOME/.kube.bak
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
kubectl apply -f https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/hosted/kubeadm/1.7/calico.yaml
kubectl get pods --all-namespaces
```

No fue necesario estaba buscando alcanzar el liveness pero el liveness es local a cada nodo
```
# Auto-detect the BGP IP address.
- name: IP
  value: "autodetect"
- name: IP_AUTODETECTION_METHOD
  value: "interface=enp0s8"
```

No fue necesario, calico se instala solo poniendo un contenedor y un punto de montaje en los nodos
```
sysctl net.bridge.bridge-nf-call-iptables=1
export kubever=$(kubectl version | base64 | tr -d '\n')
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$kubever"
```

Unir los nodos
```
mkdir -p /etc/cni/net.d/
vi /etc/cni/net.d/10-weave.conf
{
    "name": "weave",
    "type": "weave-net",
    "hairpinMode": true
}
chmod 744 /etc/cni/net.d/10-weave.conf
kubeadm join 192.168.56.101:6443 --token pgmop3.hyakc1edre6tl1l7 --discovery-token-ca-cert-hash sha256:9ab154a9d87b8ae05c871e19dae210f445fda1a4006b3b672424849399e32bbd
```

