# Description

This folder contains files for programming the various programmable logic devices (PLDs) that are used for decoding addresses.

# File Formats

The .pld files are in [WINCUPL II format](https://www.microchip.com/en-us/development-tool/wincupl). 

The .jed files are pre-generated JEDEC programming files that are almost all device programmers.

# PLD Configuration Files

## TI-CUBE-9901AddrDecode Files

One ATF16V8 PLD (U5) is used to decode the CRU address for the TMS 9901 PSI on the `TI CUBE` CPU Board. By default this device is set to CRU address 0x40.

## TI-CUBE-9902AddrDecode Files

Two ATF16V8 PLDs (U1 and U2) are used to decode the CRU address for the two TMS 9902 ACC devices on the `TI CUBE` Serial Interface Board. Address selection for each ACC is set by installing a jumper on the appropriate address selection.

Jumper           | CRU Address Range
---------------- | -----------------
Address Select 0 | 0x00 to 0x3F
Address Select 1 | 0x80 to 0xBF
Address Select 2 | 0xC0 to 0xFF
Address Select 3 | 0x100 to 0x13F
Address Select 4 | 0x200 to 0x23F
Address Select 5 | 0x400 to 0x43F

These address ranges can be changed by editing the .pld file, recompiling the .jed file, and then reprogramming either U1 or U2 (as required).

## TI-CUBE-MemAddrAddrDecode Files

One ATF16V8 PLD (U5) is used to decode the memory address enables for the RAM and ROM devices on the `TI CUBE` Memory Board. By default the ROM is addressed from 0x0000 to 0x7FFF (32 kiB) and the RAM is addressed from 0x8000 to 0xFFFF (32 kiB). These address ranges can be changed by editing the .pld file, recompiling the .jed file, and then reprogramming U5.

