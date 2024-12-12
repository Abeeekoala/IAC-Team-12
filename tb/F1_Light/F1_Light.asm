
F1_Light.out.reloc:     file format elf32-littleriscv


Disassembly of section .text:

bfc00000 <main> (File Offset: 0x1000):
main():
bfc00000:	00100413          	addi	s0,zero,1
bfc00004:	0fc00293          	addi	t0,zero,252

bfc00008 <trigger_wait> (File Offset: 0x1008):
trigger_wait():
bfc00008:	0002a583          	lw	a1,0(t0)
bfc0000c:	04058e63          	beq	a1,zero,bfc00068 <lfsr_continue> (File Offset: 0x1068)
bfc00010:	00000513          	addi	a0,zero,0
bfc00014:	04c000ef          	jal	ra,bfc00060 <delay> (File Offset: 0x1060)
bfc00018:	00100513          	addi	a0,zero,1
bfc0001c:	044000ef          	jal	ra,bfc00060 <delay> (File Offset: 0x1060)
bfc00020:	00300513          	addi	a0,zero,3
bfc00024:	03c000ef          	jal	ra,bfc00060 <delay> (File Offset: 0x1060)
bfc00028:	00700513          	addi	a0,zero,7
bfc0002c:	034000ef          	jal	ra,bfc00060 <delay> (File Offset: 0x1060)
bfc00030:	00f00513          	addi	a0,zero,15
bfc00034:	02c000ef          	jal	ra,bfc00060 <delay> (File Offset: 0x1060)
bfc00038:	01f00513          	addi	a0,zero,31
bfc0003c:	024000ef          	jal	ra,bfc00060 <delay> (File Offset: 0x1060)
bfc00040:	03f00513          	addi	a0,zero,63
bfc00044:	01c000ef          	jal	ra,bfc00060 <delay> (File Offset: 0x1060)
bfc00048:	07f00513          	addi	a0,zero,127
bfc0004c:	014000ef          	jal	ra,bfc00060 <delay> (File Offset: 0x1060)
bfc00050:	0ff00513          	addi	a0,zero,255
bfc00054:	00c000ef          	jal	ra,bfc00060 <delay> (File Offset: 0x1060)
bfc00058:	00000513          	addi	a0,zero,0
bfc0005c:	fadff06f          	jal	zero,bfc00008 <trigger_wait> (File Offset: 0x1008)

bfc00060 <delay> (File Offset: 0x1060):
delay():
bfc00060:	00041463          	bne	s0,zero,bfc00068 <lfsr_continue> (File Offset: 0x1068)
bfc00064:	00100413          	addi	s0,zero,1

bfc00068 <lfsr_continue> (File Offset: 0x1068):
lfsr_continue():
bfc00068:	00645e93          	srli	t4,s0,0x6
bfc0006c:	001efe93          	andi	t4,t4,1
bfc00070:	00245f13          	srli	t5,s0,0x2
bfc00074:	001f7f13          	andi	t5,t5,1
bfc00078:	01eecfb3          	xor	t6,t4,t5
bfc0007c:	00141413          	slli	s0,s0,0x1
bfc00080:	01f46433          	or	s0,s0,t6
bfc00084:	07f47413          	andi	s0,s0,127
bfc00088:	f80580e3          	beq	a1,zero,bfc00008 <trigger_wait> (File Offset: 0x1008)
bfc0008c:	00041463          	bne	s0,zero,bfc00094 <delay_not_zero> (File Offset: 0x1094)
bfc00090:	00100413          	addi	s0,zero,1

bfc00094 <delay_not_zero> (File Offset: 0x1094):
delay_not_zero():
bfc00094:	00040393          	addi	t2,s0,0

bfc00098 <delay_loop> (File Offset: 0x1098):
delay_loop():
bfc00098:	fff38393          	addi	t2,t2,-1
bfc0009c:	fe039ee3          	bne	t2,zero,bfc00098 <delay_loop> (File Offset: 0x1098)
bfc000a0:	00008067          	jalr	zero,0(ra)

Disassembly of section .riscv.attributes:

00000000 <.riscv.attributes> (File Offset: 0x10a4):
   0:	1e41                	.2byte	0x1e41
   2:	0000                	.2byte	0x0
   4:	7200                	.2byte	0x7200
   6:	7369                	.2byte	0x7369
   8:	01007663          	bgeu	zero,a6,14 <main-0xbfbfffec> (File Offset: 0x10b8)
   c:	0014                	.2byte	0x14
   e:	0000                	.2byte	0x0
  10:	7205                	.2byte	0x7205
  12:	3376                	.2byte	0x3376
  14:	6932                	.2byte	0x6932
  16:	7032                	.2byte	0x7032
  18:	5f30                	.2byte	0x5f30
  1a:	326d                	.2byte	0x326d
  1c:	3070                	.2byte	0x3070
	...
