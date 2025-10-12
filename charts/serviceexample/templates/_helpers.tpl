{{/*
Expand the name of the chart.
*/}}
{{- define "serviceexample.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a fully qualified name for resources.
*/}}
{{- define "serviceexample.fullname" -}}
{{- $name := include "serviceexample.name" . -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

