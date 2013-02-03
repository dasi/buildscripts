	.section .text
	.align	1
	.global	_start
#---------------------------------------------------------------------------------
_start:
#---------------------------------------------------------------------------------
	movhi	hi(__stack), r0, sp
	movea	lo(__stack), sp, sp
	movhi	hi(__gp), r0, gp
	movea	lo(__gp), gp, gp

	movhi	0x0001, r0, r1
	ldsr	r1, psw
	ldsr	r0, chcw

	movea	0x2000, r0, r6
DummyLoop:
	add		-1, r6
	bnz		DummyLoop

/* Copy data section from LMA to VMA (ROM to RAM) */
	movhi	hi(__data_lma), r0, r6
	movea	lo(__data_lma), r6, r6
	movhi	hi(__data_end), r0, r7
	movea	lo(__data_end), r7, r7
	movhi	hi(__data_start), r0, r8
	movea	lo(__data_start), r8, r8

	jr		end_initdata
initdata:
	ld.b	0[r6],r9
	st.b	r9,0[r8]
	add		1,r6
	add		1,r8
end_initdata:
	cmp		r7,r8
	blt		initdata

/* Clear bss section and unintialised WRAM */
	movhi	0x0501, r0, r6
	jr		loop_start1
loop_top1:
	st.h	r0, 0[r7]
	add		2, r7
loop_start1:
	cmp		r6, r7
	blt		loop_top1

/* Clear VRM and DRAM to zero */
	movhi	4, r0, r6
ClrLoop:
	add		-4, r6
	st.w	r0, 0[r6]
	bnz		ClrLoop

/* Jump to user code */
	movhi	hi(__end), r0, r31
	movea	lo(__end), r31, r31

	movhi	hi(_main), r0, r1
	movea	lo(_main), r1, r1
	jmp		[r1]

__end:

/* Reset when main returns */
	movhi   hi(_reset_vector), r0, r31
	movea	lo(_reset_vector), r31, r31
	jmp		[r31]


	.section ".vectors", "ax"
	.align	1
#---------------------------------------------------------------------------------
_rom_header:
#---------------------------------------------------------------------------------
	.fill	20,1,0		# Game Title (7FFFDE0h)
	.fill	5,1,0		# unused
	.fill	2,1,0		# Maker Code
	.ascii	"V  E"		# Game Code
	.byte	0x00		# Software Version No (7FFFDFFh)

#---------------------------------------------------------------------------------
_interrupt_handler_table:
#---------------------------------------------------------------------------------
    /* INTKEY (7FFFE00h) - Controller Interrupt */
	br		_int_handler
	.fill	0x0E,1,0xFF

    /* INTTIM (7FFFE10h) - Timer Interrupt */
	br		_int_handler
	.fill	0x0E,1,0xFF

    /* INTCRO (7FFFE20h) - Expansion Port Interrupt */
	br		_int_handler
	.fill	0x0E,1,0xFF

    /* INTCOM (7FFFE30h) - Link Port Interrupt */
	br		_int_handler
	.fill	0x0E,1,0xFF

    /* INTVPU (7FFFE40h) - VIP Interrupt */
	br		_int_handler
	.fill	0x0E,1,0xFF

_int_handler:
	# Get the handler address
	stsr	ecr, r1
	andi	0x00F0, r1, r1
	shr		2, r1
	movhi	0x0600, r1, r1
	ld.w	0xFFD0[r1], r1

	# Call the handler function
	addi	-88, sp, sp
	st.w	r31, 16[sp]
	st.w	r30, 20[sp]
	st.w	r19, 24[sp]
	st.w	r18, 28[sp]
	st.w	r17, 32[sp]
	st.w	r16, 36[sp]
	st.w	r15, 40[sp]
	st.w	r14, 44[sp]
	st.w	r13, 48[sp]
	st.w	r12, 52[sp]
	st.w	r11, 56[sp]
	st.w	r10, 60[sp]
	st.w	r9, 64[sp]
	st.w	r8, 68[sp]
	st.w	r7, 72[sp]
	st.w	r6, 76[sp]
	st.w	r5, 80[sp]
	st.w	r2, 84[sp]

	movhi	hi(_int_handler_return), r0, r31
	movea	lo(_int_handler_return), r31, r31
	jmp		[r1]
_int_handler_return:
	# Return from the handler function
	ld.w	16[sp], r31
	ld.w	20[sp], r30
	ld.w	24[sp], r19
	ld.w	28[sp], r18
	ld.w	32[sp], r17
	ld.w	36[sp], r16
	ld.w	40[sp], r15
	ld.w	44[sp], r14
	ld.w	48[sp], r13
	ld.w	52[sp], r12
	ld.w	56[sp], r11
	ld.w	60[sp], r10
	ld.w	64[sp], r9
	ld.w	68[sp], r8
	ld.w	72[sp], r7
	ld.w	76[sp], r6
	ld.w	80[sp], r5
	ld.w	84[sp], r2
	addi	88, sp, sp
	reti

	.fill	0x5C,1,0xFF

    /* (7FFFF60h) - Float exception */
	reti
	.fill	0x0E,1,0xFF

    /* Unused vector */
	.fill	0x10,1,0xFF

    /* (7FFFF80h) - Divide by zero exception */
	reti
	.fill	0x0E,1,0xFF

    /* (7FFFF90h) - Invalid Opcode exception */
	reti
	.fill	0x0E,1,0xFF

    /* (7FFFFA0h) - Trap 0 exception */
	reti
	.fill	0x0E,1,0xFF

    /* (7FFFFB0h) - Trap 1 exception */
	reti
	.fill	0x0E,1,0xFF

    /* (7FFFFC0h) - Trap Address exception */
	reti
	.fill	0x0E,1,0xFF

    /* (7FFFFD0h) - NMI/Duplex exception */
	halt
	.fill	0x0E,1,0xFF

    /* Unused vector */
	.fill	0x10,1,0xFF

    /* Reset Vector (7FFFFF0h) - program start address */

	.global _reset_vector
#---------------------------------------------------------------------------------
_reset_vector:
#---------------------------------------------------------------------------------
	movhi	hi(_start), r0, r1
	movea	lo(_start), r1, r1
	jmp		[r1]
	.fill	0x06,1,0xFF
