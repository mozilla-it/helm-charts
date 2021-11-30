# helm-charts

[![Lint & Test Charts](https://github.com/mozilla-it/helm-charts/actions/workflows/ci.yaml/badge.svg)](https://github.com/mozilla-it/helm-charts/actions/workflows/ci.yaml)

This repository contains a collection of Helm charts curated by Mozilla's Service Engineering team

## Adding more charts

## Compiling and publishing charts

## Referencing images in ECR
Charts referencing Docker Images stored in an ECR repo under `itsre-apps` subaccount can't be pulled without credentials.   

GitHub Actions is configured to get Pull credentials for repositories inside that account.  

In order to instruct the testing suite to use those credentials you have to create a folder named `ci` inside your chart, a file `test-values.yaml` inside it with the next content:
```
imagePullSecrets:
  - name: ecr-registry
```
Check [here](https://github.com/mozilla-it/helm-charts/pull/39/commits/1a0fbfed5810a6d6875ca0172adac5065ee03b74#diff-245000fef8fab28267cb8040d6a3d7f6) for an example.

## Installing Helm Charts from this repository
This repository is serving Helm Charts using the webserver provided by Github pages. In order to install Helm charts in your cluster add this repository to your helm repository list running `helm repo add mozilla-helm-charts https://mozilla-it.github.io/helm-charts/`

## Debug a Chart deployment
This section describes how to verify that your chart is installed correctly as well as what to do if it is not.

### View current deployed chart
The first step should be to check if a chart was successfully installed and which version it is deployed.
Running `helm list` in your target namespace shows the current deployed charts. Example:
```
helm list                                                  
NAME                         	NAMESPACE 	REVISION	UPDATED                                	STATUS  	CHART                      	APP VERSION
voice-prod                   	voice-prod	5       	2020-04-15 14:11:52.540100678 +0000 UTC	deployed	mozilla-common-voice-0.1.12	           
voice-prod-ingress-controller	voice-prod	1       	2020-04-09 13:17:23.087215157 +0000 UTC	deployed	nginx-ingress-1.31.0       	0.29.0  
```
Here we can see that namespace `voice-prod` has 2 charts deployed. For this example we are only interested in the chart `voice-prod`. As you can see currently version 0.1.12 of the chart is deployed, however my configuration specified that 0.1.13 should be there.

### View Helm Release
The next step should be to check what versions of the HelmRelease are present in the cluster. Run `kubectl get helmrelease` in the target namespace. In this example we will find why our chart could not be installed:
```
kubectl get helmrelease
NAME                 RELEASE                         STATUS     MESSAGE                                                                                                                                                                                        AGE
ingress-controller   voice-prod-ingress-controller   deployed   Helm release sync succeeded                                                                                                                                                                    7d19h
voice                voice-prod                      deployed   failed to upgrade chart for release [voice-prod]: YAML parse error on mozilla-common-voice/templates/configmap.yaml: error converting YAML to JSON: yaml: line 17: did not find expected key   7d19h
```
Here we can clearly see an error, we are missing a key in our configmap. Running `kubectl describe helmrelease voice-prod` will give you even more information.

### Using logs for debugging
#### Flux
The same information found out above can be found in the logs of the 2 components involved: flux and helm. First of all we will check the logs of Flux to see what is in there.
Running `kubectl logs -l=app=flux -n fluxcd` you will get the logs of Flux where we can make sure that it correctly detected the change in the Chart and will try to apply it.
```
kubectl logs -l=app=flux -n fluxcd
ts=2020-04-17T09:24:41.796293402Z caller=loop.go:133 component=sync-loop event=refreshed url=ssh://git@github.com/mozilla-it/voice-infra branch=main HEAD=26626653ecca80f3d43f6e42aa3376af15755622
```
Nothing wrong here, moving on and checking helm-operator logs

#### Helm
helm-operator logs are also a good resource of information when debugging. Check them running `kubectl logs -f -l=app=helm-operator -n fluxcd`. Here we will see the same error that we saw when describing the HelmRelease:
```
kubectl logs -f -l=app=helm-operator -n fluxcd                                                                   :(
ts=2020-04-17T09:24:37.559875402Z caller=operator.go:307 component=operator info="enqueuing release" resource=voice-prod:helmrelease/voice
ts=2020-04-17T09:24:37.647535928Z caller=release.go:353 component=release release=voice-prod targetNamespace=voice-prod resource=voice-prod:helmrelease/voice helmVersion=v3 info="release has not yet been processed" action=upgrade
ts=2020-04-17T09:24:37.663182157Z caller=helm.go:69 component=helm version=v3 info="preparing upgrade for voice-prod" targetNamespace=voice-prod release=voice-prod
ts=2020-04-17T09:24:37.790261829Z caller=release.go:216 component=release release=voice-prod targetNamespace=voice-prod resource=voice-prod:helmrelease/voice helmVersion=v3 error="Helm release failed" revision=0.1.13 err="failed to upgrade chart for release [voice-prod]: YAML parse error on mozilla-common-voice/templates/configmap.yaml: error converting YAML to JSON: yaml: line 17: did not find expected key"
```

### Fixing the problem
We now know where the problem is, a missing or bad value which makes not possible rendering the configmap. Here one of the options you have is to go an verify if you are missing some value, inc ase you are not able to find it, other option is to force localy the render of the chart. This will allow us to reproduce the error locally and fix it faster.
In our case we will try rendering the mozilla-common-voice chart:
```
helm template -f mozilla-common-voice/values.yaml mozilla-common-voice/                               :(
Error: YAML parse error on mozilla-common-voice/templates/configmap.yaml: error converting YAML to JSON: yaml: line 17: did not find expected key
```
Yet the same error again. But know we can modify easily the chart until we find the culprit line.

### Verifying the fix
After finding and fixing the bug, we want to make sure that the new chart is now installed. You can verify it by listing the version of the chart installed.
```
helm list
NAME                         	NAMESPACE 	REVISION	UPDATED                                	STATUS  	CHART                      	APP VERSION
voice-prod                   	voice-prod	6       	2020-04-17 09:39:39.195640231 +0000 UTC	deployed	mozilla-common-voice-0.1.13	           
voice-prod-ingress-controller	voice-prod	1       	2020-04-09 13:17:23.087215157 +0000 UTC	deployed	nginx-ingress-1.31.0       	0.29.0     
```
Here we can verify that we currently have the version 0.1.13 of the chart installed.
