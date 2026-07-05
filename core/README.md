# Core
This directory contains tools to build the core.

> [!WARNING]
> **WORK IN PROGRESS**

## Dependencies
Install the following dependencies before performing anything.
- podman
- buildah

## Compilation
1. Download AzerothCore or Playerbots fork source code into this folder with
```sh
# original azerothcore
git clone https://github.com/azerothcore/azerothcore-wotlk.git

# or the version compatible with mod-playerbots
# see https://github.com/mod-playerbots/mod-playerbots/wiki/Installation-Guide
git clone https://github.com/mod-playerbots/azerothcore-wotlk.git --branch=Playerbot
cd azerothcore-wotlk/modules
git clone https://github.com/mod-playerbots/mod-playerbots.git --branch=master
```
2. Build the base container image with `./build-bci.sh`
3. Build the development container image with `./build-dev.sh`.
4. Finally, build the core with `./build.sh`. This will create a `build` directory on the host.
5. Your built installation lives into `build/dist`. Other containers will make use of that.

Note that other building scripts such as `./build-runtime.sh` are used by dependent images such as the authserver and the worldserver.

### Errors & Warnings during compilation
#### LLVM
In case of a complain about llvm, installing `llvm llvm-devel` inside the dev container will fix it.

#### CMakeList fix for find_package(Boost)
If this happens this is because the policy isn't enabled. Add the following to `azerothcore-wotlk/deps/boost/CMakeLists.txt` to fix it.

```cmake
# Fix for find_package(Boost)
if(POLICY CMP0167)
  cmake_policy(SET CMP0167 NEW)
endif()
```

this should be added just before the already existing part

```cmake
# Boost.System is header-only since 1.69; do not require it explicitly.
find_package(Boost ${BOOST_REQUIRED_VERSION} REQUIRED COMPONENTS filesystem program_options iostreams regex)
```
