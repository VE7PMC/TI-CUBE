* ============================================================
* VGM Player for TMS9900 by Paul Chernikhowsky
* Assembler: asm990
*
* Plays back a VGM format file using the YM3812 FM synthesis chip.
*
* Note that hex constants in this file use the TMS 9900 format (i.e., ">" indicates a hex value)
* 
* Code origin: 0x8000 (code must be loaded at this RAM location)
* VGM data:    0x9000 (VGM data file must be located starting at 0x9000
*
* YM3812 CRU mapping:
*   CRU bits 0-7 = D0-D7  (data bus, 8 bits)
*   CRU bit  8   = A0     (0=address write, 1=data write)
*   CRU bit  9   = /CS    (chip select, active low)
*   CRU bit  A   = /RD    (read strobe,  active low)
*   CRU bit  B   = /WR    (write strobe, active low)
*
* Register usage:
*   R0  - scratch / CRU data byte
*   R1  - VGM program counter (byte address)
*   R2  - current VGM command byte
*   R3  - YM3812 register address (for OPL write)
*   R4  - YM3812 data byte (for OPL write)
*   R5  - wait sample count (16-bit)
*   R6  - scratch / loop counter
*   R7  - scratch
*   R8  - VGM loop point address (0 = no loop)
*   R14 - saved PC
*   R15 - saved ST
*
* ============================================================

* ------------------------------------------------------------
* Constants
* ------------------------------------------------------------
CRUBASE EQU  >0100        * YM3812 CRU base address - this should be changed as required if the secondary address is used
ACCBASE EQU  >0000        * TMS 9902 serial port CRU base address (used for keyboard interrupt during playback)
VGMBASE EQU  >9000        * VGM data start in memory

CMD_OPL  EQU  >5A         * VGM command: YM3812 write
CMD_WAIT EQU  >61         * VGM command: wait N samples
CMD_W60  EQU  >62         * VGM command: wait 735 samples (1/60s)
CMD_W50  EQU  >63         * VGM command: wait 882 samples (1/50s)
CMD_END  EQU  >66         * VGM command: end of stream

* VGM header offsets
VGM_DATOFS EQU  >34       * offset of data-offset field in header
VGM_GD3OFS EQU  >14       * offset of GD3 relative-offset field (32-bit LE)
VGM_GD3ABS EQU  VGMBASE+>14  * absolute address of GD3 offset field
VGM_LPOFS  EQU  >1C       * offset of loop-offset field (32-bit LE, rel to >1C)
VGM_LPCNT  EQU  >20       * offset of loop sample count (32-bit LE, informational)
VGM_LPABS  EQU  VGMBASE+>1C  * absolute address of loop-offset field

* GD3 tag structure offsets from tag start
GD3_IDENT  EQU  >00       * "Gd3 " 4-byte magic
GD3_VER    EQU  >04       * version (4 bytes)
GD3_LEN    EQU  >08       * data length (4 bytes)
GD3_DATA   EQU  >0C       * first string starts here (English track name, UTF-16LE)

* Wait constants (samples, 16-bit)
WAIT_735 EQU  735         * 1 NTSC frame @ ~44100 Hz (VGM standard)
WAIT_882 EQU  882         * 1 PAL  frame

* ------------------------------------------------------------
* Workspace (32 bytes of scratchpad RAM, word-aligned)
* ------------------------------------------------------------
WRKSP    EQU  >8200

* ------------------------------------------------------------
* Code entry point
* ------------------------------------------------------------
         AORG >8000

START    LWPI WRKSP       * load workspace pointer
         LIMI 0           * disable interrupts

* Set up CRU base for YM3812 in R12
         LI   R12,CRUBASE * R12 = >0100

* Deassert /CS, /RD, /WR (all are inactive high)
         SBO  10          * /RD = 1 (inactive)
         SBO  11          * /WR = 1 (inactive)
         SBO  9           * /CS = 1 (deselected)

         BL   @FMRESET    * Reset the YM3812 chip
		 
* Calculate VGM data start address
* Absolute data start = VGMBASE + >34 + offset_at_(VGMBASE+>34)
         LI R1, VGMBASE+>80    * standard data start = >9000 + >34 + >4C = >9080

* ------------------------------------------------------------
* Read VGM loop offset from header (32-bit LE at VGMBASE+>1C)
* Loop abs address = VGMBASE + VGM_LPOFS + loop_offset
* If loop_offset == 0, no loop; R8 = 0 signals that below.
* We only use the lower 16 bits (VGM files have to fit in the 64 KB address space).
* TMS9900 MOV reads [addr] as high byte, [addr+1] as low byte
* (big-endian word read), but the field is little-endian in
* the VGM file, so one SWPB corrects the 16-bit value.
* ------------------------------------------------------------
         MOV  @VGM_LPABS,R8    * load LE low 16 bits of loop offset (bytes swapped)
         SWPB R8               * R8 = correct 16-bit offset value
         CI   R8,0
         JEQ  NOLOOP           * zero offset -> no loop, leave R8=0
         AI   R8,VGM_LPABS     * R8 = VGMBASE + >1C + offset  (absolute loop addr)
NOLOOP

* ------------------------------------------------------------
* Main player loop
* ------------------------------------------------------------
         BL   @PRTGD3     * Read GD3 tag and print track name

MAINLP
         LI   R12,ACCBASE * CRU base for TMS9902
         TB   21          * test receive buffer full flag
         JEQ  STOP        * character waiting - stop playback
         LI   R12,CRUBASE * restore YM3812 CRU base

         MOVB *R1+,R2     * fetch command byte, advance PC
         SWPB R2          * move byte to low byte of R2
         ANDI R2,>00FF    * zero-extend

         CI   R2,CMD_END  * >66 end of stream?
         JEQ  DOEND

         CI   R2,CMD_OPL  * >5A YM3812 write?
         JEQ  DOOPL

         CI   R2,CMD_WAIT * >61 wait N samples?
         JEQ  DOWAIT

         CI   R2,CMD_W60  * >62 wait 735 samples?
         JEQ  DOW60

         CI   R2,CMD_W50  * >63 wait 882 samples?
         JEQ  DOW50
		 
* Unknown command: single byte is already consumed, so skip and continue
         JMP  MAINLP

* ------------------------------------------------------------
STOP     MOV  R11,R9      * save R11 across nested calls
         SBZ  18          * Reset RBRL (to clear rcvd char)
         LI   R12,CRUBASE * restore YM3812 CRU base
         BL   @FMRESET    * silence the chip

         JMP  DONE

* ------------------------------------------------------------
DOOPL    MOVB *R1+,R3     * fetch register byte
         SWPB R3
         ANDI R3,>00FF
         MOVB *R1+,R4     * fetch data byte
         SWPB R4
         ANDI R4,>00FF
         BL   @OPLWRT
         JMP  MAINLP

* ------------------------------------------------------------
DOWAIT   MOVB *R1+,R0     * fetch low byte of sample count
         SWPB R0
         ANDI R0,>00FF
         MOVB *R1+,R5     * fetch high byte
         SWPB R5
         ANDI R5,>00FF
         SLA  R5,8        * shift high byte to upper 8 bits
         SOC  R0,R5       * combine: R5 = 16-bit sample count
         BL   @DOWT
         JMP  MAINLP

* ------------------------------------------------------------
DOW60    LI   R5,WAIT_735
         BL   @DOWT
         JMP  MAINLP

* ------------------------------------------------------------
DOW50    LI   R5,WAIT_882
         BL   @DOWT
         JMP  MAINLP

* ------------------------------------------------------------
* End-of-stream handler: loop back if a loop point is set,
* otherwise fall through to DONE.
* ------------------------------------------------------------
DOEND    CI   R8,0        * loop point set?
         JEQ  DONE        * no -> stop
         MOV  R8,R1       * yes -> R1 (VGM PC) = loop address
         JMP  MAINLP      * continue from loop point

* ------------------------------------------------------------
DONE     XOP  @ENDMSG,14  * Print done message
         B    >0080       * Return to TIBUG

* ============================================================
* Reset YM3812: write 0 to all operator registers >20->F5
* Trashes: R3, R4, R9
* Returns: via B *R9
* ============================================================
FMRESET  MOV  R11,R9
         XOP  @RSTMSG,14  * Print reset message

* --- Key-off all 9 channels first ---
         LI   R3,>00B0    * first channel key-on register
         CLR  R4          * data = 0 (key-off, block=0, freq-hi=0)
KLOOP    BL   @OPLWRT
         AI   R3,>0001
         CI   R3,>00B9    * done after B8
         JNE  KLOOP

* --- Short delay to let envelopes release ---
         LI   R5,>0800
RDLY     DEC  R5
         JNE  RDLY

* --- Now zero all operator registers ---
         LI   R3,>0020
         CLR  R4
RLOOP    BL   @OPLWRT
         AI   R3,>0001
         CI   R3,>00F6
         JNE  RLOOP
         B    *R9
		 
* ============================================================
* PRTGD3 - Read GD3 English track name and print it
*
* Reads the 32-bit little-endian GD3 relative offset from the
* VGM header at VGMBASE+>14.  The offset is relative to its own
* location, so:  GD3_abs = VGMBASE + VGM_GD3OFS + offset
* The GD3 header is 12 bytes ("Gd3 " + version + length), after
* which follows the first string: English track name in UTF-16LE.
* We iterate through the UTF-16LE chars, outputting the low byte
* of each via XOP 12 (TIBUG single character output), stopping when the
* low byte is zero.  Falls back to a generic message if no GD3 tag found.
*
* Trashes: R0, R6, R7, R9
* Returns: via B *R11
* ============================================================
PRTGD3
* --- Step 1: read GD3 relative offset (32-bit little-endian) ---
* VGM stores it LE: byte[>14]=lo8, byte[>15]=hi8 (low 16 bits).
* TMS9900 MOV loads [addr] as high byte, [addr+1] as low byte,
* so after MOV the bytes are swapped; SWPB corrects this.
* Upper 16 bits (bytes >16/>17) ignored; VGM files fit in 64KB.
         MOV  @VGM_GD3ABS,R7           * load LE word (bytes swapped)
         SWPB R7                       * R7 = correct 16-bit offset value

* --- Step 2: check for absent GD3 (offset == 0) ---
         CI   R7,0
         JEQ  NOGD3

* --- Step 3: compute absolute address of GD3 tag ---
* Absolute = VGMBASE + VGM_GD3OFS + R7
         AI   R7,VGM_GD3ABS            * R7 -> "Gd3 " magic

* --- Step 4: skip GD3 header (12 bytes) to reach string data ---
* "Gd3 " (4) + version (4) + data-length (4) = >0C bytes
         AI   R7,GD3_DATA              * R7 -> first UTF-16LE char of track name

* --- Step 5: print prefix ---
         XOP  @MSGPFX,14               * print "Now playing: "

* --- Step 6: output track name one ASCII char at a time via XOP 12 ---
* UTF-16LE: each char is two bytes, low byte first then high byte.
* For ASCII-range titles the high byte is always >00; we use low byte.
* MOVB *R7+,R6 fetches the low byte into R6's high byte and sets EQ if zero.
GLOOP    MOVB *R7+,R6                  * R6 hi = UTF-16 low byte; EQ set if zero
         JEQ  GNULL                    * null low byte -> end of string
         MOVB *R7+,R0                  * consume UTF-16 high byte (discard)
         XOP  R6,12                    * output character in high byte of R6
         JMP  GLOOP

GNULL    MOVB *R7+,R0                  * consume the paired high byte (should be >00)
         XOP  @MSGCR,14                * newline after track name

* --- Step 7: skip 5 more UTF-16LE strings to reach author field ---
* Strings 2-6: track name (orig), game name (EN), game name (orig),
*              system name (EN), system name (orig)
* Save PRTGD3's return address; BL @SKPSTR will overwrite R11.
         MOV  R11,R9                   * R9 = saved return address
         LI   R6,5                     * skip 5 strings
SKIPLP   BL   @SKPSTR                  * advance R7 past one UTF-16LE string
         DEC  R6
         JNE  SKIPLP
         MOV  R9,R11                   * restore PRTGD3's return address

* --- Step 8: print author (English) ---
         XOP  @MSGBY,14                * print "by: "
ALOOP    MOVB *R7+,R6                  * R6 hi = UTF-16 low byte; EQ set if zero
         JEQ  ANULL                    * null low byte -> end of string
         MOVB *R7+,R0                  * consume UTF-16 high byte (discard)
         XOP  R6,12                    * output character in high byte of R6
         JMP  ALOOP

ANULL    MOVB *R7+,R0                  * consume the paired high byte
         XOP  @MSGCR,14                * print CR/LF
         B    *R11

* --- Fallback: no GD3 tag ---
NOGD3    XOP  @PLAYMSG,14              * print generic "Playing VGM file..."
         B    *R11

* ============================================================
* SKPSTR - Skip one null-terminated UTF-16LE string
* Advances R7 past the next string including its double-null terminator.
* Trashes: R0
* ============================================================
SKPSTR   MOVB *R7+,R0                  * fetch low byte; EQ set if zero
         JEQ  SKEND
         MOVB *R7+,R0                  * consume high byte
         JMP  SKPSTR
SKEND    MOVB *R7+,R0                  * consume paired high byte of terminator
         B    *R11

* ============================================================
* OPLWRT - Write one byte to YM3812
* Inputs:  R3 = register address (word, low byte used)
*          R4 = data byte        (word, low byte used)
* Trashes: R0, R6
* Uses R12 as CRU base (must already be set to CRUBASE*2)
* ============================================================
OPLWRT
* --- Phase 1: write register address ---
         MOV  R3,R0       * copy register to R0 for LDCR
		 SWPB R0          * swap MSB and LSB
         LDCR R0,8        * output 8 bits to CRU D0-D7

         SBZ  8           * YM3812 A0 = 0 (address phase)
         SBO  10          * YM3812 /RD = 1 (inactive)
         SBO  11          * YM3812 /WR = 1 (deassert first)
         SBZ  9           * YM3812 /CS = 0 (select)
         SBZ  11          * YM3812 /WR = 0 (latch address)
         SBO  11          * YM3812 /WR = 1 (done)
         SBO  9           * YM3812 /CS = 1 (deselect)

* Address setup delay (~3.3 us = ~10 cycles @ 3MHz, we do a short loop)
         LI   R6,5
ADLP     DEC  R6
         JNE  ADLP

* --- Phase 2: write data ---
         MOV  R4,R0       * copy data to R0 for LDCR
		 SWPB R0          * swap MSB and LSB
         LDCR R0,8        * output 8 bits to CRU D0-D7

         SBO  8           * YM3812 A0 = 1 (data phase)
         SBZ  9           * YM3812 /CS = 0 (select)
         SBZ  11          * YM3812 /WR = 0 (latch data)
         SBO  11          * YM3812 /WR = 1 (done)
         SBO  9           * YM3812 /CS = 1 (deselect)

         SBZ  8           * Exit with YM3812 A0 low
		 LI   R0,>0
		 LDCR R0,8        * Exit with YM3812 data bits low

         B    *R11        * return (BL saves return addr in R11)

* ============================================================
* DOWT - Busy-wait for R5 samples
*
* This delay loop is precisely tuned to play back at the correct
* tempo only when using a 3 MHz CPU clock. The timing will need
* to be adjusted if a different CPU clock is used.
*
* Trashes: R6
* ============================================================
DOWT
         MOV  R5,R6        
         JEQ  DWDONE       
DWOUT    NOP               * 10 cycles
         NOP               * 10 cycles
         LIMI 0            * 16 cycles
         LIMI 0            * 16 cycles
         DEC  R6           * 10 cycles
         JNE  DWOUT        * 10 taken / 8 not taken
DWDONE   B    *R11

* ------------------------------------------------------------
* Text strings
* ------------------------------------------------------------

RSTMSG   BYTE >0d,>0a
         TEXT 'Resetting YM3812...'
         BYTE >0d,>0a,>00
		 
MSGPFX   TEXT 'Now playing: '
         BYTE >00

MSGBY    TEXT 'by: '
         BYTE >00

MSGCR    BYTE >0d,>0a,>00

PLAYMSG  TEXT 'Playing VGM file...'
         BYTE >0d,>0a,>00

ENDMSG   TEXT 'Done.'
         BYTE >0d,>0a,>00
		 

* ============================================================
* End of code
* ============================================================
         END  START
