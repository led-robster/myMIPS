# TEST CAMPAIGN

## 1. TEST EVERY INSTRUCTION

Every instruction is fed into the ROM.  
Waveform inspection.
This test takes into account instruction interactions, since there is no stand-alone instruction.

|instruction under test|test no.|S/F|
|----------------------|--------|---|


>  when can we say that the unit is valid?
1. runs the instruction  
    1.2 DE - decodes correctly  
    1.3 EXE - alu has the correct operands and alu command  
    1.4 MEM - correct access to ram1 (, correct address)  
        1.4.1 read/write  
        1.4.2 correct address  
        1.4.3 correct data in, correct data out  
    1.5 WB - correct writeback  
    1.6 correct PC update  
    1.7 populates the register file (cycle delay)  
