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

Dejo de funcionar con la rama master
```
kubectl apply -f \
https://docs.projectcalico.org/master/getting-started/kubernetes/installation/hosted/calico.yaml
```
