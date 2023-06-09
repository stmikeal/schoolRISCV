#ifndef _FUN
#define _FUN

.macro fun rd, rs1, rs2, f7=0b0000000, f3=000, opcode=1110111
    .word   \f7\rs1\rs2\f3\rd\opcode
.endm

#endif