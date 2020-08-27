# H8 Clock Glitching Dumper

### What?
Mask ROM H8 3297/4 series parts seem to prevent reading back the ROM via the normal process used in the PROM variants.  This is likely a security feature and wasn't unexpected.  That said, I want to dump the ROMs of these parts, and this is the FPGA project containing the clock glitching, memory map, etc. to make it happen.

### Why?
The Nintendo 64DD is effectively crippled by making portions of every disk read-only. Through some probing it was determiend that the onboard H8 is responsible for this write protection.  By dumping, modifying, and programming a replacement micro, the ability to write anywhere should be possible.
