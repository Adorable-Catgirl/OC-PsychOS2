# OC-PsychOS2

A lightweight, multi-user operating system for OpenComputers

## Building

### The kernel

The kernel can be built using the build script:

    ./build.sh

### The boot filesystem

A boot filesystem contains several things:

 - The kernel, as init.lua
 - The exec/ directory, as this contains all executables
 - The lib/ directory, containing libraries
 - The service/ directory, containing system services

This has been automated in the form of build.sh, pending a real makefile.

## Documentation

To generate function documentation, run:

    ./finddesc.lua module/* lib/* > apidoc.md
