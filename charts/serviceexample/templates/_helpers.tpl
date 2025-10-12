{{- define "serviceexample.name" -}}
{{- default .Chart.name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "serviceexample.fullname" -}}
{{- $name := default .Chart.name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

