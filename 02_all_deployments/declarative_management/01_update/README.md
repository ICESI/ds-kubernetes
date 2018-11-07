| Command  | Description  |
|---|---|
| kubectl apply -f https://k8s.io/examples/application/simple_deployment.yaml | |
| kubectl get -f https://k8s.io/examples/application/simple_deployment.yaml -o yaml | view the live configuration |
| kubectl scale deployment/nginx-deployment --replicas=2 | |
| kubectl get -f https://k8s.io/examples/application/simple_deployment.yaml -o yaml | |
| kubectl apply -f https://k8s.io/examples/application/update_deployment.yaml | |
| kubectl get -f https://k8s.io/examples/application/simple_deployment.yaml -o yaml | |
| | |
| kubectl delete -f <filename> | |
| kubectl apply -f <directory/> --prune -l <labels> | |
