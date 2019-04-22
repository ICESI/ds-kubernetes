### Horizontal Scaling

Para poder emplear el escalado horizontal se requiere la instalación de un servicio de métricas

| Command  | Description  |
|---|---|
| git clone https://github.com/kubernetes-incubator/metrics-server.git | |
| cd metrics-server | |
| kubectl create -f deploy/1.8+/ | |
| kubectl edit deployment metrics-server -n kube-system | Ver anexo 1 (Solo la parte de los comandos ha sido necesaria, sigue fallando en un nodo distinto al nodo 0, en el nodo 0 esta usando https en lugar de http)|
| kubectl get apiservices | egrep metrics | |
| kubectl describe apiservice v1beta1.metrics.k8s.io | |
| kubectl get deploy,svc --namespace kube-system | egrep metrics-server | |
| kubectl top node | |
| kubectl get --raw "/apis/metrics.k8s.io/v1beta1/nodes" | jq . | |
| kubectl get nodes --all-namespaces -o wide | |

En caso de necesitar reiniciar los pods de coredns use el siguiente procedimiento

| Command  | Description  |
|---|---|
| kubectl scale --current-replicas=2 --replicas=0 deployment/coredns -n kube-system | Restart all coredns pods. (TODO: Verificar esto) |
| kubectl scale --replicas=2 deployment/coredns -n kube-system | |

En caso de necesitar reiniciar el pod de metrics-server use el siguiente procedimiento

| Command  | Description  |
|---|---|
| kubectl scale --replicas=0 deployment/metrics-server -n kube-system | |
| kubectl scale --replicas=2 deployment/coredns -n kube-system | |

#### Anexo 1:
Cambie spec.template.spec.containers.command a:

 command:
  - /metrics-server
  - --kubelet-insecure-tls
  - --kubelet-preferred-address-types=InternalIP

Adicione los hostAlias debajo de spec.template.spec.containers

hostAliases:
- hostnames:
  - node0
  ip: 192.168.56.101
- hostnames:
  - node1
  ip: 192.168.56.102
- hostnames:
  - node2
  ip: 192.168.56.103

### Troubleshooting

#### Caso 1:

El contenedor de metrics-server está en continuo CrashLoopBackOff

#### Diagnóstico

Estos comandos son reemplazados por kubectl logs ...

| Command  | Description  |
|---|---|
| kubectl describe pod metrics-server-5cbbc84f8c-lvmj2 -n kube-system | Intente obtener información del error en el pod |
| kubectl get pods --all-namespaces -o wide | Identifique el nodo donde se ha desplegado el pod |
| docker ps -a | Vaya al nodo y obtenga el id del contenedor |
| docker logs f58d2d4d8dd3 -f | Consulte los logs del contenedor |

#### Caso 2:

El comando: kubectl top node , retorna: error: metrics not available yet

#### Diagnóstico

| Command  | Description  |
|---|---|
| kubectl logs metrics-server-6888449b4-pf49v -n kube-system -c metrics-server | |

### References
* https://medium.com/@cagri.ersen/kubernetes-metrics-server-installation-d93380de008
* https://medium.com/devopslinks/how-to-restart-kubernetes-pod-7c702ca984c1
* https://github.com/wercker/stern

* https://github.com/kubernetes-incubator/metrics-server/issues/95
