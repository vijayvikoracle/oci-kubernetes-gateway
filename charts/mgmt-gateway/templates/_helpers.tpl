# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

# tpl render function
{{- define "common.tplvalues.render" -}}
  {{- if typeIs "string" .value }}
    {{- tpl .value .context }}
  {{- else }}
    {{- tpl (.value | toYaml) .context }}
  {{- end }}
{{- end -}}

# Prefix for all resources created using this chart.
{{- define "mgmt-gateway.resourceNamePrefix" -}}
  {{- if .Values.resourceNamePrefix -}}
    {{ include "common.tplvalues.render" ( dict "value" .Values.resourceNamePrefix "context" .) | trunc 63 | trimSuffix "-" }}
  {{- else -}}
    {{- "oci-onm" -}}
  {{- end -}}
{{- end -}}

# namespace
{{- define "mgmt-gateway.namespace" -}}
  {{- if .Values.namespace -}}
    {{ include "common.tplvalues.render" ( dict "value" .Values.namespace "context" .) }}
  {{- else -}}
    {{- "oci-onm" -}}
  {{- end -}}
{{- end -}}

#serviceAccount
{{- define "mgmt-gateway.serviceAccount" -}}
  {{ include "common.tplvalues.render" ( dict "value" .Values.serviceAccount "context" .) }}
{{- end -}}

#kubernetesClusterName
{{- define "mgmt-gateway.kubernetesClusterName" -}}
  {{- if .Values.kubernetesCluster.name -}}
    {{ include "common.tplvalues.render" ( dict "value" .Values.kubernetesCluster.name "context" .) }}
  {{- else -}}
    {{- "UNDEFINED" -}}
  {{- end -}}
{{- end -}}
#mgmtgateway name
{{- define "mgmt-gateway.gatewayFullname" -}}
{{- .Release.Name | printf "%s-gateway" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

