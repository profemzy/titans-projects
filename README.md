# titans-projects

Simple Deployment Automation 

````
k -n kube-system get secrets sealed-secrets-key5m7n6 -o json | jq .data'."tls.crt"' -r | base64 -d
````

````
kubeseal -o yaml --cert sealedSecret.crt < db-secret.yaml > db-sealed-secret.yaml 
````

### Please note that i put most of the deployments and services in one namespace so I can share a single ingress and load balancer just so simplify things, this is not advisable in actual work environment.
