MIPS ISA instructions include:
|Name|Assembly code|Operation|Format|Comments|Include in MIPS16?|
|----|-------------|---------|------|--------|------------------|
|add|add $s1,$s2,$s3|$s1=$s2+$s3|R|overflow detection|Y|
|subtract|sub $s1,$s2,$s3|$s1=$s2-$s3|R|overflow detection|Y|
|add immediate|addi $s1,$s2,k||I||Y|
|add unsigned|addu $s1,$s2,$s3||R||N|
|subtract unsigned|subu $s1,$s2,$s3||R||N|
|add immediate unsigned|addiu $s1,$s2,k||||N|
|move from coprocessor register|mfc0 $s1,$epc|$s1=$epc|R||N|
|multiply|mult $s2,$s3|Hi,Lo=$s2x$s3|R||Y|
|multiply unsigned|multu $s2,$s3|Hi,Lo=$s2x$s3|R||N|
|divide|div $s2,$s3|Lo=$s2/$s3, Hi=$s2mod$s3|R||Y|
|divide unsigned|divu $s2,$s3|''|R||N|
|move from Hi|mfhi $s1|$s1=Hi|R||Y|
|move from Lo|mflo $s1|$s1=Lo|R||Y|
|---|---|---|
|and|and $s1,$s2,$s3|$s1=$s2AND$s3|R||Y|
|or|or $s1,$s2,$s3||R||Y|
|and immediate|andi $s1,$s2,k||I||Y|
|or immediate|ori $s1,$s2,k||I||Y|
|shift left logical|sll $s1,$s2,k||R||Y|
|shift right logical|srl $s1,$s2,k||R||Y|
|---|---|---|
|load word|lw $s1,k($s2)||I||Y|
|store word|sw $s1,k($s2)||I||Y|
|load halfword|lh $s1,k($s2)||I||N|
|store halfword|sh $s1,k($s2)||I||N|
|load byte|lb $s1,k($s2)||I||N|
|store byte|sb $s1,k($s2)||I||N|
|load byte unsigned|lbu $s1,k($s2)||I||N|
|load upper immediate|lui $s1,k||I||N|
|---|---|---|
|branch on equal|beq $s1,$s2,k||I||Y|
|branch on not equal|bne $s1,$s2,k||I||N|
|set on less than|slt $s1,$s2,$s3||R||N|
|set on less than immediate|slti $s1,$s2,k||I||N|
|set on less than unsigned|sltu $s1,$s2,$s3||R||N|
|set on less than immediate unsigned|sltiu $s1,$s2,k||I||N|
|---|---|
|jump|j addr||J||Y|
|jump register|jr $reg||R||Y|
|jump and link|jal addr||J||Y|

### myMIPS ISA
* add
* subtract
* addi
* and
* or
* andi
* ori
* sll
* srl
* lw
* sw
* beq
* j
* jr
* jal

Number of registers : 8  
Width of registers : 16 bit



## INSTRUCTION FORMATs
In a 32bit MIPS yhe format is as listed below :

|format||||fields|||used by|
|------|-|-|-|-|-|------|-------|
||6 bits|5 bits|5 bits|5 bits|5 bits|6 bits||
|Rformat|opcode|rs|rt|rd|shamt|Fcode|ALU instructions. except immediate, jump register|
|Iformat|opcode|rs|rt|offset/immediate|load,store,immediate ALU,beq,bne|
|Jformat|opcode||||target address||Jump,jump and link|

**shamt** := shift amount

the opcode for R-format instructions is 0x0 except for mfc0 (but why?).

### myMIPS ISA table

|format||||fields||used by|
|------|-|-|-|-|-------|-|
||4 bits|3 bits|3 bits|3 bits|3 bits||
|Rformat|opcode|rs|rt|rd/shamt|Fcode|ALU instructions (except immediate), jump register|
|Iformat|opcode|rs|rt|offset/immediate||load,store,imnmediate ALU,beq,bne|
|Jformat|opcode|target address||||Jump,jump and link|

> IMPLICATIONS: the J format can address 12-bit target addresses (proper concatenation has to be applied). The 'jr' instruction can address $rx which is a 16-bit address.

|name|format|Bits 15-12|Bits 11-9|Bits 8-6|Bits 5-3|Bits 2-0|desc|
|-|-|-|-|-|-|-|-|
|add|R|0000|rs|rt|rd|000|
|subtract|R|0000|rs|rt|rd|001|
|addi|I|0001|rs|rt|imm|
|and|R|0000|rs|rt|rd|010|
|or|R|0000|rs|rt|rd|011|
|slt|R|0000|rs|rt|rd|100| 
|slti|I|0011|rs|rt|imm||
|sll|R|0000|rs|rt|shamt|101|
|srl|R|0000|rs|rt|shamt|110|
|lw|I|0100|rs|rt|offset||store RAM[$rs + offset] in $rt|
|sw|I|0101|rs|rt|offset||store $rt in RAM[$rs + offset]
|beq|I|0110|rs|rt|immediate||if ($rs==$rt) then branch to PC +2 +2*offset|
|j|J|0111|addr|||
|jr|R|0000|rs|0|0|111|
|jal|J|1000|addr||||same as j, but store PC in $ra|

## MEMORY ASPECTS

Memory is NOT byte-addressable, but word-addressable.  
Why this choice?  
Since there is no instruction suited for smaller or bigger words. For example in a32-bit MIPS the memory is byte-addressable since there are the reduced instructions like 'lb' to load a byte or 'lh' for loading halfwords.  
In a memory is important memory alignment to grant speed to overall instruction execution. For my solution I'm adopting a word-addressable memory, that is aligned by definition. This implementation has the **pro** that bypasses memory alignment checks (speeding architecture), and a **con** that doesn't implement byte operations, but since we dont care about those is not  a problem.   

## SPECIAL FUNCTION REGISTERS
The **ZERO** register.  
The **RETURN ADDRESS** register.  
the **ALU STATUS** register.  
The **PC**.  
The **ERROR CODE** register.
