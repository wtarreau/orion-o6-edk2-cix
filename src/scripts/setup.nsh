#!/usr/bin/env -S echo "This script is for UEFI Shell only:"

@echo -off

echo "========================================================================"
echo "                  You are about to update the BIOS."
echo "      Please make sure the power stays on during the operation."
echo " "
echo "                       Do you want to continue?"
echo "========================================================================"
pause

echo "========================================================================"
echo "                           Updating BIOS..."
echo "========================================================================"
echo " "

FlashUpdate.efi -f cix_flash.bin

# Currently reset will stuck at boot, so just exit the script
goto EOF

echo "========================================================================"
echo "                        BIOS Update completed!"
echo "                     The system is about to reset."
echo "      You can quit now if you are not ready to reset the device."
echo " "
echo "                       Do you want to continue?"
echo "========================================================================"
pause

reset

:EOF
