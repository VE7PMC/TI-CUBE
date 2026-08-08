# -------------------------------
# Generic makefile for asm990 + lnk990
# Produces: program.bin (a.out with first 16 bytes removed)
# -------------------------------

# Input source file (without extension)
TARGET = vgmplay

# Tools
AS = asm990
LD = lnk990

# Flags (customize as needed)
ASFLAGS =
LDFLAGS = -a

# Default target
#all: $(TARGET).bin

# Assemble .asm → .obj
$(TARGET).obj: $(TARGET).asm
	$(AS) $(ASFLAGS) -l $(TARGET).lst -o $@ $<

# Uncomment the following to generate ROM images
# Link .obj → a.out
#$(TARGET).o: $(TARGET).obj
#	$(LD) $(LDFLAGS) -o $@ $<

# Strip first 16 bytes → final binary (and split into two files)
#$(TARGET).bin: $(TARGET).o
#	tail -c +17 $< > $@

# Split into even and odd bytes
#$(TARGET)-rom_msb.bin: $(TARGET).bin
#	srec_cat -o $@ -binary $< -binary -split 2 0

#$(TARGET)-rom_lsb.bin: $(TARGET).bin
#	srec_cat -o $@ -binary $< -binary -split 2 1

# Cleanup
clean:
	rm -f $(TARGET).obj $(TARGET).o $(TARGET)*.bin $(TARGET).lst 

