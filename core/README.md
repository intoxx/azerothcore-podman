# Core
This directory contains tools to build the core.

> [!WARNING]
> **WORK IN PROGRESS**
>
> **MUST DO**
> - Update README with potential LLVM and CMakeList fixes

## Dependencies
Install the following dependencies before performing anything.
- podman
- buildah

## Compilation
1. Download AzerothCore source code into this folder with
`git clone https://github.com/azerothcore/azerothcore-wotlk.git`
2. Build the base container image with `./build-bci.sh`
3. Build the development container image with `./build-dev.sh`.
4. Finally, build the core with `./build.sh`. This will create a `build` directory on the host.
5. Your built installation lives into `build/dist`. Other containers will make use of that.

Note that other building scripts such as `./build-runtime.sh` are used by dependent images such as the authserver and the worldserver.
