#!/bin/sh

#echo "begin watchdog"  >  /home/mirte/test.txt

echo "wifi watchdog serviec opnieuw gestart" > /dev/kmsg

sub="xradio"

dmesg --follow | while read -r line; do
  if `echo $line | grep -q "xradio WSM-ERR: CMD timeout!"`; then
     echo "CRASH! REBOOT!" > /dev/kmsg
     echo $line >> /home/mirte/test.txt
#     reboot -f now
     echo b > /proc/sysrq-trigger
  fi
done
