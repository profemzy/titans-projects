# titans-projects

Simple Deployment Automation 

````
k -n kube-system get secrets sealed-secrets-key5m7n6 -o json | jq .data'."tls.crt"' -r | base64 -d
````

````
kubeseal -o yaml --cert sealedSecret.crt < db-secret.yaml > db-sealed-secret.yaml 
````
