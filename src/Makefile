UEFI_TARGET ?= RELEASE

.PHONY: all
all: build

PACKAGE_TOOL := edk2-non-osi/Platform/CIX/Sky1/PackageTool
DSC := $(wildcard edk2-platforms/Platform/CIX/Sky1/*/*.dsc) $(wildcard edk2-platforms/Platform/Radxa/Orion/*/*.dsc)
CIX_FLASH := $(foreach i, $(patsubst edk2-platforms/Platform/%.dsc,%,$(DSC)), Build/$(lastword $(subst /, ,$(i)))/$(UEFI_TARGET)_GCC5/cix_flash.bin)
.PHONY: build
build: $(CIX_FLASH)

.SILENT: help
.PHONY: help
help:
	echo "Supported targets:"
	echo "$(CIX_FLASH)"

Build/%/$(UEFI_TARGET)_GCC5/cix_flash.bin: Build/%/$(UEFI_TARGET)_GCC5/bootloader2.img
	cp Build/$*/$(UEFI_TARGET)_GCC5/bootloader2.img $(PACKAGE_TOOL)/Firmwares/bootloader2.img
	cd "$(PACKAGE_TOOL)" && \
	"./cix_package_tool" -c "./cix_spi_flash_config.json" \
		-o "$(shell realpath "$@")"

Build/%/$(UEFI_TARGET)_GCC5/bootloader2.img: Build/%/$(UEFI_TARGET)_GCC5/FV/SKY1_BL33_UEFI.fd
	cd "$(PACKAGE_TOOL)" && \
	PATH_PACKAGE_TOOL="." "./cix_image_tool.sh" -p -K Keys -T rsa3072 \
		--bf31 "./Firmwares/tf-a.bin" \
		--bf32 "./Firmwares/tee.bin" \
		--bf33 "$(shell realpath "$<")" \
		-o "$(shell realpath "$@")"

.ONESHELL:
SHELL := bash
Build/%/$(UEFI_TARGET)_GCC5/FV/SKY1_BL33_UEFI.fd:
	make -C edk2/BaseTools -j$(shell nproc) Source/C
	export WORKSPACE="$(shell pwd)"
	export PACKAGES_PATH="$$WORKSPACE/edk2:$$WORKSPACE/edk2-platforms:$$WORKSPACE/edk2-non-osi"
	export GCC5_AARCH64_PREFIX="/opt/gcc-arm-10.2-2020.11-x86_64-aarch64-none-elf/bin/aarch64-none-elf-"
	if [[ -f tools/acpica/generate/unix/bin/iasl ]]; then
		export IASL_PREFIX="$$WORKSPACE/tools/acpica/generate/unix/bin/"
	fi
	unset MAKEFLAGS
	source edk2/edksetup.sh --reconfig
	build -a AARCH64 -t GCC5 -p "$(subst edk2-platforms/,,$(filter %/$*.dsc,$(DSC)))" \
		-b $(UEFI_TARGET) -D BOARD_NAME=$(word 2, $(subst /,, $@)) -D BUILD_DATE=$(shell date -Is) \
		-D COMMIT_HASH=$(shell git rev-parse --short HEAD) -D SMP_ENABLE=1 -D ACPI_BOOT_ENABLE=1 \
		-D DEB_VERSION=$(shell cd .. && dpkg-parsechangelog -S Version)

tools/acpica/generate/unix/bin/iasl:
	make -C tools/acpica -j$(shell nproc)

.PHONY: clean
clean:
	rm -rf Build $(PACKAGE_TOOL)/certs
	rm -rf $(PACKAGE_TOOL)/Firmwares/bootloader2.img
	make -C edk2/BaseTools -j$(shell nproc) clean
	make -C tools/acpica -j$(shell nproc) veryclean || true

.PHONY: distclean
distclean: clean
