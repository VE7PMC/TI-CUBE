# The TI CUBE

The `TI CUBE` is a homebrew microcomputer I designed around the Texas Instruments TMS 9900 microprocessor and its associated peripheral devices.

<img alt="Photo of the complete TI CUBE assembly" src="./images/Complete.jpg" />

In its basic form the `TI CUBE` supports communications through two serial ports and has 32 KiB of ROM and 32 KiB of RAM for code and data storage.

# Why the TMS 9900?

The [TMS 9900 microprocessor was relatively advanced for its time (released in 1976)](https://www.cpushack.com/2015/02/05/ti-tms9900sbp9900-accidental-success/) and is essentially a single-chip version of TI's 990 series of 16-bit minicomputers from the 1970s. The TMS 9900 is considered one of the first true 16-bit microprocessors with a full 16-bit external data bus. This was allowed by the use of rather unconventional 64-pin DIP package. The address bus uses 15 bits, but since all memory accesses are 16-bits wide, this provides a 64 KiB address space (32 K of 16 bit words). The most unique feature of the TMS 9900 is that it had no internal registers, other than the program counter (PC), workspace pointer (WP), and status register (SR) - all 16-bits wide. Instead of internal registers, the WP pointed to a region in external memory where 16 "registers" were stored in sequential memory addresses. Adjusting the WP allowed for very fast context switching by pointing to a different set of "registers". This capability was used in TI 990 minicomputers to support multiuser computing.

The elegance of the internal AND external 16-bit data bus (unlike the crippled Intel 8088 CPU used in the first IBM PC), the quirkiness of its memory-based registers, and its unique serial-based I/O CRU interface makes this chip a fascinating way to explore early microcomputer technology and its capabilities.

Finally, the project was greatly inspired by [Usagi Electric](https://www.youtube.com/@UsagiElectric)'s ongoing homebrew computer project based on the TMS 9900 CPU. I had a spare TMS 9900 IC that I removed from a TI-99/4A several decades ago(!), and figured this was a good way to put it to use. 

# Design Philosophy

The following principles guided my development of this homebrew project. The list is roughly in order of priority (highest is first).

1. **No 8-bit data buses!** The TMS 9900 microprocessor is fundamentally a 16-bit design descendent from TI's 990 series of 16-bit minicomputers and I wanted to honour this ancestry as much as possible. I find address/data bus muxing/demuxing complex and inelegant. Yes, the TMS 9900 isn't the fastest of the TMS 99xx series of microprocessors, but it's the only one that supports an *external* 16-bit data bus interface.

2. **Modularity.** Just like a minicomputer which would typically have a backplane populated with multiple cards, the `TI CUBE` uses a similar philosophy with three basic cards: 
   * CPU card (with clock and interrupt control)
   * Memory card (holding the RAM and ROM)
   * Serial port interface card (equipped with two serial chips driving two EIA-232C compatible ports). 
  
   All cards plug into a backplane using 72-pin header connectors. Any card can go in any slot, and multiple cards (e.g., multiple serial interface cards) are supported. Additional backplanes can also be daisy-chained to support additional card slots.

3. **Board size.** Constraining the board size to 100 x 100 mm (4 x 4 in) allows ordering PCBs using the [JLCPCB](https://jlcpcb.com) or [PCBWAY](https://pcbway.com) prototyping services (personally, I have had great experience with JLCPCB). This significantly reduces the cost of individual boards (approximately $2 per board). The physical construction also gives the `TI CUBE` its name: four 100 x 100 mm vertical cards plugged into a horizontal four-slot 100 x 100 mm backplane.

   Interestingly, these dimensions are similar to those used by [CubeSat](https://en.wikipedia.org/wiki/CubeSat) modules. Perhaps a `TI CUBE` will someday get launched into orbit as the most underpowered satellite ever.

5. **Simplicity.** I subscribe to the [Earl Muntz](https://en.wikipedia.org/wiki/Muntzing) philosophy. As such, the `TI CUBE` design uses the minimum required amount of components to accomplish its function. Random logic (i.e., TTL gates and decoders) is complex and consumes significant board space. Instead, I prefer to use simple and standard PLD devices like the ubiquitous 16V8, which does everything needed in one chip. This also allows easily reconfigurability simply by reprogramming the PLD.

   There are  no address or data buffers in the `TI CUBE`, but the small size combined with the use of four-layer PCBs keeps the digital signals clean; my builds have demonstrated excellent reliablity and performance. 

6. **Period correctness.** Primarily this means use of only through-hole components and no surface mount devices (SMD). I don't mind SMD as such, but through-hole is still easier to assemble and is more consistent with 70s/80s computers. I have violated the period-correctness rule in number of other places (e.g., use of PLDs instead of random logic, larger memory ICs compared to what was available in the 70s and early 80s), so this one is more a [guideline than an actual rule](https://www.youtube.com/watch?v=omjnIeLIzJc&t=13s). 😉

7. **Use of TMS 9900 family peripherals.** The TMS 9900 has a unique serial-oriented I/O bus: the "CRU" (communications-register unit). While there is a plethora of external I/O devices that could be memory mapped, I wanted the `TI CUBE` to remain consistent with the TMS 9900 ecosystem through the used of CRU-based I/O where possible. Currently, this includes the TMS 9901 programmable systems interface (PSI) and the TMS 9902 asynchronous communications controller (ACC). 
   
8. **Compatibility.** I designed the `TI CUBE` to be generally compatible with other TMS 9900-based systems. One excellent example is [Stuart Connor's TMS 9900 breadboard/PCB system](http://www.stuartconner.me.uk/tms9900_breadboard/tms9900_breadboard.htm). In fact, the binary files he provides can be downloaded, burned to EPROMs, and used directly in the `TI CUBE`. This includes the TIBUG and EVMBUG monitors and Cortex BASIC which work right out of the box!

# Hardware Specifications

This [file](hardware/README.md) contains a description of the `TI CUBE` hardware design.

# Future Expansion/Ideas

This [file](FUTURE.md) contains my current thoughts on future expansions and/or design modifications.

# References

* [TI 9900 Family Systems Design and Data Book](https://www.bitsavers.org/components/ti/TMS9900/1978_TI_9900_Family_Systems_Design_and_Data_Book_1ed.pdf)
* [TMS 9900 Microprocessor Data Manual](https://datasheets.chipdb.org/TI/9900/TMS9900_DataManual.pdf)
* [The TI-99/4A Tech Pages](https://www.unige.ch/medecine/nouspikel/ti99/titechpages.htm)
* [TI TMS9900/SBP9900: Accidental Success](https://www.cpushack.com/2015/02/05/ti-tms9900sbp9900-accidental-success/)
* [The Inside Story of Texas Instruments’ Biggest Blunder: The TMS9900 Microprocessor](https://spectrum.ieee.org/the-inside-story-of-texas-instruments-biggest-blunder-the-tms9900-microprocessor)

# Acknowledgements

The following are excellent resources from other experimenters with the TMS 9900:

* [Stuart Conner's Home Page](http://www.stuartconner.me.uk/) contains very helpful hardware designs and software files which I have referenced in the `TI CUBE` design.
* [POWERTRAN Cortex](http://powertrancortex.com/index.html) contains source code for Cortex BASIC which can be modified to run on the `TI CUBE`.

