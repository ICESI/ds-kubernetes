### Kubernetes (Inicialización)

Los siguientes pasos fueron probados con las siguientes versiones de agentes:
```
vagrant@node0:~$ kubeadm version
kubeadm version: &version.Info{Major:"1", Minor:"14", GitVersion:"v1.14.1", GitCommit:"b7394102d6ef778017f2ca4046abbaa23b88c290", GitTreeState:"clean", BuildDate:"2019-04-08T17:08:49Z", GoVersion:"go1.12.1", Compiler:"gc", Platform:"linux/amd64"}

vagrant@node0:~$ kubectl version
Client Version: version.Info{Major:"1", Minor:"14", GitVersion:"v1.14.1", GitCommit:"b7394102d6ef778017f2ca4046abbaa23b88c290", GitTreeState:"clean", BuildDate:"2019-04-08T17:11:31Z", GoVersion:"go1.12.1", Compiler:"gc", Platform:"linux/amd64"}
Server Version: version.Info{Major:"1", Minor:"14", GitVersion:"v1.14.1", GitCommit:"b7394102d6ef778017f2ca4046abbaa23b88c290", GitTreeState:"clean", BuildDate:"2019-04-08T17:02:58Z", GoVersion:"go1.12.1", Compiler:"gc", Platform:"linux/amd64"}
vagrant@node0:~$ kubelet --version
Kubernetes v1.14.1

vagrant@node0:~$ docker -v
Docker version 18.09.5, build e8ff056
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

Para desplegar un pod hello-node
```
kubectl create deployment hello-node --image=gcr.io/hello-minikube-zero-install/hello-node
```

server.js
```
var http = require('http');

var handleRequest = function(request, response) {
  console.log('Received request for URL: ' + request.url);
  response.writeHead(200);
  response.end('Hello World!');
};
var www = http.createServer(handleRequest);
www.listen(8080);
```

Dockerfile
```
FROM node:6.14.2
EXPOSE 8080
COPY server.js .
CMD node server.js
```

### Comandos útiles

| Command  | Description  |
|---|---|
| kubeadm token create --print-join-command | Obtener el comando de union de un nodo|
| kubectl logs metrics-server-5845cc8fd4-s7tgx -n kube-system | Chequear los logs de un pod del namespace del sistema |
| journalctl -xeu kubelet | Diagnosticar fallas de kubernetes |
| journalctl -xeu docker | Diagnosticar fallas de Docker |
| lsof -i :port -S | Conocer el servicio que usa un puerto (port) |
| sudo netstat -tlpn | Conocer el servicio que usa un puerto (port) |
| `netstat -anp \| grep "LISTEN" \| grep 9099` | Chequear el liveness probe check |
| kubeadm reset | Reinicia el agente de administración de kubernetes, elimina los directorios creados|
| systemctl stop kubelet | Detiene el agente de kubelet |
|---|---|
|kubectl get nodes | Obtener los nodos del cluster |
|kubectl get pods --all-namespaces -o wide | Obtener los pods desplegados en todos los nodos y namespaces|
|kubectl describe node node1 | Obtener información del nodo 1|
|kubectl create -f pod-nginx.yaml | |
|kubectl delete pod nginx | |
|kubectl label nodes node1 nodetype=development | |
|kubectl get endpoints | |
|kubectl logs -n kube-system <weave-net-pod> weave | |
|kubectl delete -f calico.yaml | |
|---|---|
| kubectl drain node2 --ignore-daemonsets --delete-local-dat | |
| kubectl delete node node2 | |
|---|---|
| kubectl describe pod calico-node-mjvr8 -n kube-system | Ver los logs de los pods del sistema (CrashLoopBackOff) |
| kubectl delete pod coredns-576cbf47c7-qcdn4 -n kube-system | Borrar un pod del sistema |
|---|---|

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
* https://github.com/kubernetes/website.git
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
* https://github.com/GoogleCloudPlatform/microservices-demo
