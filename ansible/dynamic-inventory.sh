#!/bin/bash
if [ "$1" == "--list" ] ; then
  if [ -e $inventory_temp ]; then
          echo "[all]" > inventory_temp
  else
          touch inventory_temp
          echo "[all]" > inventory_temp
  fi
  yc compute instance list | grep RUNNING | awk '{print$4}' > inventory_host_temp
  yc compute instance list | grep RUNNING | awk '{print$10}' > inventory_ip_temp
  pr -mts' ansible_host=' inventory_host_temp inventory_ip_temp > pre-inventory_temp
  sort -k 1 pre-inventory_temp >> sorted_inventory_temp
  echo "[manager]" >> inventory_temp
  cat sorted_inventory_temp | grep node | grep node0 >> inventory_temp
  echo "[workers]" >> inventory_temp
  cat sorted_inventory_temp | grep node | grep -v node0 >> inventory_temp
  echo "[monitoring]" >> inventory_temp
  cat sorted_inventory_temp | grep monitoring >> inventory_temp
  ansible-inventory --list -i inventory_temp 
  rm inventory_host_temp inventory_ip_temp inventory_temp pre-inventory_temp sorted_inventory_temp

elif [ "$1" == "--host" ]; then
          echo '{"_meta": {"hostvars": {}}}'
  else
          echo "{ }"
fi
