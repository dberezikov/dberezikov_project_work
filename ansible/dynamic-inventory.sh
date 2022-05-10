#!/bin/bash

if [ "$1" == "--list" ] ; then
  if [ -e $inventory_temp ]; then
          echo "[all]" > inventory_temp
  else
          touch inventory_temp
          echo "[all]" > inventory_temp
  fi
  yc compute instance list | grep RUNNING | awk '{print$10}' | grep -v '^|' | sed -E '/^$/d' >> inventory_temp
  ansible-inventory --list -i inventory_temp
  rm inventory_temp
elif [ "$1" == "--host" ]; then
          echo '{"_meta": {"hostvars": {}}}'
  else
          echo "{ }"
fi
