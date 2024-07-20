{{/*
Get a password for local login. If no password is provided, a 24-character alpha-numerical password will be generated.
*/}}
{{- define "foreman.localLoginPassword" -}}
{{ .Values.config.auth.local.password | default (randAlphaNum 24) | quote }}
{{- end -}}

{{/*
Generates a valid resource name using a possible nameOverride or the chart name.
*/}}
{{- define "foreman.name" -}}
    {{- default .Chart.Name .Values.global.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Generates a valid chart name which contains the name and the version of the chart.
*/}}
{{- define "foreman.chartName" -}}
    {{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Returns the name of foreman's config map considering a give existing configmap.
*/}}
{{- define "foreman.configMapName" -}}
  {{- if .Values.config.existingConfigMap -}}
    {{ .Values.config.existingConfigMap }}
  {{- else -}}
    {{ include "foreman.name" . }}-config
  {{- end -}}
{{- end -}}

{{/*
Returns the name of foreman's secret considering a give existing secret.
*/}}
{{- define "foreman.secretName" -}}
  {{- if .Values.config.existingSecret -}}
    {{ .Values.config.existingSecret }}
  {{- else -}}
    {{ include "foreman.name" . }}-secret
  {{- end -}}
{{- end -}}

{{/*
Returns the proper foreman image name.
*/}}
{{- define "foreman.image" -}}
    {{- if .Values.image.digest -}}
        {{- printf "%s@%s" .Values.image.repository .Values.image.digest }}
    {{- else -}}
        {{- printf "%s:%s" .Values.image.repository .Values.image.tag }}
    {{- end -}}
{{- end -}}

{{/*
Returns the proper Docker Image Registry Secret Names evaluating values as templates.
*/}}
{{- define "foreman.pullSecrets" }}
    {{- $secrets := .Values.image.pullSecrets }}
    {{- if $secrets }}
imagePullSecrets:
        {{- range $secrets }}
  - name: {{ . }}
        {{- end }}
    {{- end }}
{{- end }}

{{/*
Renders a value that contains a template.
*/}}
{{- define "foreman.renderTplValues" -}}
    {{- if typeIs "string" .value }}
        {{- tpl .value .context }}
    {{- else }}
        {{- tpl (.value | toYaml) .context }}
    {{- end }}
{{- end -}}

{{/*
Kubernetes standard labels
see: https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/
*/}}
{{- define "foreman.labels" -}}
helm.sh/chart: {{ include "foreman.chartName" . }}
app.kubernetes.io/name: {{ include "foreman.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ default .Values.image.tag .Chart.AppVersion }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

