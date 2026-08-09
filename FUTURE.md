# Thoughts on Future Expansion/Modifications

## Can it play Doom?

~~The short answer is "no, not even close." I'm working on an idea for a longer answer that starts with "yes, but...".~~

**Yes - it can!** As long as your definition of "play" is limited to playing the sound files! The TMS 9900 CPU itself does not even come close to the capabilities required to render realtime 3D imagery, but when combined with the [Yamaha YM3812 FM synthesis](https://www.ardent-tool.com/datasheets/Yamaha_YM3812.pdf) and [YM3014B DAC](https://ardent-tool.com/datasheets/Yamaha_YM3014B.pdf) ICs it can certainly play the sound files (when converted to VGM format). Even still, the playback duration is limited to the available free RAM. With the current configuration this represents approximately 29,200 bytes of memory which is good for about 30 seconds of Doom music playback.

Instructions to upload the VGM Player object code and an associated VGM file can be found [here](/code/VGMPlay/README.md#uploading-the-object-code-and-vgm-files).

And here's a video (and audio) demo:\
[![Watch the TI CUBE play Doom!](https://img.youtube.com/vi/pIbxxHVAydw/sddefault.jpg)](https://www.youtube.com/watch?v=pIbxxHVAydw)

## External Instructions
The TMS 9900 has an interesting feature where a handful of instructions can be decoded externally and used to trigger various hardware functions. These instructions are:
| Mnemonic  | A0 | A1 | A2 | A3-A14 |
| ---- | - | - | - | ---------- |
| RSET | 0 | 1 | 1 | Don't care |
| IDLE | 0 | 1 | 0 | Don't care |
| CKON | 1 | 0 | 1 | Don't care |
| CKOF | 1 | 1 | 0 | Don't care |
| LREX | 1 | 1 | 1 | Don't care |
| CRU operations | 0 | 0 | 0 | From R12 |

These five instructions implemented various hardware extensions in the TI 990 series of minicomputers. 

For the `TI CUBE`, RSET could be decoded and used to trigger an external hardware reset. The IDLE instruction is typically used by the operating system to pause procesing of instructions while waiting for an external interrupt (I/O or timer). On TI 990 minicomputers this instruction was decoded to drive the front panel "IDLE" LED.

The CKOF/CKOF instructions are used for various implementation-specific functions (some microcomputers such as the Cortex used these for enabling/disabling the memory mapper function). The LREX (Load and Restart Execution) instruction was used in some hardware to implement a single-step function.

All of the above could be added to the `TI CUBE` by decoding the appropriate address lines (A0, A1 and A2) along with the CRUCLK signal using the existing 16V8 PLDs (or additional devices).

## RAM Memory Expansion
The `TI CUBE` memory board decodes the entire address space of the TMS 9900 but this is a maximum of 65536 bytes (64 kiB). A number of other computers based on the TMS 9900 (e.g., Cortex and the TI 990/10 and 990/12) used memory mappers to expand the memory space up to 1 MiB or more of RAM via paging. The primary advantage of this expansion is that would allow running either [MDEX](http://www.stuartconner.me.uk/mini_cortex/mini_cortex.htm#using_mdex) or [Unix](http://www.stuartconner.me.uk/mini_cortex/mini_cortex.htm#using_unix), both courtesy of Stuart Conner who ported them for his Mini-Cortext project. I'd really like to try Unix on the `TI CUBE` as it might allow a rudimentary mulituser system to be constructed (when equipped with multiple additional serial cards). 

## Floppy and/or Hard Drive Controller
The next step after the memory expansion described above would be to add non-volatile storage using using a floppy or hard-drive controller. This would also be necessary to support booting the MDEX/Unix systems described above.
