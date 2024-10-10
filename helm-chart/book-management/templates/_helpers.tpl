{{/*
Expand the name of the chart.
*/}}
{{- define "book-management.fullname" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
