### K8S Ejemplos

### Ejemplo básico kubernetes

Install kubectl
```
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
kubectl cluster-info
```

Install minikube
```
curl -Lo minikube https://storage.googleapis.com/minikube/releases/v0.22.3/minikube-linux-amd64 && chmod +x minikube && sudo mv minikube /usr/local/bin/
minikube start
```

Ver los contextos (~/.kube/config)
```
kubectl config view
```

Usar el contexto minikube
```
kubectl config use-context minikube
```

Verificar que kubectl se comunica con el cluster
```
kubectl cluster-info
```

Cree el siguiente ejemplo server.py
```
import logging
from logging.handlers import RotatingFileHandler

from flask import Flask

app = Flask(__name__)

@app.route("/")
def hello():
    app.logger.info('info')
    return "Hello World!"

if __name__ == "__main__":
    log_formatter = logging.Formatter( "%(asctime)s | %(pathname)s:%(lineno)d | %(funcName)s | %(levelname)s | %(message)s ")
    file_handler = RotatingFileHandler('flask.log', maxBytes=10000, backupCount=1)
    file_handler.setLevel(logging.INFO)
    file_handler.setFormatter(log_formatter)
    app.logger.addHandler(file_handler)
    console_handler = logging.StreamHandler()
    console_handler.setFormatter(log_formatter)
    app.logger.addHandler(console_handler)
    app.run(host='0.0.0.0',port=8080,debug='False')
```

Dockerfile
```

```


Para construir el contenedor dentro de la VM de minikube
```
eval $(minikube docker-env)
```

Digite el siguiente comando para contruir un contenedor con la aplicación
```
docker build -t hello-flask:v1.0.0 .
```

Crear un deployment
```
kubectl run hello-flask --image=hello-flask:v1.0.0 --port=8080
```
ó

```
kubectl create -f hello_flask_deployment.yaml
```

hello_flask_deployment.yaml
```
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: hello-flask
#  labels:
#    app: hello-flask
spec:
#  selector:
#    matchLabels:
#      app: hello-flask
  template:
    metadata:
      labels:
        app: hello-flask
    spec:
      containers:
        - name: flask-container
          image: hello-flask:v1.0.0
          resources:
            requests:
              #memory: "64Mi"
              cpu: "100m"
            limits:
              #memory: "64Mi"
              cpu: "200m"
          ports:
            - containerPort: 8080
```

hello_flask_pod.yaml (ya incluido en el deployment.yaml)
```
apiVersion: v1
kind: Pod
metadata:
  name: hello-flask
  labels:
    app: flask-app
spec:
  containers:
    - name: flask-container
      image: hello-flask:v1.0.0
      resources:
        requests:
          memory: "64Mi"
          cpu: "100m"
        limits:
          memory: "64Mi"
          cpu: "200m"
      ports:
        - containerPort: 8080
```

Ver el deployment
```
kubectl get deployments
```

Ver el Pod
```
kubectl get pods
```

Ver los eventos del cluster
```
kubectl get events
```

Ver la configuración de kubectl
```
kubectl config view
```

Crear un servicio
```
kubectl expose deployment hello-flask --type=NodePort
```

ó

```
kubectl expose deployment hello-flask --type=ClusterIP --port=8080
```

ó

Si esta desplegando en cloud (Azure, Google Cloud, AWS) use:
```
--type=LoadBalancer
```

Ver los servicios creados
```
kubectl get services
```

Nota: Tambien puede definir una especificación para el servicio en el hello_flask_deployment.yaml

El parámetro indica que se quiere exponer el servicio por fuera del cluster. Es posible acceder al servicio
a través del comando
```
minikube service hello-flask
```

Para observar los logs de la aplicación use el identificador del Pod
```
kubectl logs hello-flask-1975222887-713n9
```

Actualizar la aplicación

Realizar algun cambio a la aplicación
```
import logging
from logging.handlers import RotatingFileHandler

from flask import Flask

app = Flask(__name__)

@app.route("/")
def hello():
    app.logger.info('info')
    return "Hello Kubernetes"

if __name__ == "__main__":
    log_formatter = logging.Formatter( "%(asctime)s | %(pathname)s:%(lineno)d | %(funcName)s | %(levelname)s | %(message)s ")
    file_handler = RotatingFileHandler('flask.log', maxBytes=10000, backupCount=1)
    file_handler.setLevel(logging.INFO)
    file_handler.setFormatter(log_formatter)
    app.logger.addHandler(file_handler)
    console_handler = logging.StreamHandler()
    console_handler.setFormatter(log_formatter)
    app.logger.addHandler(console_handler)
    app.run(host='0.0.0.0',port=8080,debug='False')
```

Construir una nueva versión
```
docker build -t hello-flask:v2.0.0 .
```

Actualizar la imagen del deployment
```
kubectl set image deployment/hello-flask hello-flask=hello-flask:v2.0.0
```

Acceda el servicio actualizado a través del comando
```
minikube service hello-flask
```

Limpiar los recursos del cluster
```
kubectl delete service hello-flask
kubectl delete deployment hello-flask
```

Para detener minikube
```
minikube stop
```

MacOSX
```
minikube start --vm-driver=xhyve
```

### Pruebas en un cluster real

```
NAME          TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
hello-flask   NodePort    10.96.118.135   <none>        8080:31042/TCP   6s
hello-node    ClusterIP   10.100.208.42   <none>        8080/TCP         11m
```

Si esta desplegando en un cluster real, prueba la aplicación asi dependiendo del tipo de servicio:

```
curl 192.168.56.101:31042
curl 10.100.208.42:8080
```

Recuerde que en el caso de ClusterIP el puerto expuesto en el servicio debe coincidir con el expuesto por la aplicación

### Commandos generales

| Command  | Description  |
|---|---|
| kubectl proxy --port=8080 | Proporciona acceso a la API de Kubernetes, http://localhost:8080/api/v1/proxy/namespaces/<NAMESPACE>/services/<SERVICE-NAME>:<PORT-NAME>/ |
| kubectl get namespaces |  |
| kubectl --namespace=\<insert-namespace-name-her\> run nginx --image=nginx |  |
| kubectl --namespace=\<insert-namespace-name-here\> get pods |  |
| kubectl config set-context $(kubectl config current-context) --namespace=\<insert-namespace-name-here\> | |
| `kubectl config view \| grep namespace:` | |
| | |
| kubectl api-resources --namespaced=true | |
| kubectl api-resources --namespaced=false | |
| | |
| kubectl get pods -l environment=production,tier=frontend | |
| kubectl get pods -l 'environment in (production),tier in (frontend)' | |
| kubectl get pods -l 'environment in (production, qa)' | |
| kubectl get pods -l 'environment,environment notin (frontend) | |
| | |
| kubectl get nodes | |
| kubectl label nodes \<node-name\> \<label-key\>=\<label-value\> | |
| kubectl label nodes kubernetes-foo-node-1.c.a-robinson.internal disktype=ssd | |
| kubectl get nodes --show-labels | |
| | |
| kubectl create -f https://k8s.io/examples/pods/pod-nginx.yaml | |
| | |
| kubectl get pods --field-selector status.phase=Running | |
| kubectl get services --field-selector metadata.namespace!=default | |
| kubectl get pods --field-selector=status.phase!=Running,spec.restartPolicy=Always | |
| kubectl get statefulsets,services --field-selector metadata.namespace!=default | |
| | |
| kubectl run nginx --image nginx | |
| kubectl create deployment nginx --image nginx | |
| kubectl create -f nginx.yaml | |
| kubectl delete -f nginx.yaml -f redis.yaml | |
| kubectl replace -f nginx.yaml | |
| kubectl apply -f configs/ | |
| kubectl apply -R -f configs/ | |
| | |
| kubectl get \<kind\>/\<name\> -o yaml --export \> \<kind\>_\<name\>.yaml | |
| Remove status field | |
| kubectl replace -f \<kind\>_\<name\>.yaml | |
| | |
| kubectl get deployments --all-namespaces | Remove a pod permanently |
| kubectl delete -n NAMESPACE deployment DEPLOYMENT | |
| kubectl delete pods podname --grace-period=0 --force | |
| | |
| kubectl describe nodes \| grep -i taint | Find node taints |
| kubectl describe nodes your-node-name \| grep -i taint | |

### References
* https://labs.play-with-k8s.com
* https://kubernetes.io/docs/concepts/cluster-administration/networking/#how-to-achieve-this  
* https://kubernetes.io/docs/concepts/overview/object-management-kubectl/declarative-config/

* https://kubernetes.io/docs/user-guide/walkthrough/
* https://github.com/kubernetes/minikube/releases  
* https://kubernetes.io/docs/tutorials/stateless-application/hello-minikube/  
* https://damyanon.net/post/flask-series-logging/  
* https://github.com/kubernetes/community/blob/master/contributors/design-proposals/README.md

* https://kubernetes.io/docs/tasks/inject-data-application/define-environment-variable-container/
* https://github.com/kubernetes/website/tree/master/content/en/docs/user-guide/walkthrough
* https://medium.com/google-cloud/understanding-kubernetes-networking-pods-7117dd28727

* https://www.digitalocean.com/community/tutorials/an-introduction-to-kubernetes
* https://www.cncf.io/the-childrens-illustrated-guide-to-kubernetes/
* https://learning.oreilly.com/videos/kubernetes-course-from/9781789806823/9781789806823-video4_2

* https://stackoverflow.com/questions/40686151/kubernetes-pod-gets-recreated-when-deleted
