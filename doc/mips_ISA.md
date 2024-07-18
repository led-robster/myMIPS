MIPS ISA instructions comprise:
|Name|Assembly code|Operation|Format|Comments|Include in MIPS16?|
|----|-------------|---------|------|--------|------------------|
|add|add $s1,$s2,$s3|$s1=$s2+$s3|R|overflow detection|Y|
|subtract|sub $s1,$s2,$s3|$s1=$s2-$s3|R|overflow detection|Y|
|add immediate|addi $s1,$s2,k||I||Y|
|add unsigned|addu $s1,$s2,$s3||R||N|
|subtract unsigned|subu $s1,$s2,$s3||R||N|
|add immediate unsigned|addiu $s1,$s2,k||||N|
|move from coprocessor register|mfc0 $s1,$epc|$s1=$epc|R||Y|
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