#!/usr/bin/env bash

if [ "${TOOLBOX_DEBUG}" == "true" ]; then
  set -x
fi

{{ if has .task "env" -}}
{{- range $k, $v := .task.env -}}
{{- if $v }}
export {{ $k }}=${ {{- $k }}:-{{ $v }}}
{{ end -}}
{{ end -}}
export DOCKER_ENV_VARS="-e {{ $s := coll.Keys .task.env }}{{ join $s " -e " }}"
{{ end -}}

export TOOLBOX_TOOL_DOCKER_IMAGE=${TOOLBOX_TOOL_DOCKER_IMAGE:-{{ .task.image }}}


eval ".toolbox/core/run {{ .task.tools_dir }}/{{ .task.cmd }} $*"

