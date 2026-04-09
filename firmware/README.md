# Firmware for the `TI CUBE`

These files can be burnt into two EPROMs (must be at least 32 KB each). One file is for the [even/MSB EPROM](even_msb.bin) and the other is for the [odd/LSB EPROM](odd_lsb.bin) (labeled on the memory card).

These files are direct copies from Stuart Conner's [TMS 9900 breadboard system](http://www.stuartconner.me.uk/tms9900_breadboard/tms9900_breadboard.htm#versions_cortex_basic) page. **All rights and credit go to him.**

As he notes on his page: "A combined EPROM binary image is provided which contains the EVMBUG system monitor and Cortex BASIC in the lower 32K bank, and the TIBUG system monitor and Cortex BASIC in the upper 32K bank." 
For the `TI CUBE` the bank is selected using JP1 on the memory card (note: JP2 must be in the "FIXED" position).

# Demo running Cortex BASIC

<img alt="Hellorld!" src="images/TI_CUBE%20demo.gif" />
