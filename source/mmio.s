/*
 *   This file is part of fastboot 3DS
 *   Copyright (C) 2019 Aurora Wright, TuxSH, derrek, profi200
 *
 *   This program is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

@ Based on https://github.com/AuroraWright/Luma3DS/blob/master/arm9/source/alignedseqmemcpy.s

#include "asm_macros.h"

.syntax unified
.cpu arm946e-s
.fpu softvfp



@ void iomemcpy(vu32 *restrict dst, const vu32 *restrict src, u32 size)
BEGIN_ASM_FUNC iomemcpy
	bics    r12, r2, #31
	beq     iomemcpy_test_words
	stmfd   sp!, {r4-r10}
	iomemcpy_blocks_lp:
		ldmia  r1!, {r3-r10}
		subs   r12, #32
		stmia  r0!, {r3-r10}
		bne    iomemcpy_blocks_lp
	ldmfd   sp!, {r4-r10}
iomemcpy_test_words:
	ands    r12, r2, #28
	beq     iomemcpy_halfword_byte
	iomemcpy_words_lp:
		ldr    r3, [r1], #4
		subs   r12, #4
		str    r3, [r0], #4
		bne    iomemcpy_words_lp
iomemcpy_halfword_byte:
	tst     r2, #2
	ldrhne  r3, [r1], #2
	strhne  r3, [r0], #2
	tst     r2, #1
	ldrbne  r3, [r1]
	strbne  r3, [r0]
	bx      lr
END_ASM_FUNC


@ void iomemset(vu32 *ptr, u32 value, u32 size)
BEGIN_ASM_FUNC iomemset
	bics    r12, r2, #31
	beq     iomemset_test_words
	stmfd   sp!, {r4-r9}
	mov     r3, r1
	mov     r4, r1
	mov     r5, r1
	mov     r6, r1
	mov     r7, r1
	mov     r8, r1
	mov     r9, r1
	iomemset_blocks_lp:
		stmia  r0!, {r1, r3-r9}
		subs   r12, #32
		bne    iomemset_blocks_lp
	ldmfd   sp!, {r4-r9}
iomemset_test_words:
	ands    r12, r2, #28
	beq     iomemset_halfword_byte
	iomemset_words_lp:
		subs   r12, #4
		str    r1, [r0], #4
		bne    iomemset_words_lp
iomemset_halfword_byte:
	tst     r2, #2
	strhne  r1, [r0], #2
	tst     r2, #1
	strbne  r1, [r0]
	bx      lr
END_ASM_FUNC
