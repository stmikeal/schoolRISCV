#include "fun_macro.h"
#include "reg_codes.h"

start: 
    li x10, 0
    li x11, 1
    li x12, 1
    fun rx10, rx11, rx12
    li x12, 0   