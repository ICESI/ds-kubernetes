### Kubernetes (Inicialización)

Los siguientes pasos fueron probados con las siguientes versiones de agentes:
```
vagrant@node0:~$ kubelet --version
Kubernetes v1.12.2
vagrant@node0:~$ kubeadm version
kubeadm version: &version.Info{Major:"1", Minor:"12", GitVersion:"v1.12.2", GitCommit:"17c77c7898218073f14c8d573582e8d2313dc740", GitTreeState:"clean", BuildDate:"2018-10-24T06:51:33Z", GoVersion:"go1.10.4", Compiler:"gc", Platform:"linux/amd64"}
vagrant@node0:~$ kubectl version
Client Version: version.Info{Major:"1", Minor:"12", GitVersion:"v1.12.2", GitCommit:"17c77c7898218073f14c8d573582e8d2313dc740", GitTreeState:"clean", BuildDate:"2018-10-24T06:54:59Z", GoVersion:"go1.10.4", Compiler:"gc", Platform:"linux/amd64"}
Server Version: version.Info{Major:"1", Minor:"12", GitVersion:"v1.12.7", GitCommit:"6f482974b76db3f1e0f5d24605a9d1d38fad9a2b", GitTreeState:"clean", BuildDate:"2019-03-25T02:41:57Z", GoVersion:"go1.10.8", Compiler:"gc", Platform:"linux/amd64"}
vagrant@node0:~$ docker -v
Docker version 18.09.0, build 4d60db4
```

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

Instalar calico (aqui hago ping a la rama v3.5, con la version master ya no funciona)
```
kubectl apply -f \
https://docs.projectcalico.org/v3.5/getting-started/kubernetes/installation/hosted/calico.yaml
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
kubeadm join 192.168.56.101:6443 --token pgmop3.hyakc1edre6tl1l7 --discovery-token-ca-cert-hash sha256:9ab154a9d87b8ae05c871e19dae210f445fda1a4006b3b672424849399e32bbd --ignore-preflight-errors=SystemVerification
mkdir -p $HOME/.kube
sudo scp root@192.168.56.101:/etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
kubectl get nodes
```

### Comandos útiles

| Command  | Description  |
|---|---|
|kubectl get nodes | |
|kubectl create -f pod-nginx.yaml | |
|kubectl delete pod nginx | |
|kubectl label nodes node1 nodetype=development | |
|kubectl get pods -o wide | |
|kubectl get endpoints | |
|kubectl get pods --all-namespaces -o wide | |
|kubectl logs -n kube-system <weave-net-pod> weave | |
|kubectl delete -f calico.yaml | |
|kubeadm token create --print-join-command | Obtener el comando de union de un nodo|
|---|---|
| lsof -i :port -S | Conocer el servicio que usa un puerto (port) |
| journalctl -xeu kubelet | Diagnosticar fallas de kubernetes |
| kubectl -n kube-system describe pod calico-node-mjvr8 | Ver los logs de los pods del sistema (CrashLoopBackOff) |
| `netstat -anp \| grep "LISTEN" \| grep 9099` | Chequear el liveness probe check |

### Calico

| Command  | Description  |
|---|---|
| curl -O -L https://github.com/projectcalico/calicoctl/releases/download/v3.2.3/calicoctl | Install calicoctl and test |
| chmod +x calicoctl | |
| export ETCD_ENDPOINTS=http://10.96.232.136:6666 | |
| ./calicoctl get nodes | |

### Activities
* Despliegue un cluster de kubernetes y verifique la estabilidad de los contenedores en los nodos (todos en running)
* Despliegue un ejemplo que haga uso de los nodos y un sistema de ficheros distribuido

### References
* https://github.com/kubernetes/examples/tree/master/staging/volumes/glusterfs
* https://kubernetes.io/docs/concepts/storage/persistent-volumes/
* https://kubernetes.io/docs/tutorials/stateful-application/basic-stateful-set/
* https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/
* https://kubernetes.io/docs/setup/independent/install-kubeadm/
* https://gist.github.com/d4n13lbc/5c54262b76fa3b41f44331b243765fc3
* https://gist.github.com/d4n13lbc/cf63ef0baf2280ceaf3cab8dd157e658
* https://kubernetes.io/docs/tutorials/
* https://github.com/kubernetes/kubernetes/issues/33671
* https://kubernetes.io/docs/concepts/configuration/assign-pod-node/  
* https://docs.projectcalico.org/v3.2/getting-started/kubernetes/
* https://github.com/kubernetes/kubernetes/issues/50295       
