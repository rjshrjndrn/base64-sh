---
title: "Jenkins in kubernetes"
date: 2022-02-04T10:21:41+05:30
draft: true
description: "Run Jenkins in kubernetes"
---

Running Jenkins is trivial task, But configuring it.. Well that can be lil daunting. But as every cloud project now evolved to.. Yay.. Kubernetes!!!

## Running Jenkins in Kubernetes

1. Create a kubernetes cluster. If you want to use k3d, follow this [guide](https://blog.rjsh.me/kubernetes/local/create-local-kubernetes-cluster/#code).
2. Install Helm. Refer this [guide](https://blog.rjsh.me/kubernetes/local/helm-basics/#code) Download Helm section.
3. Installing Jenkins in kubernetes 
   ```bash
   helm repo add jenkins https://charts.jenkins.io
   helm repo update
   helm install jenkins/jenkins
   ```
4. Accessing Jenkins 
   ```bash
   # Get jenkins password
   kubectl exec -it svc/jenkins -c jenkins -- /bin/cat /run/secrets/chart-admin-password && echo
   # Accessing Jenkins
   kubectl port-forward svc/jenkins 8080:8080
   ```
   Goto your browser, open `http://localhost:8080` 🎉🎉🎉🎉

You have Jenkins running in Kubernetes now. This is just a simple installation. I'll post another article on customizing jenkins using code.
