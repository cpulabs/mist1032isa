
./out/irq_utim64.out:     file format elf32-mist32


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

000000b4 <check0>:
  b4:	0d c0 00 00 	clr	r0
  b8:	0d 40 24 00 	wl16	r0,0x120
  bc:	0d 40 02 00 	wl16	r16,0x0
  c0:	0d 60 02 04 	wh16	r16,0x4
  c4:	00 00 02 00 	add	r16,r0
  c8:	0d 40 02 23 	wl16	r17,0x3
  cc:	0d 60 02 20 	wh16	r17,0x0
  d0:	0d 40 2e 50 	wl16	r18,0x170
  d4:	0d 60 02 40 	wh16	r18,0x0
  d8:	10 a0 02 30 	st32	r17,r16
  dc:	00 10 02 04 	add	r16,4
  e0:	10 a0 02 50 	st32	r18,r16
  e4:	0d 40 00 00 	wl16	r0,0x0
  e8:	0d 60 00 04 	wh16	r0,0x4
  ec:	1e 40 00 00 	sridtw	r0
  f0:	24 40 00 00 	idts
  f4:	1c b0 00 01 	srieiw	0x1
  f8:	0d c0 00 40 	clr	r2
  fc:	00 10 00 43 	add	r2,3
 100:	19 60 00 20 	sriosr	r1
 104:	0d c0 00 e0 	clr	rtmp
 108:	10 a0 00 e1 	st32	rtmp,r1
 10c:	0d c0 00 e0 	clr	rtmp
 110:	20 40 00 01 	move	r0,r1
 114:	00 10 00 04 	add	r0,4
 118:	10 a0 00 e0 	st32	rtmp,r0
 11c:	00 10 00 04 	add	r0,4
 120:	10 a0 00 e0 	st32	rtmp,r0
 124:	0d c0 00 e0 	clr	rtmp
 128:	20 40 00 01 	move	r0,r1
 12c:	00 10 00 0c 	add	r0,12
 130:	00 10 00 e0 	add	rtmp,0
 134:	10 a0 00 e0 	st32	rtmp,r0
 138:	0d c0 00 e0 	clr	rtmp
 13c:	20 40 00 01 	move	r0,r1
 140:	00 10 00 10 	add	r0,16
 144:	00 10 04 e0 	add	rtmp,32
 148:	10 a0 00 e0 	st32	rtmp,r0
 14c:	0d c0 00 e0 	clr	rtmp
 150:	20 40 00 01 	move	r0,r1
 154:	00 10 04 0c 	add	r0,44
 158:	00 00 00 e2 	add	rtmp,r2
 15c:	10 a0 00 e0 	st32	rtmp,r0
 160:	0d c0 00 e0 	clr	rtmp
 164:	00 10 00 e1 	add	rtmp,1
 168:	10 a0 00 e1 	st32	rtmp,r1
 16c:	14 30 00 00 	br	16c <check0+0xb8>,#al

00000170 <check0_hdl>:
 170:	19 60 00 20 	sriosr	r1
 174:	20 40 00 01 	move	r0,r1
 178:	00 10 0c 1c 	add	r0,124
 17c:	10 40 00 e0 	ld32	rtmp,r0
 180:	20 40 00 07 	move	r0,rtmp
 184:	00 d0 00 01 	cmp	r0,1
 188:	14 32 ff a6 	br	20 <error>,#ne

0000018c <check1>:
 18c:	0d c0 00 00 	clr	r0
 190:	0d 40 24 00 	wl16	r0,0x120
 194:	0d 40 02 00 	wl16	r16,0x0
 198:	0d 60 02 04 	wh16	r16,0x4
 19c:	00 00 02 00 	add	r16,r0
 1a0:	0d 40 02 23 	wl16	r17,0x3
 1a4:	0d 60 02 20 	wh16	r17,0x0
 1a8:	0d 40 4a 54 	wl16	r18,0x254
 1ac:	0d 60 02 40 	wh16	r18,0x0
 1b0:	10 a0 02 30 	st32	r17,r16
 1b4:	00 10 02 04 	add	r16,4
 1b8:	10 a0 02 50 	st32	r18,r16
 1bc:	0d 40 00 00 	wl16	r0,0x0
 1c0:	0d 60 00 04 	wh16	r0,0x4
 1c4:	1e 40 00 00 	sridtw	r0
 1c8:	24 40 00 00 	idts
 1cc:	1c b0 00 01 	srieiw	0x1
 1d0:	0d c0 00 40 	clr	r2
 1d4:	00 10 00 43 	add	r2,3
 1d8:	19 60 00 20 	sriosr	r1
 1dc:	0d c0 00 e0 	clr	rtmp
 1e0:	10 a0 00 e1 	st32	rtmp,r1
 1e4:	0d c0 00 e0 	clr	rtmp
 1e8:	20 40 00 01 	move	r0,r1
 1ec:	00 10 00 04 	add	r0,4
 1f0:	10 a0 00 e0 	st32	rtmp,r0
 1f4:	00 10 00 04 	add	r0,4
 1f8:	10 a0 00 e0 	st32	rtmp,r0
 1fc:	0d c0 00 e0 	clr	rtmp
 200:	20 40 00 01 	move	r0,r1
 204:	00 10 00 0c 	add	r0,12
 208:	00 10 00 e0 	add	rtmp,0
 20c:	10 a0 00 e0 	st32	rtmp,r0
 210:	0d c0 00 e0 	clr	rtmp
 214:	20 40 00 01 	move	r0,r1
 218:	00 10 00 10 	add	r0,16
 21c:	00 10 04 e0 	add	rtmp,32
 220:	10 a0 00 e0 	st32	rtmp,r0
 224:	0d c0 00 e0 	clr	rtmp
 228:	20 40 00 01 	move	r0,r1
 22c:	00 10 04 0c 	add	r0,44
 230:	00 00 00 e2 	add	rtmp,r2
 234:	10 a0 00 e0 	st32	rtmp,r0
 238:	0d c0 00 e0 	clr	rtmp
 23c:	00 10 00 e1 	add	rtmp,1
 240:	10 a0 00 e1 	st32	rtmp,r1
 244:	0d c0 01 00 	clr	r8

00000248 <check1_wait>:
 248:	00 d0 01 01 	cmp	r8,1
 24c:	14 32 ff ff 	br	248 <check1_wait>,#ne
 250:	14 30 00 0a 	br	278 <check1_ok>,#al

00000254 <check1_hdl>:
 254:	19 60 00 20 	sriosr	r1
 258:	20 40 00 01 	move	r0,r1
 25c:	00 10 0c 1c 	add	r0,124
 260:	10 40 00 e0 	ld32	rtmp,r0
 264:	20 40 00 07 	move	r0,rtmp
 268:	00 d0 00 01 	cmp	r0,1
 26c:	14 32 ff 6d 	br	20 <error>,#ne
 270:	02 00 01 08 	inc	r8,r8
 274:	14 60 00 00 	ib

00000278 <check1_ok>:
 278:	20 00 00 00 	nop

0000027c <check2>:
 27c:	0d c0 00 00 	clr	r0
 280:	0d 40 24 00 	wl16	r0,0x120
 284:	0d 40 02 00 	wl16	r16,0x0
 288:	0d 60 02 04 	wh16	r16,0x4
 28c:	00 00 02 00 	add	r16,r0
 290:	0d 40 02 23 	wl16	r17,0x3
 294:	0d 60 02 20 	wh16	r17,0x0
 298:	0d 40 6a 50 	wl16	r18,0x350
 29c:	0d 60 02 40 	wh16	r18,0x0
 2a0:	10 a0 02 30 	st32	r17,r16
 2a4:	00 10 02 04 	add	r16,4
 2a8:	10 a0 02 50 	st32	r18,r16
 2ac:	0d 40 00 00 	wl16	r0,0x0
 2b0:	0d 60 00 04 	wh16	r0,0x4
 2b4:	1e 40 00 00 	sridtw	r0
 2b8:	24 40 00 00 	idts
 2bc:	1c b0 00 01 	srieiw	0x1
 2c0:	0d c0 00 40 	clr	r2
 2c4:	00 10 00 4b 	add	r2,11
 2c8:	19 60 00 20 	sriosr	r1
 2cc:	0d c0 00 e0 	clr	rtmp
 2d0:	10 a0 00 e1 	st32	rtmp,r1
 2d4:	0d c0 00 e0 	clr	rtmp
 2d8:	20 40 00 01 	move	r0,r1
 2dc:	00 10 00 04 	add	r0,4
 2e0:	10 a0 00 e0 	st32	rtmp,r0
 2e4:	00 10 00 04 	add	r0,4
 2e8:	10 a0 00 e0 	st32	rtmp,r0
 2ec:	0d c0 00 e0 	clr	rtmp
 2f0:	20 40 00 01 	move	r0,r1
 2f4:	00 10 00 0c 	add	r0,12
 2f8:	00 10 00 e0 	add	rtmp,0
 2fc:	10 a0 00 e0 	st32	rtmp,r0
 300:	0d c0 00 e0 	clr	rtmp
 304:	20 40 00 01 	move	r0,r1
 308:	00 10 00 10 	add	r0,16
 30c:	00 10 04 e0 	add	rtmp,32
 310:	10 a0 00 e0 	st32	rtmp,r0
 314:	0d c0 00 e0 	clr	rtmp
 318:	20 40 00 01 	move	r0,r1
 31c:	00 10 04 0c 	add	r0,44
 320:	00 00 00 e2 	add	rtmp,r2
 324:	10 a0 00 e0 	st32	rtmp,r0
 328:	0d c0 00 e0 	clr	rtmp
 32c:	00 10 00 e1 	add	rtmp,1
 330:	10 a0 00 e1 	st32	rtmp,r1
 334:	0d c0 01 00 	clr	r8

00000338 <check2_wait>:
 338:	00 d0 01 04 	cmp	r8,4
 33c:	14 32 ff ff 	br	338 <check2_wait>,#ne
 340:	19 60 00 20 	sriosr	r1
 344:	0d c0 02 00 	clr	r16
 348:	10 a0 02 01 	st32	r16,r1
 34c:	14 30 00 0a 	br	374 <check2_ok>,#al

00000350 <check2_hdl>:
 350:	19 60 00 20 	sriosr	r1
 354:	20 40 00 01 	move	r0,r1
 358:	00 10 0c 1c 	add	r0,124
 35c:	10 40 00 e0 	ld32	rtmp,r0
 360:	20 40 00 07 	move	r0,rtmp
 364:	00 d0 00 01 	cmp	r0,1
 368:	14 32 ff 2e 	br	20 <error>,#ne
 36c:	02 00 01 08 	inc	r8,r8
 370:	14 60 00 00 	ib

00000374 <check2_ok>:
 374:	20 00 00 00 	nop

00000378 <test_end>:
 378:	14 30 ff 3a 	br	60 <finish>,#al

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
