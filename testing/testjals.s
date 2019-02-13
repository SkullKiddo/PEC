movi R1, 0x06
movhi R1, 0xC0 
jal R1, R1
halt
movi R2, 0xFF
jmp R1