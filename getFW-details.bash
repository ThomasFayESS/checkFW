#!/bin/bash
usage() {
  echo "Usage: $0" 
}

exit_abnormal() {
  usage
  exit 1
}

outFile=/home/iocuser/tfay/checkFW/versionsFW
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

cmdNames="ethercat -m 2 slaves"
stringNames=$($cmdNames)
regHW='0x1009 0x0'
regFW='0x100a 0x0'

echo "$cmdSlaveNames"
while IFS= read -r line; do
  name=${line#*+  }
  slaveID=${line%0:*}
  if [[ $name = "EL9*" ]]; then
    echo "$slaveID: $name No SDOs available for this module."
  else
    cmdHW="ethercat -m $master upload -p $slaveID -t string $regHW"
    ID_HW=$($cmdHW)
    cmdFW="ethercat -m $master upload -p $slaveID -t string $regFW"
    ID_SW=$($cmdFW)
    echo "$slaveID: $name ID-HW: $ID_HW ID-SW: $ID_SW"
  fi
done <<< "$stringNames"

exit 1
outFile="$outFile"_master-$master
echo "Firmware versions for slaves of master number [$master]" > "$outFile"

nameReg="0x1008 0x0"
hwReg="0x1009 0x0"
fwReg="0x100a 0x0"
for ((i=0 ; i<="$slave_end" ; i++)); do
  echo "Slave $i..."
  cmd="ethercat -m $master upload -p $i -t string"
  cmdName="$cmd $nameReg"
  cmdHW="$cmd $hwReg"
  cmdFW="$cmd $fwReg"
  name=$($cmdName)
  version_HW=$($cmdHW)
  version_FW=$($cmdFW)
  echo "Slave $i, $name HW:$version_HW FW:$version_FW" >> $outFile
done

