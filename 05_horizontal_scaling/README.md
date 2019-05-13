### Horizontal Scaling

### Despliegue del servicio de métricas

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
| kubectl get --raw "/apis/metrics.k8s.io/v1beta1/nodes" \| jq . | |
| kubectl get nodes --all-namespaces -o wide | |
| kubectl top pods | |
| https://github.com/kubernetes-incubator/metrics-server/issues/144 | Servidor de métricas con seguridad |

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

### Despliegue de un servicio para pruebas

| Command  | Description  |
|---|---|
| kubectl create -f php-apache-hpa.yaml | |
| kubectl get hpa | |
| kubectl create -f php-apache-deployment.yaml | |
| kubectl get deployments | |
| kubectl expose deployment php-apache --type=ClusterIP --port=80 | No es necesario, si ya el deployment.yaml contiene la definición del servicio |
| kubectl get services | |
| kubectl get svc hpa-example -o yaml \| grep clusterIP | Get the cluster IP for the service
| curl 10.111.198.19 | Do a curl to the cluster IP address, in this case the 10.111.198.19 |
| nslookup php-apache.default.svc.cluster.local 10.96.0.10 | |
| while true; do curl http://10.111.198.19; done | Do multiple calls to the pod endpoint |
| kubectl create -f busybox.yaml | Crear un pod con una shell para pruebas |
| kubectl exec -it busybox -- top | |
| kubectl get hpa | Observar los cambios en el escalamiento |
|---|---|
| kubectl cluster-info \| grep master | |
| curl -k -u admin:password https://192.168.56.101:6443/api/v1/proxy/namespaces/default/services/php-apache/ | |

php-apache-hap.yaml
```
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
```

php-apache-deployment.yaml
```
apiVersion: v1
kind: Service
metadata:
  name: php-apache
  labels:
    app: php-apache
spec:
  ports:
    - port: 80
  selector:
    app: php-apache
type: ClusterIP
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: php-apache
spec:
  #replicas: 2
  template:
    metadata:
      labels:
        app: php-apache
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
```

busybox.yaml
```
apiVersion: v1
kind: Pod
metadata:
  name: busybox
  namespace: default
spec:
  containers:
  - image: busybox
    command:
      - sleep
      - "3600"
    imagePullPolicy: IfNotPresent
    name: busybox
  restartPolicy: Always
```

php-apache-pod.yaml (ya incluído en el deployment)
```
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
```

### Troubleshooting

#### Caso 1:

El contenedor de metrics-server está en continuo CrashLoopBackOff

#### Diagnóstico

| Command  | Description  |
|---|---|
| kubectl describe pod metrics-server-5cbbc84f8c-lvmj2 -n kube-system | Intente obtener información del error en el pod |
| kubectl get pods --all-namespaces -o wide | Identifique el nodo donde se ha desplegado el pod |
| kubectl logs metrics-server-5cbbc84f8c-lvmj2 -n kube-system | |

#### Caso 2:

El comando: kubectl top node , retorna: error: metrics not available yet

#### Diagnóstico

| Command  | Description  |
|---|---|
| kubectl logs metrics-server-6888449b4-pf49v -n kube-system -c metrics-server | |

### Caso 3:

Validar el funcionamiento correcto del DNS de kubernetes

| Command  | Description  |
|---|---|
| kubectl logs coredns-576cbf47c7-xkh79 -n kube-system | Ver los logs del kube-dns |
| nslookup kubernetes.default.svc.cluster.local 10.96.0.10 | Validar el funcionamiento del kube-dns |
| kubectl get svc -n kube-system -o wide| La IP del servicio kube-dns es la IP del servidor DNS |
| kubectl create -f busybox.yaml | Crear un pod con una shell para pruebas |
| kubectl exec -it busybox -- cat /etc/resolv.conf | Revisar el archivo de configuracion del DNS |
| kubectl exec -it busybox -- nslookup kubernetes.default.svc.cluster.local | Chequear la resolución de nombres desde el pod |
| kubectl edit svc/kube-dns -n kube-system | Ajustar las configuraciones del pod de kube-dns |

### Caso 4:

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

* https://github.com/eBay/Kubernetes/tree/master/docs/user-guide/horizontal-pod-autoscaling
* https://www.josedomingo.org/pledin/2018/11/sercicio-dns-kubernetes
* https://kubernetes.io/docs/reference/kubectl/cheatsheet/
* https://github.com/kelseyhightower/kubernetes-the-hard-way/issues/356
* https://kubernetes.io/docs/tutorials/hello-minikube/
* https://www.mirantis.com/blog/introduction-to-yaml-creating-a-kubernetes-deployment/

* https://medium.com/google-cloud/kubernetes-nodeport-vs-loadbalancer-vs-ingress-when-should-i-use-what-922f010849e0
