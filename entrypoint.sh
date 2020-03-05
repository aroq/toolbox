#!/usr/bin/env bash

# Set strict bash mode
set -euo pipefail

TOOLBOX_TOOL=${TOOLBOX_TOOL:-${1}}
TOOLBOX_WRAP_TOOL_PATH=${TOOLBOX_WRAP_TOOL_PATH:-}
TOOLBOX_TOOL_DIRS=${TOOLBOX_TOOL_DIRS:-toolbox,.}
# CMD=${1:-}

>&2 echo "DEBUG: TOOLBOX_TOOL: ${TOOLBOX_TOOL}"
>&2 echo "DEBUG: TOOLBOX_TOOL_DIRS: ${TOOLBOX_TOOL_DIRS}"

if [ ! -f "${TOOLBOX_TOOL}" ]; then
IFS=" "
for i in $(echo "$TOOLBOX_TOOL_DIRS" | sed "s/,/ /g")
do
  >&2 echo "DEBUG: Check if tool exists at path: ${i}/${TOOLBOX_TOOL}"
  if [[ -f "${i}/${TOOLBOX_TOOL}" ]]; then
    TOOLBOX_WRAP_TOOL_PATH="${i}/${TOOLBOX_TOOL}"
    break
  fi
done
fi

if [[ -z ${TOOLBOX_WRAP_TOOL_PATH} ]]; then
  echo "TOOLBOX_WRAP_TOOL_PATH: NOT FOUND!"
  exit 1
fi

echo "TOOLBOX_WRAP_TOOL_PATH=\"${TOOLBOX_WRAP_TOOL_PATH}\""

TOOLBOX_WRAP_ENTRYPOINT_MODE=${TOOLBOX_WRAP_ENTRYPOINT_MODE:-run}
>&2 echo "DEBUG: TOOLBOX_WRAP_ENTRYPOINT_MODE: ${TOOLBOX_WRAP_ENTRYPOINT_MODE}"

case "$TOOLBOX_WRAP_ENTRYPOINT_MODE" in
  vars)
    if [[ -f ${TOOLBOX_WRAP_TOOL_PATH} ]] && grep -Fq variant "${TOOLBOX_WRAP_TOOL_PATH}"; then
      yq r -j "${TOOLBOX_WRAP_TOOL_PATH}" | jq -r '. | recurse(.tasks[]?) | select(.bindParamsFromEnv == true) | .parameters | .[]? | .name' | uniq
    fi;;

  run)
    shift
    ${TOOLBOX_WRAP_TOOL_PATH} "$@"
esac

