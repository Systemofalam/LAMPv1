#!/usr/bin/env bash
set -euo pipefail

mkdir -p rib updates

COLLECTOR="route-views2"
BASE_URL="https://archive.routeviews.org/${COLLECTOR}/bgpdata"
MONTH="$(date -u +%Y.%m)"        # ex : 2025.11
RIB_URL="${BASE_URL}/${MONTH}/RIBS/"
UPD_URL="${BASE_URL}/${MONTH}/UPDATES/"

echo "RIB_URL    = ${RIB_URL}"
echo "UPDATES_URL= ${UPD_URL}"

LATEST_RIB=$(
  curl -s "${RIB_URL}" \
  | grep -o 'rib\.[0-9]\{8\}\.[0-9]\{4\}\.bz2' \
  | sort \
  | tail -n1
)

if [[ -z "${LATEST_RIB}" ]]; then
  echo "Impossible to find a rib on ${RIB_URL}"
  exit 1
fi

echo "Dernier RIB      : ${LATEST_RIB}"

LATEST_UPD=$(
  curl -s "${UPD_URL}" \
  | grep -o 'updates\.[0-9]\{8\}\.[0-9]\{4\}\.bz2' \
  | sort \
  | tail -n1
)

if [[ -z "${LATEST_UPD}" ]]; then
  echo "Impossible to find updates on ${UPD_URL}"
  exit 1
fi

echo "Dernier UPDATES  : ${LATEST_UPD}"

cd rib
if [[ ! -f "${LATEST_RIB}" ]]; then
  wget "${RIB_URL}${LATEST_RIB}"
fi
cd ..

cd updates
if [[ ! -f "${LATEST_UPD}" ]]; then
  wget "${UPD_URL}${LATEST_UPD}"
fi
cd ..


RIB_IN="rib/${LATEST_RIB}"
RIB_OUT="rib/${LATEST_RIB%.bz2}.dump"

echo "Conversion RIB → ${RIB_OUT}"
bgpdump -M "${RIB_IN}" > "${RIB_OUT}"

UPD_IN="updates/${LATEST_UPD}"
UPD_OUT="updates/${LATEST_UPD%.bz2}.dump"

echo "Conversion UPDATES → ${UPD_OUT}"
bgpdump -M "${UPD_IN}" > "${UPD_OUT}"

echo "Done."
echo "  - RIB binaire      : ${RIB_IN}"
echo "  - RIB lisible      : ${RIB_OUT}"
echo "  - UPDATES binaire  : ${UPD_IN}"
echo "  - UPDATES lisible  : ${UPD_OUT}"

