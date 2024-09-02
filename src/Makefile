UEFI_PROJECT ?= Merak
UEFI_TARGET ?= RELEASE
BOARD ?= evb

.PHONY: all
all: build

PACKAGE_TOOL ?= edk2-non-osi/Platform/CIX/Sky1/PackageTool
.PHONY: build
build: cix_flash.bin

cix_flash.bin: $(PACKAGE_TOOL)/Firmwares/bootloader2.img
	cd "$(PACKAGE_TOOL)" && \
	"./cix_package_tool" -c "./cix_spi_flash_config.json" \
		-o "$(shell realpath "$@")"

$(PACKAGE_TOOL)/Firmwares/bootloader2.img: Build/$(UEFI_PROJECT)/$(UEFI_TARGET)_GCC5/FV/SKY1_BL33_UEFI.fd
	cd "$(PACKAGE_TOOL)" && \
	PATH_PACKAGE_TOOL="." "./cix_image_tool.sh" -p -K Keys -T rsa3072 \
		--bf31 "./Firmwares/tf-a.bin" \
		--bf32 "./Firmwares/tee.bin" \
		--bf33 "$(shell realpath "$<")" \
		-o "$(shell realpath "$@")"

SHELL := bash
Build/$(UEFI_PROJECT)/$(UEFI_TARGET)_GCC5/FV/SKY1_BL33_UEFI.fd:
	rm -rf Build
	make -C edk2/BaseTools -j$(shell nproc) Source/C
	export WORKSPACE="$(shell pwd)" && \
	export PACKAGES_PATH="$$WORKSPACE/edk2:$$WORKSPACE/edk2-platforms:$$WORKSPACE/edk2-non-osi" && \
	export GCC5_AARCH64_PREFIX="/opt/gcc-arm-10.2-2020.11-x86_64-aarch64-none-elf/bin/aarch64-none-elf-" && \
	unset MAKEFLAGS && \
	source edk2/edksetup.sh --reconfig && \
	build -a AARCH64 -t GCC5 -p "Platform/CIX/Sky1/$(UEFI_PROJECT)/$(UEFI_PROJECT).dsc" \
		-b $(UEFI_TARGET) -D BOARD_NAME=$(BOARD) -D BUILD_DATE=$(shell date "+%VM%y%m%d%H%M%SN") \
		-D COMMIT_HASH=$(shell git rev-parse --short=12 HEAD) -D SMP_ENABLE=1 -D ACPI_BOOT_ENABLE=1

.PHONY: clean
clean:
	rm -rf Build $(PACKAGE_TOOL)/certs
	rm -rf cix_flash.bin $(PACKAGE_TOOL)/Firmwares/bootloader2.img Build/$(UEFI_TARGET)/$(UEFI_TARGET)_GCC5/FV/SKY1_BL33_UEFI.fd
	make -C edk2/BaseTools -j$(shell nproc) clean

.PHONY: distclean
distclean: clean
