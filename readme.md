# Kubernetes on LXD
Uses terraform for create a LXD container, with ubuntu20.04 and k0S for the k8s

# Uses
 * Ubuntu 20.04 (host machine)
 * Terraform 1.0.1 (host machine)
 * LXD 4.15 (host machine)
 * k0s v1.21.2+k0s.0 (guest machine)

## Pull config to use on kubectl
```bash
lxc file pull k0s-001/var/lib/k0s/pki/admin.conf lxd-k0s.conf
```

### Replace with container ip
```bash
sed -i "s/localhost:6443/`terraform output -raw k0s-container-ip`:6443/g" lxd-k0s.conf
```

### Export the config for use on kubectl
```bash
export KUBECONFIG=lxd-k0s.conf
kubectl get pods
```

### Test k8s
```bash
 k0s kubectl apply -f https://k8s.io/examples/application/deployment.yaml
 ```