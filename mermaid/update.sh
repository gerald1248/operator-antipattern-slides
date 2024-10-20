#!/bin/bash
# Allowed choices are default, forest, dark, neutral.
TOOL=mmdc
THEME=default
SCALE=3

which "${TOOL}" >/dev/null || (echo "${TOOL} not available" && exit 1)

for FILE in *.mmd; do
  echo "Processing ${FILE}"
  PNG=$(sed 's/mmd/png/' <<<"${FILE}")
  SVG=$(sed 's/mmd/svg/' <<<"${FILE}")
  "${TOOL}" -p puppeteer-config.json --width 1600 --theme "${THEME}" -b transparent -s ${SCALE} -i "${FILE}" -o "${PNG}" >/dev/null
  "${TOOL}" -p puppeteer-config.json --theme "${THEME}" -b transparent -i "${FILE}" -o "${SVG}" >/dev/null
done
