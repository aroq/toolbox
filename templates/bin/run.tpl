#!/usr/bin/env bash

eval ".toolbox/core/run {{ .task.name }} {{ .task.path }} {{ .task.cmd }} {{ .task.image }} $*"
