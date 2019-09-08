#!/usr/bin/env bash

{{ if has .task "env" -}}
{{- range $k, $v := .task.env -}}
export {{ $k }}={{ $v }}
{{ end -}}
{{- end }}

eval ".toolbox/core/run {{ .task.tools_dir }}/{{ .task.cmd }} {{ .task.image }} $*"
