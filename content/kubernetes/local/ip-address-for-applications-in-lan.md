---
title: "LAN wide accessible IP addresses for applications deployed in local Kubernetes cluster"
date: 2020-11-27T23:28:39+05:30
draft: false
description: "Create Local LoadBalancers with LAN wide access in Kubernetes."
---

## Create an application in kubernetes cluster which is accessible from entire lan

If you're running a local kubernetes cluster like [k3d](https://github.com/rancher/k3d), then most probably you won't be able to access the application which is running inside the kubernetes cluster in your local network (unless you're running behind the ingress with each application separate path).

In this tutorial, we'll make a single node kubernetes cluster and install one nginx web server which will be accessible from the entire LAN.

### Code

1. Create kuernetes cluster
   ```bash
   k3d cluster create --k3s-server-arg --no-deploy --k3s-server-arg traefik --network host --k3s-server-arg --no-deploy --k3s-server-arg servicelb  --api-port ${2:-16433} --no-hostip
   ```
2. Wait for your cluster to be up 
   ```bash
   kubectl cluster-info
   ```
3. Install [metallb](https://metallb.universe.tf/). 

   Metallb is a serivce, which will talk to your local router, to publish the ip address from your given address pool(more on this on the config part). Metallb can use layer2/BGP protocols to publish the ip address. 
   
   Long story short, you'll get an ip address in your LAN, like you've another device connected.

   Installing metallb in kubernetes so that it can provide ip addresses 
   ```bash
   kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.5/manifests/namespace.yaml
   kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.5/manifests/metallb.yaml
   # On first install only
   kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"
   ```
   Configure ip range 
   
   Note: This should be a valid ip range from your LAN. For example, if your network subnet is 192.168.0.0/24 (ie, 192.168.0.1-255), reserve the last 20 ips(192.168.0.200-220). 
   ```bash
   kubectl apply -f - << EOF
   apiVersion: v1
   kind: ConfigMap
   metadata:
     namespace: metallb-system
     name: config
   data:
     config: |
       address-pools:
       - name: default
         protocol: layer2
         addresses:
         - 192.168.1.200-192.168.1.220
   EOF
   ```
4. Deploying a sample application
   ```bash
   kubectl apply -f - << EOF
   apiVersion: apps/v1
   kind: Deployment
   metadata:
     name: nginx-metallb
     namespace: default
   spec:
     replicas: 1
     selector:
       matchLabels:
         app: nginx-metallb
     template:
       metadata:
         labels:
           app: nginx-metallb
       spec:
         containers:
         - name: name
           image: nginx
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
     name: nginx-metallb
     namespace: default
   spec:
     type: LoadBalancer
     ports:
     - port: 80
       targetPort: 80
     selector:
       app: nginx-metallb
   EOF
   ```
5. Access the application ip address. Now you can use this ip address from entire lan to access the application.
   ```bash
   kubectl get svc nginx --template="{{range .status.loadBalancer.ingress}}{{.ip}}{{end}}"
   ```
