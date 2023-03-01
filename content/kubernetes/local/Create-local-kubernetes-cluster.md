---
title: "Create Local Kubernetes Cluster In a Minute"
date: 2020-11-29T13:01:10+05:30
draft: false
description: "Create reproduceable local Kubernetes cluster with k3d"
---

Testing our applications or prototyping some new [operators](https://kubernetes.io/docs/concepts/extend-kubernetes/operator/) needs fresh cluster more often, which will be a daunting task, If you have created a kubernetes cluster in bare metal. But now, thanks to community, there are awesome products which can be used to create kubernetes clusters, let it be single node or multi node.
2 of the major projects are
1. k3d(docker implementation of k3s, a minimal kubernetes distribution by Rancher)
2. kinD(Kubernetes in Docker, which is used for kubernetes sig testing)

We'll be using k3d in our usecase, as that is more faster and includes some batteries like
- [local path provisioner](https://github.com/rancher/local-path-provisioner) for PV and PVCs
- [traefik](https://traefik.io/) for ingress controller

## Code

Create a local kubernetes cluster
- start docker 
  ```bash
  sudo systemctl start docker.service
  ```
- Creating kubernets cluster 
  ```bash
  k3d cluster create my-first-kube-cluster
  ```
- Accssing cluster. 
  
  *Note: By default, k3d will merge the kubeconfig with your ~/.kube/config and make it as default context*
  ```bash
  kubectl cluster-info
  ```
- Deploy sample application 
  
  ```bash
  kubectl apply -f - << EOF
  apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: hello-world
    namespace: default
  spec:
    replicas: 1
    selector:
      matchLabels:
        app: hello-world
    template:
      metadata:
        labels:
          app: hello-world
      spec:
        containers:
        - name: hello-world
          image: rancher/hello-world
          resources:
            requests:
              cpu: 100m
              memory: 200Mi
          ports:
          - containerPort: 80
  ---
  apiVersion: v1
  kind: Service
  metadata:
    name: hello-world
    namespace: default
  spec:
    ports:
    - port: 80
      targetPort: 80
    selector:
      app: hello-world
  ---
  apiVersion: extensions/v1beta1
  kind: Ingress
  metadata:
    name: hello-world
    namespace: default
  spec:
    rules:
    - http:
        paths:
        - path: /
          backend:
            serviceName: hello-world
            servicePort: 80
  EOF
  ```
- Accessing application, using ingress ip.
  Copy the ip address from below command, and paste that in browser. You are now accessing the application running in kubernetes using an ingress
  
  ```bash
  # Check the ingressip
  kubectl get ingress
  ```
  *Note: This method will only work on linux machines. In Mac and Windows, docker is running in it's own vm, which will be isolated from the host machine. In such cases, while creating the K3d cluster, [expose the port](https://k3d.io/usage/guides/exposing_services/).*
  
### If you don't want ingress, or want to try out your own ingresses, you can create cluster with

```bash
k3d cluster create \
  --k3s-server-arg --no-deploy \
  --k3s-server-arg traefik \
```
- `--k3s-server-arg` will pass the suffix to k3s as an argument.
- here we're saying `--no-deploy traefik` which is the ingress
