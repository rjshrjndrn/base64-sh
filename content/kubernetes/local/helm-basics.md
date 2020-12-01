---
title: "Helm Basics"
date: 2020-11-28T09:07:55+05:30
draft: true
---

## Helm, the package manager for Kubernetes.

Where ever we hear about application deployment in kubernetes, we hear about an addon, [Helm](https://helm.sh/). 
So what is this Helm? Why so much hype? And how to use that?

## Introduction

You can deploy application in kubernetes using `yaml`. For example, deployment, service, hpa. The list goes on and on.
But when you're sharing the template, for example, with one of your friend, he/she might need to customize the service type from LoadBalancer to NodePort.
Or change the name from "Bob's awsome app" to "Alice's awsome app". This task will be little daunting, if you have 100's or even 10's of services.

**Helm is a templating format/engine for the kubernetes application, so that you can share the generic structure of the application to any one in a customizable manner.**


## Code

1. Deploying Hello-World application using kubernetes yaml.

    First let's create an nginx deployment, which will create nginx deployment and a service type LoadBalancer

    *Note: if you don't have kubernetes cluster, use k3d to create one. Refer [here](https://base64.sh/kubernetes/local/creating-local-kubernetes-cluster/).*

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
          - name: name
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
      type: ClusterIP
      ports:
      - port: 80
        targetPort: 8
      selector:
        app: hello-world
    EOF
    ```
2. Deploy Hello-World application using helm.

    ```bash
    # Creating helm chart
    helm create hello-world
    ```
    ```bash
    # Installing helm chart
    helm install my-hello-world --namespace default ./hello-world
    ```
    But when you inspect the deployment, you'll see the container image is `nginx`, rather than `rancher/hello-world`
    ```bash
    kubectl describe deploment Hello-World
    ```
    
    This is because when you did `helm create hello-world`, Helm created a template with some boilerplate code.

3.  Structure of a helm chart.
    ```
    ❯ tree hello-world
    hello-world
    ├── charts              # directory to put sub-charts
    ├── Chart.yaml          # Information about the chart
    ├── templates           # Folder containes the yaml's which will be templated
    │   ├── deployment.yaml
    │   ├── _helpers.tpl    # helm's helper function for advanced templating
    │   ├── hpa.yaml
    │   ├── ingress.yaml
    │   ├── NOTES.txt       # Information about the appiction usage
    │   ├── serviceaccount.yaml
    │   ├── service.yaml
    │   └── tests           # If you have any test cases for your application
    │       └── test-connection.yaml
    └── values.yaml         # File which we'll use to override the defaults

    3 directories, 10 files
    ```
    
4.  Customizing Helm chart for our application needs
    ```bash
    # Customizing the boilerplate
    vim values.yaml
    ```
    Edit the following sections in values.yaml
    
    *Note: Yaml syntax is space sensitive. So make sure your spaces are proper.*
    ```yaml
    # Changing the image from nginx to `rancher/hello-world`
    image:
      repository: rancher/hello-world
    ```
    *Note: use `:wq!` for save and quit from vim*
5. Upgrading our application with helm.    
    ```bash
    helm upgrade my-hello-world --namespace default
    ```
    After the upgrade completes, 
    ```bash
    kubectl describe deploment Hello-World
    ```
    Now you can see the `rancher/hello-world` image, not the default nginx image

*Now, if you want, you can change the `service.type` from `ClusterIP` to `LoadBalancer` to expose the application, externally.*

Happy Helming!!!
