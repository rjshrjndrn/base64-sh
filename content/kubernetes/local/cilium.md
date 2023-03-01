---
title: "Install cilium in k3d"
date: 2022-12-12T05:39:16+01:00
description: "eBPF networking with cilium"
draft: false
---

## Run cilium in k3d

### Sample k3d config file

```Yaml
apiVersion: k3d.io/v1alpha2 # this will change in the future as we make everything more stable
kind: Simple # internally, we also have a Cluster config, which is not yet available externally
name: mycluster # name that you want to give to your cluster (will still be prefixed with `k3d-`)
servers: 1 # same as `--servers 1`
kubeAPI: # same as `--api-port myhost.my.domain:6445` (where the name would resolve to 127.0.0.1)
  hostIP: "127.0.0.1" # where the Kubernetes API will be listening on
  hostPort: "26443" # where the Kubernetes API listening port will be mapped to on your host system
image: rancher/k3s:v1.22.8-k3s1 # same as `--image rancher/k3s:v1.20.4-k3s1`
network: my-kube-net # same as `--network my-custom-net`
options:
  k3d: # k3d runtime settings
    wait: true # wait for cluster to be usable before returining; same as `--wait` (default: true)
    timeout: "60s" # wait timeout before aborting; same as `--timeout 60s`
    disableLoadbalancer: false # same as `--no-lb`
    disableImageVolume: false # same as `--no-image-volume`
    disableRollback: false # same as `--no-Rollback`
    disableHostIPInjection: false # same as `--no-hostip`
  k3s: # options passed on to K3s itself
    extraServerArgs: # additional arguments passed to the `k3s server` command; same as `--k3s-server-arg`
      - --no-deploy=traefik
      - --flannel-backend=none
      - --disable-network-policy
    extraAgentArgs: [] # addditional arguments passed to the `k3s agent` command; same as `--k3s-agent-arg`
  kubeconfig:
    updateDefaultKubeconfig: false # add new cluster to your default Kubeconfig; same as `--kubeconfig-update-default` (default: true)
    switchCurrentContext: false # also set current-context to the new cluster's context; same as `--kubeconfig-switch-context` (default: true)
```

### Create k3d cluster

```bash
k3d cluster create cilium --config ~/Documents/projects/k3d/config.yaml 
```

### Update mount points

```bash
docker exec -it k3d-cilium-server-0 sh

mount bpffs -t bpf /sys/fs/bpf
mount --make-shared /sys/fs/bpf
mkdir -p /run/cilium/cgroupv2
mount -t cgroup2 none /run/cilium/cgroupv2
mount --make-shared /run/cilium/cgroupv2/
exit

```

## Install cilum

Download cilium cli from https://github.com/cilium/cilium-cli/releases

```bash
cilium install
cilium hubble enable --ui
```
