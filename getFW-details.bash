#!/bin/bash
usage() {
  echo "Usage: $0" 
}
exit_abnormal() {
  usage
  exit 1
}

outFile=/home/iocuser/tfay/versionsFW
master=""
slave_start=""
slave_end=""

while getopts "m:s:e:" options; do
  case "${options}" in
    m)
      master="${OPTARG}"
      ;;
    e)
      slave_end="${OPTARG}"
      ;;
    *)
      exit_abnormal
      ;;
  esac
done

echo "Firmware versions for slaves of master number [$master]" > "$outFile"

for ((i=3 ; i<$slave_end ; i++)); do
  cmd="ethercat -m $master upload -p $i -t string 0x1008 0x0"
  name=$($cmd)
  echo "Slave $i, $name" | tee -a "$outFile"
done

