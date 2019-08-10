#!/usr/bin/env bash

eval ".toolbox/core/run {{ .task.cmd }} {{ .task.path }} {{ .task.cmd }} {{ .task.image }} $*"
