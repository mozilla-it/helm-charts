# refractr chart [![Build Status](https://travis-ci.com/mozilla-it/refractr.svg?branch=main)](https://travis-ci.com/mozilla-it/refractr)
Helm chart for [refractr](https://github.com/mozilla-it/refractr/), containerized HTTP redirects and rewrites service.

[![Build Status](https://travis-ci.com/mozilla-it/refractr.svg?branch=main)](https://travis-ci.com/mozilla-it/refractr)

# Refractr at Mozilla
Refractr at Mozilla runs in our itse-apps cluster and is installed via a HelmRelease in the it-sre-apps github repo.

# Using this Helm chart on your own

## First install cert-manager if not already installed:

### Add the cert-manager CRD
```
kubectl apply --validate=false \
    -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.13/deploy/manifests/00-crds.yaml
```

### Add the Jetstack Helm repository
```
helm repo add jetstack https://charts.jetstack.io
```

### Install the cert-manager helm chart
```
helm install --name my-release --namespace cert-manager jetstack/cert-manager
```

## Create namespace and RBAC required for refractr to generate a Ingress configuration for all domains
The yaml will look like this:
```
---
apiVersion: v1
kind: Namespace
metadata:
  name: refractr
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: refractr
  namespace: refractr
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: Role
metadata:
  name: refractr
  namespace: refractr-stage
rules:
  - apiGroups:
      - ""
    resources:
      - configmaps
      - pods
      - secrets
      - namespaces
    verbs:
      - get
  - apiGroups:
      - ""
    resources:
      - configmaps
    resourceNames:
      # Defaults to "<election-id>-<ingress-class>"
      # Here: "<ingress-controller-leader>-<nginx>"
      # This has to be adapted if you change either parameter
      # when launching the nginx-ingress-controller.
      - "ingress-controller-leader-nginx"
      - "ingress-controller-leader-refractr"
    verbs:
      - get
      - update
  - apiGroups:
      - ""
    resources:
      - configmaps
    verbs:
      - create
  - apiGroups:
      - ""
    resources:
      - endpoints
    verbs:
      - get
  - apiGroups:
      - extensions
    resources:
      - ingresses
    verbs:
      - get
      - update
      - create
      - list
      - patch
      - delete
      - watch

---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: RoleBinding
metadata:
  name: refractr
  namespace: refractr
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: refractr
subjects:
  - kind: ServiceAccount
    name: refractr
    namespace: refractr
```


## Install the refractr helm chart
helm repo add mozilla-helm-charts https://mozilla-it.github.io/helm-charts/
helm install -n refractr mozilla-helm-charts/refractr refractr --set issuer=stage --set image.repository=<mydockerrepo> --set image.tag=<myimagetag>

