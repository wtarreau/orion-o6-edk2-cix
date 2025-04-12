# edk2-cix

Modified Radxa edk2 image for cix release allowing to adjust OPP.

## Build

1. `git clone --recurse-submodules https://github.com/wtarreau/orion-o6-edk2-cix.git`

    Note: it can be a bit long because EDK2 has a long dependency chain. The size of
    downloaded data amounts to about 2.3 GB.

2. `cd orion-o6-edk2-cix/src`
3. `mkdir -p tools/gcc`
4. `curl -L https://developer.arm.com/-/media/Files/downloads/gnu-a/10.2-2020.11/binrel/gcc-arm-10.2-2020.11-x86_64-aarch64-none-elf.tar.xz | tar -JxC tools/gcc/`

   Note: the compiler requires about 500 MB of extra space. It may be installed anywhere else with a symlink from
   `gcc/gcc-arm-10.2-2020.11-x86_64-aarch64-none-elf` to the installation path.
5. The first time only, need to build ACPI tools:
   ```
   cd tools/acpica
   make -j$(nproc)
   cd -
   ```
5. You may want to edit some OPP:
   ```
   vi edk2-platforms/Platform/Radxa/Orion/O6/pm_config/opp_config_custom.h
   ```
6. Prepare for building. If a previous build was run and only the OPP have changed since, a faster rebuild can be performed by only removing `cix*.bin` from `Build/O6/RELEASE_GCC5`:
   ```
   rm -f Build/O6/RELEASE_GCC5/cix*bin
   ```

   Otherwise better remove the whole `Build` directory or issue a classical `make clean`.

7. Start the build. The RAM frequency (half the DDR rating) may be forced in `MEM_CFG_MEMFREQ`, e.g. below for DDR5-6400, otherwise if not set, it defaults to 3000 MHz (DDR5-6000):
   ```
   time make -j$(nproc) MEM_CFG_MEMFREQ=3200
   ```
8. The resulting image is available in `Build/O6/RELEASE_GCC5/cix_flash_all.bin`. Let's just copy it to the orion-o6 board:

   `scp Build/O6/RELEASE_GCC5/cix_flash_all.bin user@orion-o6:`
9. From the orion-o6 machine, log in as `root` to copy the new image to the EFI partition where it can be flashed:
   ```
   mount /dev/nvme0n1p1 /mnt/
   cp ~user/cix_flash_all.bin /mnt/orion-o6/
   umount /mnt/
   ```
10. reboot into the BIOS and select "Boot to UEFI shell" in the Boot menu
    Alternatively, if you failed to enter the BIOS, you can call the shell from
    the boot loader by pressing 'c' to enter command line, then:
    ```
    grub> chainloader /orion-o6/Shell.efi
    grub> boot
    ```
11. From the shell:
    ```
    Shell> fs0:
    FS0:\> cd orion-o6
    FS0:\orion-o6\> setup.nsh
    ```
    Press ENTER to start flashing. Once done, press "q" to quit, then perform a cold reboot:
    ```
    FS0:\orion-o6\> reset -c
    ```
12. wait for the reboot (always a bit long after a flashing sequence). Then press ESC to enter the BIOS when prompted to do so, and enable ACPI.
13. once booted, check that the frequencies are properly reported according to your settings, for example on a kernel booting in device-tree mode (frequencies here are 3.0, 2.7, 2x2.6 GHz):
    ```
    root@orion-o6:~# lscpu -e
    CPU NODE SOCKET CORE ONLINE    MAXMHZ   MINMHZ       MHZ
      0    0      0    0    yes 2999.9919 799.8020  799.8020        ## big1, core0
      1    0      0    0    yes 1799.9980 799.4820  799.4820        ## lit,  core0
      2    0      0    1    yes 1799.9980 799.4820  799.4820        ## lit,  core1
      3    0      0    2    yes 1799.9980 799.4820  799.4820        ## lit,  core2
      4    0      0    3    yes 1799.9980 799.4820  799.4820        ## lit,  core3
      5    0      0    0    yes 2599.9939 799.8850  799.8850        ## med0, core0
      6    0      0    1    yes 2599.9939 799.8850  799.8850        ## med0, core1
      7    0      0    2    yes 2599.9939 799.8850 1800.1080        ## med1, core0
      8    0      0    3    yes 2599.9939 799.8850 1800.1080        ## med1, core1
      9    0      0    4    yes 2699.9951 799.8900  799.8900        ## big0, core0
     10    0      0    5    yes 2699.9951 799.8900  799.8900        ## big0, core1
     11    0      0    6    yes 2999.9919 799.8020  799.8020        ## big1, core1
    ```
    or a kernel booted in ACPI mode:
    ```
    CPU NODE SOCKET CORE L1d:L1i:L2:L3 ONLINE    MAXMHZ   MINMHZ       MHZ
      0    0      0    0 0:0:0:0          yes 3000.0000 800.0000 1819.3350
      1    0      0    0 1:1:0            yes 1800.0000 799.0000 1531.1200
      2    0      0    1 2:2:0            yes 1800.0000 799.0000 1531.1200
      3    0      0    2 3:3:0            yes 1800.0000 799.0000 1531.1200
      4    0      0    3 4:4:0            yes 1800.0000 799.0000 1531.1200
      5    0      0    0 5:5:0:0          yes 2600.0000 800.0000 1146.1100
      6    0      0    1 6:6:0:0          yes 2600.0000 800.0000 1146.1100
      7    0      0    2 7:7:0:0          yes 2600.0000 800.0000 1620.9690
      8    0      0    3 8:8:0:0          yes 2600.0000 800.0000 1620.9690
      9    0      0    4 9:9:0:0          yes 2700.0000 800.0000 1530.2930
     10    0      0    5 10:10:0:0        yes 2700.0000 800.0000 1530.2930
     11    0      0    6 11:11:0:0        yes 3000.0000 800.0000 1819.3350
    ```
14. in order to verify the frequencies match what is reported:
    ```
    $ git clone https://github.com/wtarreau/mhz
    $ cd mhz
    $ make
    $ for i in {0..11}; do echo $i: $(taskset -c $i ./mhz -c 1 0 500000);done
    0: 2998.950
    1: 1793.979
    2: 1794.398
    3: 1794.559
    4: 1793.465
    5: 2599.158
    6: 2599.158
    7: 2599.023
    8: 2599.158
    9: 2699.201
    10: 2699.055
    11: 2999.040
    ```
