{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "fluentd-papertrail.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "fluentd-papertrail.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "fluentd-papertrail.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "fluentd-papertrail.labels" -}}
helm.sh/chart: {{ include "fluentd-papertrail.chart" . }}
k8s-app: {{ include "fluentd-papertrail.fullname" . }}
version: v1
kubernetes.io/cluster-service: "true"
{{ include "fluentd-papertrail.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "fluentd-papertrail.selectorLabels" -}}
app.kubernetes.io/name: {{ include "fluentd-papertrail.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "fluentd-papertrail.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "fluentd-papertrail.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Name of Kubernetes secrets to use
*/}}
{{- define "fluentd-papertrail.secrets" -}}
{{- if .Values.secrets -}}
    {{ default (include "fluentd-papertrail.fullname" .) .Values.secrets.name }}
{{- else -}}
    {{ default "default" .Values.secrets.name }}
{{- end -}}
{{- end -}}

{{/*
Name of the configmap
*/}}
{{- define "fluentd-papertrail.configMap" -}}
{{ include "fluentd-papertrail.fullname" . }}-config
{{- end -}}

{{/*
Define cluster name
*/}}
{{- define "fluentd-papertrail.clusterName" -}}
{{- if .Values.clusterName -}}
    {{ default (include "fluentd-papertrail.fullname" .) .Values.clusterName }}
{{- else -}}
    {{ default "fluentd" .Values.clusterName }}
{{- end -}}
{{- end -}}
