
./out/irq_div.out:     file format elf32-mist32


Disassembly of section .text:

00000000 <_start>:
   0:	0d 40 00 00 	wl16	r0,0x0
   4:	0d 60 00 0f 	wh16	r0,0xf
   8:	1c 00 00 00 	srspw	r0
   c:	14 30 00 1a 	br	74 <target>,#al

00000010 <mem_print>:
  10:	0d 40 02 08 	wl16	r16,0x8
  14:	0d 60 02 02 	wh16	r16,0x2
  18:	10 a0 00 10 	st32	r0,r16
  1c:	14 40 03 e0 	b	rret,#al

00000020 <error>:
  20:	0d 40 03 20 	wl16	r25,0x0
  24:	0d 60 03 22 	wh16	r25,0x2
  28:	0e c0 03 40 	lil	r26,0
  2c:	10 a0 03 59 	st32	r26,r25
  30:	0d 40 03 30 	wl16	r25,0x10
  34:	0d 60 03 22 	wh16	r25,0x2
  38:	10 a0 03 79 	st32	r27,r25
  3c:	0d 40 03 2c 	wl16	r25,0xc
  40:	0d 60 03 22 	wh16	r25,0x2
  44:	10 a0 03 99 	st32	r28,r25
  48:	0d 40 03 34 	wl16	r25,0x14
  4c:	0d 60 03 22 	wh16	r25,0x2
  50:	10 a0 03 b9 	st32	rglobl,r25
  54:	0d 40 03 38 	wl16	r25,0x18
  58:	0d 60 03 22 	wh16	r25,0x2
  5c:	10 a0 03 d9 	st32	rbase,r25

00000060 <finish>:
  60:	0d 40 03 24 	wl16	r25,0x4
  64:	0d 60 03 22 	wh16	r25,0x2
  68:	0e c0 03 41 	lil	r26,1
  6c:	10 a0 03 59 	st32	r26,r25
  70:	14 30 00 00 	br	70 <finish+0x10>,#al

00000074 <target>:
  74:	0d c0 00 00 	clr	r0
  78:	0d c0 00 20 	clr	r1

0000007c <clr_idt_lp>:
  7c:	0d 40 02 00 	wl16	r16,0x0
  80:	0d 60 02 04 	wh16	r16,0x4
  84:	00 00 02 01 	add	r16,r1
  88:	0d 40 02 20 	wl16	r17,0x0
  8c:	0d 60 02 20 	wh16	r17,0x0
  90:	0d 40 02 40 	wl16	r18,0x0
  94:	0d 60 02 40 	wh16	r18,0x0
  98:	10 a0 02 30 	st32	r17,r16
  9c:	00 10 02 04 	add	r16,4
  a0:	10 a0 02 50 	st32	r18,r16
  a4:	00 10 00 28 	add	r1,8
  a8:	02 00 00 00 	inc	r0,r0
  ac:	00 d0 10 00 	cmp	r0,128
  b0:	14 3b ff f3 	br	7c <clr_idt_lp>,#leu
  b4:	0d c0 00 00 	clr	r0
  b8:	0d 40 30 18 	wl16	r0,0x198
  bc:	0d 40 02 00 	wl16	r16,0x0
  c0:	0d 60 02 04 	wh16	r16,0x4
  c4:	00 00 02 00 	add	r16,r0
  c8:	0d 40 02 23 	wl16	r17,0x3
  cc:	0d 60 02 20 	wh16	r17,0x0
  d0:	0d 40 22 48 	wl16	r18,0x108
  d4:	0d 60 02 40 	wh16	r18,0x0
  d8:	10 a0 02 30 	st32	r17,r16
  dc:	00 10 02 04 	add	r16,4
  e0:	10 a0 02 50 	st32	r18,r16
  e4:	0d 40 00 00 	wl16	r0,0x0
  e8:	0d 60 00 04 	wh16	r0,0x4
  ec:	1e 40 00 00 	sridtw	r0
  f0:	24 40 00 00 	idts
  f4:	1c b0 00 01 	srieiw	0x1
  f8:	0d c0 00 00 	clr	r0
  fc:	0d c0 00 20 	clr	r1
 100:	00 e0 00 01 	div	r0,r1
 104:	14 30 00 00 	br	104 <clr_idt_lp+0x88>,#al

00000108 <test0>:
 108:	20 00 00 00 	nop
 10c:	0d c0 00 00 	clr	r0
 110:	0d 40 30 18 	wl16	r0,0x198
 114:	0d 40 02 00 	wl16	r16,0x0
 118:	0d 60 02 04 	wh16	r16,0x4
 11c:	00 00 02 00 	add	r16,r0
 120:	0d 40 02 23 	wl16	r17,0x3
 124:	0d 60 02 20 	wh16	r17,0x0
 128:	0d 40 2e 40 	wl16	r18,0x160
 12c:	0d 60 02 40 	wh16	r18,0x0
 130:	10 a0 02 30 	st32	r17,r16
 134:	00 10 02 04 	add	r16,4
 138:	10 a0 02 50 	st32	r18,r16
 13c:	0d 40 00 00 	wl16	r0,0x0
 140:	0d 60 00 04 	wh16	r0,0x4
 144:	1e 40 00 00 	sridtw	r0
 148:	24 40 00 00 	idts
 14c:	1c b0 00 01 	srieiw	0x1
 150:	0d c0 00 00 	clr	r0
 154:	0d c0 00 20 	clr	r1
 158:	00 e0 00 01 	div	r0,r1
 15c:	14 30 00 04 	br	16c <test1_return>,#al

00000160 <test1_irq>:
 160:	20 00 00 00 	nop
 164:	14 60 00 00 	ib
 168:	14 30 00 00 	br	168 <test1_irq+0x8>,#al

0000016c <test1_return>:
 16c:	20 00 00 00 	nop

00000170 <test_end>:
 170:	14 30 ff bc 	br	60 <finish>,#al

Disassembly of section .assert:

00020000 <CHECK_FLAG>:
   20000:	00 00 00 01 	add	r0,r1

00020004 <CHECK_FINISH>:
   20004:	00 00 00 00 	add	r0,r0

00020008 <CHECK_LOG>:
   20008:	00 00 00 00 	add	r0,r0

0002000c <ERROR_TYPE>:
   2000c:	00 00 00 00 	add	r0,r0

00020010 <ERROR_NUMBER>:
   20010:	00 00 00 00 	add	r0,r0

00020014 <ERROR_RESULT>:
   20014:	00 00 00 00 	add	r0,r0

00020018 <ERROR_EXPECT>:
   20018:	00 00 00 00 	add	r0,r0

Disassembly of section .idt:

00040000 <idt_label>:
   40000:	20 00 00 00 	nop
   40004:	20 00 00 00 	nop

Disassembly of section .stack:

000f0000 <STACK_INDEX>:
   f0000:	00 00 00 00 	add	r0,r0
