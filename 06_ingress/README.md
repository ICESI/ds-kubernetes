### Ingress

```
kubectl apply -f https://raw.githubusercontent.com/containous/traefik/v1.7/examples/k8s/traefik-rbac.yaml
kubectl apply -f https://raw.githubusercontent.com/containous/traefik/v1.7/examples/k8s/traefik-ds.yaml
kubectl apply -f ingress.yaml
kubectl apply -f apple.yaml
kubectl apply -f banana.yaml
kubectl get pods -n kube-system
kubectl describe ingress example-ingress
```

ingress.yaml
```
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: example-ingress
  #annotations:
    #traefik.ingress.kubernetes.io/affinity: "true"
    #kubernetes.io/ingress.class: "nginx"
    #kubernetes.io/ingress.global-static-ip-name: 192.168.56.2
    #ingress.kubernetes.io/rewrite-target: /
    #ingress.appscode.com/type: NodePort
spec:
  rules:
  - host: fruits.192.168.56.101.nip.io
    http:
      paths:
        - path: /apple
          backend:
            serviceName: apple-service
            servicePort: 5678
        - path: /banana
          backend:
            serviceName: banana-service
            servicePort: 5678
```

apple.yaml
```
kind: Pod
apiVersion: v1
metadata:
  name: apple-app
  labels:
    app: apple
spec:
  containers:
    - name: apple-app
      image: hashicorp/http-echo
      args:
        - "-text=apple"
---
kind: Service
apiVersion: v1
metadata:
  name: apple-service
spec:
  selector:
    app: apple
  ports:
    - port: 5678 # Default port for image
```

banana.yaml
```
kind: Pod
apiVersion: v1
metadata:
  name: banana-app
  labels:
    app: banana
spec:
  containers:
    - name: banana-app
      image: hashicorp/http-echo
      args:
        - "-text=banana"
---
kind: Service
apiVersion: v1
metadata:
  name: banana-service
spec:
  selector:
    app: banana
  ports:
    - port: 5678 # Default port for image
```

Pruebas del Ingress
```
vagrant@node0:/vagrant/ingress$ kubectl get svc
NAME             TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
apple-service    ClusterIP      10.97.202.187   <none>        5678/TCP         4h51m
banana-service   ClusterIP      10.108.105.61   <none>        5678/TCP         4h50m
kubernetes       ClusterIP      10.96.0.1       <none>        443/TCP          9d
```

```
$ curl 10.97.202.187:5678/apple
$ curl -kL http://fruits.192.168.56.101.nip.io/apple
apple

$ curl 10.108.105.61:5678/banana
$ curl -kL http://fruits.192.168.56.101.nip.io/banana
banana

$ curl -kL http://fruits.192.168.56.101.nip.io//notfound
default backend - 404
```

Probando desde el anfitrión
```
/etc/hosts
fruits.192.168.56.101.nip.io www.fruits.com
```

```
curl www.fruits.com/apple
curl www.fruits.com/banana
```

Eliminar el Ingress
```
kubectl delete ingress example-ingress
```

### References

* https://www.josedomingo.org/pledin/2018/12/kubernetes-ingress/
* https://docs.traefik.io/user-guide/kubernetes/

* https://matthewpalmer.net/kubernetes-app-developer/articles/kubernetes-ingress-guide-nginx-example.html
* https://cloud.google.com/kubernetes-engine/docs/tutorials/http-balancer
* https://gardener.cloud/050-tutorials/content/howto/service-access/

* https://medium.com/google-cloud/kubernetes-nodeport-vs-loadbalancer-vs-ingress-when-should-i-use-what-922f010849e0
