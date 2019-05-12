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
* https://kubernetes.io/docs/concepts/configuration/assign-pod-node/

* https://kubernetes.io/docs/reference/access-authn-authz/rbac/
* https://docs.bitnami.com/kubernetes/how-to/configure-rbac-in-your-kubernetes-cluster/
* https://github.com/kubernetes-incubator/metrics-server/issues/40

* https://github.com/kubernetes-incubator/metrics-server/issues/95
* https://github.com/kubernetes-incubator/metrics-server/issues/131





----------------

K8s dns troubleshooting

https://www.josedomingo.org/pledin/2018/11/sercicio-dns-kubernetes
https://kubernetes.io/docs/reference/kubectl/cheatsheet/

kubectl get svc -n kube-system
kubectl delete pod coredns-576cbf47c7-xkh79 -n kube-system
kubectl exec -ti busybox -- nslookup kubernetes.default (mal)

kubectl edit svc/kube-dns -n kube-system
https://github.com/kelseyhightower/kubernetes-the-hard-way/issues/356


....
k8s documentation example for horizontal scaling

kubectl run php-apache --image=k8s.gcr.io/hpa-example --requests=cpu=200m --expose --port=80
kubectl autoscale deployment php-apache --cpu-percent=50 --min=1 --max=10
kubectl get hpa
kubectl run -i --tty load-generator --image=busybox /bin/sh
wget php-apache.default.svc.cluster.local
while true; do wget -q -O- http://php-apache.default.svc.cluster.local; done
kubectl get hpa
kubectl get deployment php-apache

...
k8s ebay documentation example for horizontal scaling

kubectl create deployment php-apache --image=k8s.gcr.io/hpa-example   // ? --requests=cpu=200m
kubectl expose deployment php-apache --type=ClusterIP --port=80
kubectl get services
curl 10.103.140.95

Testing dns
nslookup kubernetes.default.svc.cluster.local 10.96.0.10
nslookup php-apache.default.svc.cluster.local 10.96.0.10


----

No se cual es el admin:password
kubectl cluster-info | grep master
curl-k -u admin:password https://192.168.56.101:6443/api/v1/proxy/namespaces/default/services/php-apache/

...

https://github.com/eBay/Kubernetes/tree/master/docs/user-guide/horizontal-pod-autoscaling

....

remove permanently a pod

kubectl get deployments --all-namespaces
kubectl delete -n NAMESPACE deployment DEPLOYMENT
kubectl delete pods podname --grace-period=0 --force

https://stackoverflow.com/questions/40686151/kubernetes-pod-gets-recreated-when-deleted

....
Find node taints

kubectl describe nodes | grep -i taint
kubectl describe nodes your-node-name | grep -i taint

...
Deploy a kubernetes hello world

kubectl create deployment hello-node --image=gcr.io/hello-minikube-zero-install/hello-node
https://kubernetes.io/docs/tutorials/hello-minikube/
https://www.mirantis.com/blog/introduction-to-yaml-creating-a-kubernetes-deployment/


....
hpa-php-apache.yaml
kubectl create -f hpa-php-apache.yaml

apiVersion: autoscaling/v1
kind: HorizontalPodAutoscaler
metadata:
  name: php-apache
  namespace: default
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: php-apache
  minReplicas: 1
  maxReplicas: 10
  targetCPUUtilizationPercentage: 50

hpa-php-apache-deployment.yaml
kubectl create -f hpa-php-deployment.yaml

---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: hpa-example
spec:
  #replicas: 2
  template:
    metadata:
      labels:
        app: hpa-example
    spec:
      containers:
        - name: hpa-container
          image: k8s.gcr.io/hpa-example
          resources:
            requests:
              #memory: "64Mi"
              cpu: "100m"
            limits:
              #memory: "64Mi"
              cpu: "200m"
          ports:
            - containerPort: 80

----
apiVersion: v1
kind: Pod
metadata:
  name: hpa-example
  labels:
    app: hpa-application
spec:
  containers:
    - name: hpa-container
      image: k8s.gcr.io/hpa-example
      resources:
        requests:
          #memory: "64Mi"
          cpu: "100m"
        limits:
          #memory: "64Mi"
          cpu: "200m"
      ports:
        - containerPort: 80


---
Check resources consumption

From node0
while true; do curl http://10.111.198.19; done

kubectl exec -it load-generator-7fbcc7489f-drx7l /bin/sh
# top


——————

https://www.digitalocean.com/community/tutorials/an-introduction-to-kubernetes
https://www.cncf.io/the-childrens-illustrated-guide-to-kubernetes/
https://learning.oreilly.com/videos/kubernetes-course-from/9781789806823/9781789806823-video4_2
