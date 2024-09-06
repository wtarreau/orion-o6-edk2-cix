#!/usr/bin/env -S echo "This script is for UEFI Shell only:"

@echo -off

echo "************************************************************************"
echo "                       Radxa BIOS Update Utility"
echo "************************************************************************"
echo " "
echo "You are about to update the BIOS."
echo "Please make sure the power stays on during the operation."
echo " "
pause

echo "************************************************************************"
echo "                            Updating BIOS..."
echo "************************************************************************"
echo " "

FlashUpdate.efi -f cix_flash.bin

echo " "
echo "************************************************************************"
echo "                         BIOS Update completed!"
echo "************************************************************************"
echo "The system is about to shut down."
echo "Please disconnect the power after shutting down."
echo "Without the power reset, the device will not be bootable."
echo " "
pause

reset -s

:EOF
