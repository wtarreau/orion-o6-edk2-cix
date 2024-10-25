UEFI_TARGET ?= RELEASE
# Specify DEBUG build for development
#UEFI_TARGET ?= DEBUG

.PHONY: all
all: build

PACKAGE_TOOL := edk2-non-osi/Platform/CIX/Sky1/PackageTool
DSC := $(shell find edk2-platforms/Platform/Radxa -mindepth 3 -maxdepth 3 -name "*.dsc" -type "f") \
		$(shell find edk2-platforms/Platform/CIX -mindepth 3 -maxdepth 3 -name "*.dsc" -type "f")

CIX_FLASH := $(foreach i, $(patsubst edk2-platforms/Platform/%.dsc,%,$(DSC)), Build/$(lastword $(subst /, ,$(i)))/$(UEFI_TARGET)_GCC5/cix_flash.bin)
.PHONY: build
build: $(CIX_FLASH)

.SILENT: help
.PHONY: help
help:
	echo "Supported targets:"
	echo "$(CIX_FLASH)"

MEM_CFG_MEMFREQ := 5500
Build/%/$(UEFI_TARGET)_GCC5/cix_flash.bin: Build/%/$(UEFI_TARGET)_GCC5/Firmwares/bootloader2.img
	cp -aR $(PACKAGE_TOOL)/Firmwares/ Build/$*/$(UEFI_TARGET)_GCC5/
	export EC="$(wildcard edk2-non-osi/Platform/*/*/$*/Firmwares/ec_firmware.bin)" && \
	if [[ -f "$$EC" ]]; then \
		cp "$$EC" Build/$*/$(UEFI_TARGET)_GCC5/Firmwares/; \
	fi
	export MEM="$(wildcard edk2-platforms/Platform/*/*/$*/MemoryConfig)" && \
	if [[ -d "$$MEM" ]]; then \
		make -C "$$MEM" -j$(shell nproc) -e CFLAG:="-DMEM_CFG_MEMFREQ=$(MEM_CFG_MEMFREQ) -DMEM_CFG_CHMASK=15"; \
		mv "$$MEM/memory_config.bin" Build/$*/$(UEFI_TARGET)_GCC5/Firmwares/
	fi
	PATH_PACKAGE_TOOL="$(shell realpath "$(PACKAGE_TOOL)")"
	pushd "Build/$*/$(UEFI_TARGET)_GCC5/" && \
	"$$PATH_PACKAGE_TOOL/cix_package_tool" -c "$$PATH_PACKAGE_TOOL/cix_spi_flash_config.json" -o "./cix_flash.bin" && \
	popd

Build/%/$(UEFI_TARGET)_GCC5/Firmwares/bootloader2.img: Build/%/$(UEFI_TARGET)_GCC5/FV/SKY1_BL33_UEFI.fd
	mkdir -p "Build/$*/$(UEFI_TARGET)_GCC5/Firmwares/"
	export PATH_PACKAGE_TOOL="$(shell realpath "$(PACKAGE_TOOL)")" && \
	pushd "Build/$*/$(UEFI_TARGET)_GCC5/" && \
	"$$PATH_PACKAGE_TOOL/cix_image_tool.sh" -p -K "../../../$(PACKAGE_TOOL)/Keys" -T rsa3072 \
		--bf31 "$$PATH_PACKAGE_TOOL/Firmwares/tf-a.bin" \
		--bf32 "$$PATH_PACKAGE_TOOL/Firmwares/tee.bin" \
		--bf33 "$(shell realpath "$<")" \
		-o "./Firmwares/bootloader2.img" && \
	popd

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
	rm -rf Build
	make -C edk2/BaseTools -j$(shell nproc) clean
	make -C tools/acpica -j$(shell nproc) veryclean || true

.PHONY: distclean
distclean: clean
