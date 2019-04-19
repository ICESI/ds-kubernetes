### K8S Ejemplos

| Command  | Description  |
|---|---|
| kubectl get namespaces |  |
| kubectl --namespace=<insert-namespace-name-here> run nginx --image=nginx |  |
| kubectl --namespace=<insert-namespace-name-here> get pods |  |
| kubectl config set-context $(kubectl config current-context) --namespace=<insert-namespace-name-here> | |
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
| kubectl label nodes <node-name> <label-key>=<label-value> | |
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
| kubectl get <kind>/<name> -o yaml --export > <kind>_<name>.yaml | |
| Remove status field | |
| kubectl replace -f <kind>_<name>.yaml | |
| | |

## References
* https://labs.play-with-k8s.com
* https://kubernetes.io/docs/concepts/cluster-administration/networking/#how-to-achieve-this  
* https://kubernetes.io/docs/concepts/overview/object-management-kubectl/declarative-config/
