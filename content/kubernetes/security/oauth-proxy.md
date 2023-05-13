---
title: "Oauth Proxy"
date: 2023-05-13T02:22:14+02:00
description: "Secure applications behind OAuth proxy"
draft: false
---

## Scenario

You want to run a webapp, which contains private information, say a monitoring app. But you don't have any username/password mechanism to prevent it from public access. Rather than adding authentication to that app, we can **offload** the authentication to other applications. One of the most simple and secure project is [OAuth2 proxy](https://github.com/oauth2-proxy/oauth2-proxy)

## Solution

1. Create a kubernetes cluster

    ```bash
    # We don't need treafik ingress
    k3d cluster create notraefik --k3s-arg="--disable=traefik@server:0"
    ```

2. Install [nginx ingress controller](https://kubernetes.github.io/ingress-nginx/deploy/#quick-start)
    
    ```bash
    helm upgrade --install ingress-nginx ingress-nginx \
      --repo https://kubernetes.github.io/ingress-nginx \
      --namespace ingress-nginx --create-namespace
    ```

3. Install [Coroot](https://coroot.com) Monitoring stack

    ```bash
    helm repo add coroot https://coroot.github.io/helm-charts
    helm repo update
    helm install --namespace coroot --create-namespace coroot coroot/coroot
    ```

4. Apply the following yaml to install OAuth proxy. Don't forget to replace the `< REPLACE ME ... >` values.

    ```yaml
    apiVersion: networking.k8s.io/v1
    kind: Ingress
    metadata:
      annotations:
        nginx.ingress.kubernetes.io/auth-url: "https://$host/oauth2/auth"
        nginx.ingress.kubernetes.io/auth-signin: "https://$host/oauth2/start?rd=$escaped_request_uri"
      name: observability-coroot
      namespace: coroot
    spec:
      ingressClassName: nginx
      rules:
      - host: <REPLACE ME DOMAIN NAME>
        http:
          paths:
          - backend:
              service:
                name: coroot
                port:
                  number: 8080
            path: /
            pathType: Prefix
      # tls:
      # - hosts:
      #   - <REPLACE ME DOMAIN NAME> 
      #   secretName: openreplay-ssl

    ```

    ```yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      labels:
        k8s-app: oauth2-proxy
      name: oauth2-proxy
      namespace: kube-system
    spec:
      replicas: 1
      selector:
        matchLabels:
          k8s-app: oauth2-proxy
      template:
        metadata:
          labels:
            k8s-app: oauth2-proxy
        spec:
          containers:
          - args:
            # !!! Never use "" for values
            - --provider=github
            - --email-domain=*
            - --upstream=file:///dev/null
            - --http-address=0.0.0.0:4180
            # - --github-user=rjshrjndrn,someoneelse
            # - --github-org=openreplay
            env:
            # Follow these steps to create the GitHub OauthApplication
            # https://kubernetes.github.io/ingress-nginx/examples/auth/oauth-external-auth/#prepare
            - name: OAUTH2_PROXY_CLIENT_ID
              value: <REPLACE ME OAUTH CLIENT ID>
            - name: OAUTH2_PROXY_CLIENT_SECRET
              value: <REPLACE ME OAUTH CLIENT SECRET>
            # docker run -ti --rm python:3-alpine python -c 'import secrets,base64; print(base64.b64encode(base64.b64encode(secrets.token_bytes(16))));'
            - name: OAUTH2_PROXY_COOKIE_SECRET
              value: <REPLACE ME OUTPUT OF ABOVE COMMAND>
            image: quay.io/oauth2-proxy/oauth2-proxy:v7.2.0
            imagePullPolicy: IfNotPresent
            name: oauth2-proxy
            ports:
            - containerPort: 4180
              protocol: TCP

    ---
    apiVersion: v1
    kind: Service
    metadata:
      labels:
        k8s-app: oauth2-proxy
      name: oauth2-proxy
      namespace: kube-system
    spec:
      ports:
      - name: http
        port: 4180
        protocol: TCP
        targetPort: 4180
      selector:
        k8s-app: oauth2-proxy
    ---
    apiVersion: networking.k8s.io/v1
    kind: Ingress
    metadata:
      name: oauth2-proxy
      namespace: kube-system
    spec:
      ingressClassName: nginx
      rules:
      - host: <REPLACE ME DOMAIN NAME>
        http:
          paths:
          - path: /oauth2
            pathType: Prefix
            backend:
              service:
                name: oauth2-proxy
                port:
                  number: 4180
      #tls:
      #- hosts:
      #  -  <REPLACE ME DOMAIN NAME>
      #  secretName: openreplay-ssl
    ```

5. Now you can access the domain name, and it should ask for login with GitHub.
