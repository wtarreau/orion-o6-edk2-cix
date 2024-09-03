#!/usr/bin/env -S echo "This script is for UEFI Shell only:"

@echo -off

echo "You are about to update the BIOS."
echo "Please make sure the power stays on during the operation."
echo "Do you want to continue?"
pause

echo "***********************************************"
echo "Updating BIOS..."
echo "***********************************************"

FlashUpdate.efi -f cix_flash.bin
