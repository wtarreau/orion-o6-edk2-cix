# Build

We use docker to maintain a consistent build environment.

To build all supported EDK2 variants, please run `.github/common/build-deb`.

If you enable `devenv`, then you can run `edk2-build` from the project root as a shortcut.

Set `BUILD_TARGET` to `DEBUG` in `src/Makefile` to build for debug artifacts.

Edit `DSC` in `src/Makefile` to reduce amount of variants that will be built.
You should also edit `debian/edk2-cix.install` to exclude unbuild variants,
otherwise `debuild` will complain that those files are missing.
