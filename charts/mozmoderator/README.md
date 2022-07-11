mozmoderator
============
A Helm Chart for Mozilla's Moderator application

Current chart version is `0.2.3`



## Chart Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://charts.jetstack.io | cert-manager | 1.4.4 |
| https://charts.bitnami.com/bitnami | mysql | 9.2.0 |

## Chart Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| autoscaling.enabled | bool | `false` |  |
| autoscaling.maxReplicas | int | `5` |  |
| autoscaling.minReplicas | int | `1` |  |
| configMap.allowedHosts | string | `"kube-internal.cluster.local,cluster.local"` |  |
| configMap.siteUrl | string | `"https://moderator.mozilla.org"` |  |
| environment | string | `"stage"` |  |
| externalSecret.create | bool | `false` |  |
| fullnameOverride | string | `"moderator"` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"783633885093.dkr.ecr.us-west-2.amazonaws.com/moderator"` |  |
| imagePullSecrets | list | `[]` |  |
| ingress.annotations."kubernetes.io/ingress.class" | string | `"nginx-moderator"` |  |
| ingress.enabled | bool | `true` |  |
| ingress.hosts[0].backend.serviceName | string | `"moderator"` |  |
| ingress.hosts[0].backend.servicePort | int | `80` |  |
| ingress.hosts[0].host | string | `"moderator.mozilla.org"` |  |
| ingress.hosts[0].paths[0] | string | `"/"` |  |
| mysql.enabled | bool | `true` |  |
| mysql.fullnameOverride | string | `"mysql"` |  |
| mysql.imageTag | string | `"5.7.14"` |  |
| mysql.mysqlDatabase | string | `"moderator"` |  |
| mysql.mysqlPassword | string | `"defaultpassword"` |  |
| mysql.mysqlUser | string | `"moderator"` |  |
| nameOverride | string | `""` |  |
| podSecurityContext | object | `{}` |  |
| replicaCount | int | `1` |  |
| resources.limits.cpu | string | `"500m"` |  |
| resources.limits.memory | string | `"512Mi"` |  |
| resources.requests.cpu | string | `"20m"` |  |
| resources.requests.memory | string | `"64Mi"` |  |
| securityContext | object | `{}` |  |
| service.port | int | `80` |  |
| service.type | string | `"ClusterIP"` |  |
