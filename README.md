# Orion
A 32-bit kernel &amp; operating system written from scratch, as the name implies, with a working shell and multi-tasking capabilities. **Will only run on x86 processors (intel, amd), not on ARM/etc**. This is due to certain parts (like the bootloader) being written in x86 assembly, which makes it specific to that platform.

# features

- FAT16 file system
- Memory management
- Multitasking/multithreading
- Capable of loading ELF files and binary files
- User shell
- Support for user mode / kernel mode switching (with Intel's built in security protections)
- Built-in custom written keyboard driver
