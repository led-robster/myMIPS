from have_fun import print__pointy_separator
import os
import sys

# Get the absolute path of the current script and construct the path to 'program.casm'
script_dir = os.path.dirname(__file__)
asm_path = os.path.join(script_dir, 'program.casm')
bins_path = os.path.join(script_dir, 'program.bins')

R_ops = ["add", "sub", "and", "or", "slt", "sll", "srl", "jr"]
I_ops = ["addi", "slti", "lw", "sw", "beq"]
J_ops = ["j", "jal"]

reg_dict = {"$r0": "000",
            "$r1": "001",
            "$r2": "010",
            "$r3": "011",
            "$r4": "100",
            "$r5": "101",
            "$r6": "110",
            "$r7": "111"
            }

Fcode_dict = {"add": "000",
                "sub": "001",
                "and": "010",
                "or": "011",
                "slt": "100",
                "sll": "101",
                "srl": "110",
                "jr": "111"
            }

Icode_dict = {"addi": "0001",
              "slti": "0011",
              "lw": "0100",
              "sw": "0101",
              "beq": "0110"}

Jcode_dict = {"j": "0111",
              "jal": "1000"}

# '$r0' -> 000 ; '$r1' -> 001 ; ...
def assign_reg_bin(reg):
    return reg_dict[reg]

def check_range(imm, bit_size):
    # immediates are 6 bit wide
    if int(imm)>((2**bit_size)-1):
        return False
    else:
        return True

def assign_imm_bin(imm):
    if imm[0]=='d':
        # decimal
        integer_value = int(imm[2:])
        binary_string = bin(integer_value)[2:]
        binary_string_padded = binary_string.zfill(6)
        ret_val = binary_string_padded

    elif imm[0]=='b':
        # binary
        binary_string = imm[2:].zfill(6)
        ret_val = binary_string

    elif imm[0]=='h':
        # hexadecimal
        # h'22 -> 00100010
        integer_value = int(imm[2:], 16)
        binary_string = bin(integer_value)[2:]
        binary_string_padded = binary_string.zfill(6)
        ret_val = binary_string_padded

    return ret_val

def assign_shamt_bin(shamt):

    if shamt[0]=='d':
        # decimal
        integer_value = int(shamt[2:])
        binary_string = bin(integer_value)[2:]
        binary_string_padded = binary_string.zfill(3)
        ret_val = binary_string_padded

    elif shamt[0]=='b':
        # binary
        integer_value = int(shamt[2:],2)
        binary_string = shamt[2:].zfill(3)
        ret_val = binary_string

    elif shamt[0]=='h':
        # hexadecimal
        # h'22 -> 00100010
        integer_value = int(shamt, 16)
        binary_string = bin(integer_value)[2:]
        binary_string_padded = binary_string.zfill(3)
        ret_val = binary_string_padded

    if check_range(integer_value,3):
        pass
    else:
        print("ERROR!!!")
        sys.exit(1)

    return ret_val

def assign_addr_bin(addr):
    if addr[0]=='d':
        # decimal
        integer_value = int(addr[2:])
        binary_string = bin(integer_value)[2:]
        binary_string_padded = binary_string.zfill(12)
        ret_val = binary_string_padded

    elif addr[0]=='b':
        # binary
        binary_string = addr[2:].zfill(12)
        ret_val = binary_string

    elif addr[0]=='h':
        # hexadecimal
        # h'22 -> 00100010
        integer_value = int(addr[2:], 16)
        binary_string = bin(integer_value)[2:]
        binary_string_padded = binary_string.zfill(12)
        ret_val = binary_string_padded

    return ret_val

def integer_it(fmt):
    if fmt[0]=='d':
        return int(fmt[2:])
    elif fmt[0]=='b':
        return int(fmt[2:],2)
    elif fmt[0]=='h':
        return int(fmt[2:],16)
    else:
        print("ERROR!!!")
        sys.exit(1)


def main():
    fh = open(asm_path, "r")
    fw = open(bins_path, "w")

    line_cnt = 0
    for line in fh.readlines():

        line_cnt += 1

        line_list = line.split(" ")

        if line_list[0]==";" or len(line_list)==1:
            # comment line
            continue

        new_line_list = []
        # remove whitespaces and commas
        for string in line_list:
            tmp_str = string.replace(" ","").replace(",", "").replace("\n", "")
            new_line_list.append(tmp_str)
        
        line_list = new_line_list

        opcode = line_list[0].lower()  

        if ';' in line_list:
            # comment in-line with code
            comment_ix = line_list.index(';')
            not_opcode = line_list[1:comment_ix]
        else:
            # line w/ only code
            not_opcode = line_list[1:]
            

        if opcode in R_ops:
            # R format
            rs = not_opcode[1]
            rt = not_opcode[2] # or shamt
            rd = not_opcode[0]
            Opcode_bin = "0000"
            rs_bin = assign_reg_bin(rs)
            if opcode=="sll" or opcode=="srl":
                rt_bin = assign_shamt_bin(rt)
            else:
                rt_bin = assign_reg_bin(rt)
            
            rd_bin = assign_reg_bin(rd)
            Fcode_bin = Fcode_dict[opcode]
            line_bin = Opcode_bin+rs_bin+rt_bin+rd_bin+Fcode_bin

        elif opcode in I_ops:
            rs = not_opcode[0]
            rt = not_opcode[1]
            immediate = not_opcode[2]
            immediate_int = integer_it(immediate)
            if check_range(immediate_int, 6):
                imm_bin = assign_imm_bin(immediate)
                rs_bin = assign_reg_bin(rs)
                rt_bin = assign_reg_bin(rt)
                Opcode_bin = Icode_dict[opcode]
                line_bin = Opcode_bin+rs_bin+rt_bin+imm_bin
            else:
                # not in range
                print("ERROR AT LINE " + str(line_cnt))
                print__pointy_separator()
                print("invalid immediate range. 6 bits allowed.")
                exit
            

        elif opcode in J_ops:
            address = not_opcode[0]
            addr_bin = assign_addr_bin(address)
            Opcode_bin = Jcode_dict[opcode]

        else :
            # invalid code
            print("ERROR AT LINE " + str(line_cnt))
            print__pointy_separator
            print("invalid opcode.")
            exit

        fw.write(line_bin+'\n')

    fw.close()
    fh.close()

    return



if __name__== "__main__":
    main()