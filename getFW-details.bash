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

outFile="$outFile"_master-$master
echo "Firmware versions for slaves of master number [$master]" > "$outFile"

cmdNames="ethercat -m $master slaves"
stringNames=$($cmdNames)
regHW='0x1009 0x0'
regFW='0x100a 0x0'

echo "$cmdSlaveNames"
while IFS= read -r line; do
  name=${line#*+  }
  slaveID=${line%0:*}
  if [[ $name == *"EL9"* ]] || [[ $name == *"EK1"* ]] \
  || [[ $name == *"EL2624"* ]] || [[ $name == *"EL1809"* ]] \
  || [[ $name == *"EL3202-0010"* ]]; then
    echo "$slaveID: $name: No SDOs available for this module." >> $outFile
  else
    cmdHW="ethercat -m $master upload -p $slaveID -t string $regHW"
    ID_HW=$($cmdHW)
    cmdFW="ethercat -m $master upload -p $slaveID -t string $regFW"
    ID_SW=$($cmdFW)
    echo "$slaveID: $name ID-HW: $ID_HW ID-SW: $ID_SW" >> $outFile
  fi
done <<< "$stringNames"
