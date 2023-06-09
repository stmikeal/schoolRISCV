.text

start: 
    li x10, 0
    li x11, 1
    blt x11, x10, end 
    li x12, 2
    li x10, 8
    blt x12, x10, end
    li x10, 16
    li x11, 16
    li x12, 16


end: beqz zero, end
