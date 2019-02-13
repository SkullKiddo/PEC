movi r6, 0x0A
movhi r6, 0xC0
movi r3, 0x0A 
movi r2, 0xFF
out 9, r2
llegir: in r1, 16
bz r1, llegir
in r1, 15 
out 16, r0
out 5, r3
out 8, r6
jmp r6