---
title: "Increase Disk Size of Stateful Set"
date: 2022-02-17T17:23:19+01:00
draft: true
description: "Increase Disk Size of Stateful Set"
---

## Scenario

You've one database stateful set, and an unexpected user activity created lot of data, and you're about to fill the storage. Obviously, you have to increase the storage. But unfortunately, kubernetes doesn't allow you to increase the storage size in STS(stateful set)

## Solution

1. We've to check the storageClass which we used allow volume expansion. Means, dynamically expand the storage.

```bash
# Get your storage class name
kg pvc <pvc name> -n default -o jsonpath='{.spec.storageClassName}'

# if VolumeExpansion is supported, you'll get the value as true
kubectl get -n default -o jsonpath='{.allowVolumeExpansion}' sc <SC-NAME>

# If the above command gave false, enable volume expansion.
kubectl patch -p '{"allowVolumeExpansion": true}' sc <SC-NAME>
```

2. Increase the storage size of pvc

```bash
# First scale the sts to 0
kubectl scale statefulset -n default <statefulset name> --replicas=0

# Second increase the pvc size ( if you have multiple pvcs, like postgres-0 postgres-1 ..., do it for all of them )

NEW_SIZE=100Gi
kubectl patch pvc -p '{"spec": {"resources": {"requests": {"storage": "'$NEW_SIZE'"}}}}' -n default <pvc name>

# Note: you won't see the changed volume immediately. So don't worry. Proceed to following steps.
```

3. Delete the Statefulset

```bash
# Create the backup of current statefulset yaml
kubectl get sts -n default <statefulset name> -o yaml > sts.yaml

# Edit the statefulset yaml(sts.yaml), and update the `storage: <NEW_SIZE>`

# Delete the old statefulset
kubectl delete sts -n default <statefulset name> --cascade=orphan
```

4. Recreate the sts

```bash
kubectl apply -f sts.yaml
kubectl scale sts -n default <statefulset name> --replicas=1
```

5. Validate the changes

```bash
# You should see the updated storage.
kubectl get pvc -n default
```
