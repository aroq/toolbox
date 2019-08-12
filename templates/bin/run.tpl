#!/usr/bin/env bash

export VARIANT=1

eval ".toolbox/core/run {{ .task.cmd }} {{ .task.path }} {{ .task.cmd }} {{ .task.image }} $*"
