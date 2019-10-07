#!/usr/bin/env bash

{{ if has .task "env" -}}
{{- range $k, $v := .task.env -}}
export {{ $k }}=${ {{- $k }}:-{{ $v }}}
{{ end -}}
{{- end -}}
export TOOLBOX_TOOL_DOCKER_IMAGE=${TOOLBOX_TOOL_DOCKER_IMAGE:-{{ .task.image }}}

eval ".toolbox/core/run {{ .task.tools_dir }}/{{ .task.cmd }} $*"
