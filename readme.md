# Pull config to use on kubectl
```bash
lxc file pull k0s-001/var/lib/k0s/pki/admin.conf lxd-k0s.conf
```

# Replace with container ip
```bash
sed -i "s/localhost:6443/`terraform output -raw k0s-container-ip`:6443/g" lxd-k0s.conf
```

# Export the config for use on kubectl
```bash
export KUBECONFIG=lxd-k0s.conf
kubectl get pods
```

# Test k8s
```bash
 k0s kubectl apply -f https://k8s.io/examples/application/deployment.yaml
 ```