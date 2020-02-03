#!/usr/bin/env bash

{{ if has .task "env" -}}
{{- range $k, $v := .task.env -}}
{{- if $v }}
export {{ $k }}=${ {{- $k }}:-{{ $v }}}
{{ end -}}
{{ end -}}
export TOOLBOX_DOCKER_ENV_VARS="-e {{ $s := coll.Keys .task.env }}{{ join $s " -e " }}"
{{ end -}}

export TOOLBOX_TOOL_DIRS="toolbox,{{ $l := reverse .task.tool_dirs }}{{ join $l "," }}"

{{ if has .task "config_context_prefix" -}}
if [ -z "${VARIANT_CONFIG_CONTEXT-}" ]; then
export VARIANT_CONFIG_CONTEXT="{{ $l := reverse .task.config_context_prefix }}{{ join $l "," }}"
else
  export VARIANT_CONFIG_CONTEXT="${VARIANT_CONFIG_CONTEXT},{{ $l := reverse .task.config_context_prefix }}{{ join $l "," }}"
fi
{{ end -}}

{{ if has .task "config_dir_prefix" -}}
if [ -z "${VARIANT_CONFIG_DIR-}" ]; then
export VARIANT_CONFIG_DIR="{{ $l := reverse .task.config_dir_prefix }}{{ join $l "," }}"
else
  export VARIANT_CONFIG_DIR="${VARIANT_CONFIG_DIR},{{ $l := reverse .task.config_dir_prefix }}{{ join $l "," }}"
fi
{{ end -}}

export TOOLBOX_TOOL_DOCKER_IMAGE=${TOOLBOX_TOOL_DOCKER_IMAGE:-{{ .task.image }}}


eval "toolbox/.toolbox/deps/toolwrap/run tools/{{ .task.cmd }} $*"
