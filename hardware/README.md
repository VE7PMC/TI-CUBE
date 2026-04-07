# `TI CUBE` Hardware Specifications

1. **CPU board** [(photo)](images/CPU.jpg)
-  TMS 9900 microprocessor running at 3 MHz[^1]
-  TIM 9904 or TIM 9904A clock generator[^2]
-  TMS 9901 programmable systems interface (PSI) for interrupt management
-  ATF16V8 PLD for address decoding
-  ICL7660 voltage convertor to generate the -5V power supply needed by the CPU
-  2x red LEDs for CPU RESET signal and CPU activity (driven by the IAQ output) indication
2. **Memory board** [(photo)](images/Memory.jpg)
-  2x EPROMs (e.g., 2764, 27128, 27256) for 32 KiB of EPROM[^3]
-  2x static RAM (e.g., 55256) for 32 KiB of RAM[^3]
-  2x red LEDs for RAM and ROM access indication
-  ATF16V8 PLD for address decoding
-  Jumpers to control use of the EPROM A14 address line or to select the high or low bank.
3. **Serial I/O board** [(photo)](images/Serial_IO.jpg)
-  2x TMS 9902 asynchronous communications controllers (ACC)
-  2x MAX232 interfaces for EIA-232C compatible serial ports
-  2x ATF16V8 PLD for address decoding
-  2x 10-pin 0.1 in header connectors using the AT/Everex standard pinout to connect serial devices
-  Jumpers to allow address and interrupt selection for each TMS 9902
4. **Protoboard** [(photo)](images/Protoboard.jpg)
-  Unpopulated PCB with a large area of plated-through holes for prototyping
-  Optional ATF16V8 PLD for address decoding
5. **Backplane** [(photo)](images/Backplane.jpg)
-  4x 72-pin header sockets which support any combination of the cards above
-  1x 72-pin header socket for daisy chaining multiple backplanes
-  1x 72-pin header pin connector for daisy chaining multiple backplanes
-  2x red LEDs for +5V and +12 power supply indication
-  1x 4-pin Berg connector for +5V and +12V DC power
-  1x 2-pin 0.1 in. header connector for external RESET input (optional)
-  1x 2-pin 0.1 in. header connector for external LOAD input (optional)
-  The expansion connectors (particularly the pin header connector) can also be used to [access the bus signals for debugging (via a scope or logic analyzer)](images/Debugging.jpg)
-  Two spare bus lines (USER1 and USER2) are provided to carry user-defined signals between cards

# Component Ordering Information

A [Bill of Materials](Bill%20of%20Materials.xlsx) is provided in Excel format. Note that the TI CPU, peripherals and the EPROM and SRAM components are no longer manufactured, so these will have to be acquired from alternate sources (e.g., eBay). These are noted in the spreadsheet. A number of vendors sell a collection of these devices for about $35 USD. 

The remaining components can be purchased online from one of the many electronics vendor sites (e.g., DigiKey, Mouser, Amazon, AliExpress, etc.). I prefer to purchase from DigiKey as there are no worries about marginal or counterfeit parts. A [DigiKey parts list](DigiKey%20Parts%20List.xlsx) is also provide in Excel format; this can be directly uploaded to DigiKey website to create an order. As of April 2026 the cost of parts (excluding the items not currently manufactured) is approximately $60 USD.

Including the costs of PCB manufacturing (approximately $40 USD for a minimum order of 5 boards each), the total cost to assemble a `TI CUBE` is approximately $135 USD for the first unit (subsequent assemblies cost less due to economies of scale).

# Power Supply

The backplane receives +5V and +12V DC power via a standard 4-pin Berg connector (the same connector found on a 3.5" floppy drive). The power requirements are very modest (~1 amp on the +5V DC rail and ~0.1 amp on the +12V DC rail), so a spare PC power supply is more than up to the task.

An ICL7660 is used on the CPU board to generate the -5V DC substrate voltage needed by the TMS 9900 microprocessor, so there is no need for an external -5V DC power supply.

[^1]: Overclocking to 4 MHz is possible if a TMS 9900-40 CPU is used and the appropriate clock component changes are made.

[^2]: Depending on whether the TIM 9904 or TIM 9904A is used, and which CPU frequency is desired (12 or 16 MHz) different components must be selected for the clock crystal and tank circuit. A table of values is provided in the CPU schematic.

[^3]: The RAM and ROM sizes can be adjusted in any combination that fits within the 64 KiB address space simply by adjusting the logic for the chip enable outputs in the PLD program.


