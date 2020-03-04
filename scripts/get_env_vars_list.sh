#!/usr/bin/env bash

# Set strict bash mode
set -euo pipefail

TOOLBOX_TOOL_PATH=${TOOLBOX_TOOL_PATH:-}
TOOLBOX_TOOL_DIRS=${TOOLBOX_TOOL_DIRS:-toolbox,.}
CMD=${1:-}

>&2 echo "DEBUG: TOOLBOX_TOOL_PATH: ${TOOLBOX_TOOL_PATH}"
>&2 echo "DEBUG: TOOLBOX_TOOL_DIRS: ${TOOLBOX_TOOL_DIRS}"

if [ ! -f "${TOOLBOX_TOOL_PATH}" ]; then
IFS=" "
for i in $(echo "$TOOLBOX_TOOL_DIRS" | sed "s/,/ /g")
do
  >&2 echo "DEBUG: Check if tool exists at path: ${i}/${CMD}"
  if [[ -f "${i}/${CMD}" ]]; then
    TOOLBOX_TOOL_PATH="${i}/${CMD}"
    break
  fi
done
fi

if [[ -z ${TOOLBOX_TOOL_PATH} ]]; then
  echo "TOOLBOX_TOOL_PATH: NOT FOUND!"
  exit 1
fi

echo "TOOLBOX_TOOL_PATH=\"${TOOLBOX_TOOL_PATH}\""

if [[ -f ${TOOLBOX_TOOL_PATH} ]] && grep -Fq variant "${TOOLBOX_TOOL_PATH}"; then
  yq r -j "${TOOLBOX_TOOL_PATH}" | jq -r '. | recurse(.tasks[]?) | select(.bindParamsFromEnv == true) | .parameters | .[]? | .name' | uniq
fi
