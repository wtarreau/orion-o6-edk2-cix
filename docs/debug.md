# Debug

## Serial connection

The following UARTs can be used to debug EDK2 on Radxa Orion O1:

* UART1: EC
* UART2: AP
* UART3: Debug
* UART4: PM
* UART5: SE

UART2 is the default management console for EDK2 and the operationg system.

UART3 is only available when EDK2 is build as DEBUG image.

All UARTs other than UART1 use 115200 baud. EC UART can be viewed with the following command:

```bash
picocom -b 460800 --imap lfcrlf /dev/ttyX
```

In general, the log output order after power is connected is as follow:

```
EC ---Power On---> SE ---> AP ---> Debug
```

If you enable `devenv`, then you can run `edk2-console` to launch above 4 UART consoles at once.
Please first create a local `devenv.local.nix` based on `devenv.local.nix.example` to define the local UART devices before using this command.

## Installation

Once build completes, you can find the complete set of artifacts under `debian/edk2-cix/usr/share/edk2/`.

Copy them to a USB disk formatted in FAT file system, and connect them to the target board.

You will need to enter UEFI Shell to run the script to update the BIOS. There are 2 ways to achieve that:

### Via UEFI Setup

Press `Escape` key when prompted on the console. Then enter `Boot Manager` menu and select `UEFI Shell`.

### Via `Ventoy`

[`Ventoy`](https://www.ventoy.net/) is a popular ISO multi-boot tool. It also supports booting EFI applications and ARM64 architecture.

First, use `Ventoy` to create a bootable USB disk. Make sure you select GPT partition table in the option.

You will then reformat the first partition with FAT file system, as the default file system exFAT is not supported by EDK2.

You can then copy the EDK2 build artifacts as usual. When you boot the system and missed the `Escape` prmopt, if there is no other bootable media, EDK2 should boot into `Ventoy`.

```admonish caution
If screen is connected, Ventoy will boot into graphical mode. Under this mode you will have no output on UART2, but you can still control the menu with it.

You can enable [`Force Text Mode`](https://github.com/ventoy/Ventoy/issues/2983#issuecomment-2367411817) under the display menu to allow output on UART2.
```

Inside `Ventoy` UI you should have `Shell.efi` listed as an option if you copied everything from the `debian/edk2-cix.install` folder. Run it to enter UEFI Shell.


```admonish caution
If you built for multiple EDK2 variants you may have multiple `Shell.efi` listed in `Ventoy`. They are generally compatible with different platforms, but when in doubt, only use the one come with your target platform.
```

---

Once inside the UEFI Shell, you should first be greeted by a list of available storage devices and their physical paths.

If you only have the USB disk connected, it should be listed as `fs0`.

You can rescan the storage device with `map -r` command, which will reprint the available devices as well.

You can run BIOS flash script from UEFI Shell now. It uses Windows convention, so an example command would be:

```cmd
fs0:\radxa\orion-o1\setup.nsh
```

The first backslash is not mandatory:

```cmd
fs0:radxa\orion-o1\setup.nsh
```

There is limited auto completion in the UEFI Shell when pressing `Tab` key.

Running this command will flash your BIOS. Follow its prompt to complete the process.
