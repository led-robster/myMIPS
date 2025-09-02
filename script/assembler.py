# USAGE: py assembler.py program.casm

# general TODO : build an ad-hoc error logging system, --debug , -d

from have_fun import print__pointy_separator
import os
import sys
import argparse

print("argparse version: " + argparse.__version__)

# ===========================================================
#                       PARSER
# ===========================================================
parser = argparse.ArgumentParser(
            prog='assembler',
            description='CASM assembler',
            epilog="All rights registered @ led-robster.ecorp"
            )
# ADD PARSER ARGS
parser.add_argument('filename')
parser.add_argument('-d', '--dbgasm', action='store_true')
# PARSE
args= parser.parse_args()

casm_fn = args.filename
if args.dbgasm:
    print("REFERENCE is going to be generated.")
else:
    print("REFERENCE is NOT going to be generated.")


# ===========================================================
#           FILE PATH MANAGEMENT
# ===========================================================
# Get the absolute path of the current script and construct the path to 'program.casm'
script_dir = os.path.dirname(__file__)
asm_path = os.path.join(script_dir, casm_fn)
bins_path = os.path.join(script_dir, 'program.bins')
ref_path  = os.path.join(script_dir, 'ref_casm.txt')

# ===========================================================
#           SYSTEM PARAMETER
# ===========================================================
"""
    GENERATE_REF is a boolean, when True then the ref_casm.txt is generated based on passed casm file.
    Inherits argument functionality.
"""
if args.dbgasm:
    GENERATE_REF = True
else:
    GENERATE_REF = False

# ===========================================================
#           CONSTANTS, DICTS & LISTS
# ===========================================================
BANNER = "XX.YY.ZZ INSTRUCTION SNAPSHOT: D        | E        | MA        | WB        |\n" \
"=================================================================\n"

R_ops = ["add", "sub", "and", "or", "slt", "sll", "srl", "jr"]
I_ops = ["addi", "slti", "lw", "sw", "beq"]
J_ops = ["j", "jal"]

"""
    Mapping register literal to its binary value.
"""
reg_dict = {"$r0": "000",
            "$r1": "001",
            "$r2": "010",
            "$r3": "011",
            "$r4": "100",
            "$r5": "101",
            "$r6": "110",
            "$r7": "111"
            }

"""
    Mapping code literal to its binary value.
"""
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


# ===========================================================
# SNAP RAM
# ===========================================================
RAM_SIZE = 256
snap_ram_keys = [str(x) for x in range(0,RAM_SIZE)]
snap_ram_values = [0 for x in range(0, RAM_SIZE)]
snap_ram= {k:v for (k,v) in zip(snap_ram_keys, snap_ram_values)}


# ===========================================================
# SNAP REGFILE
# ===========================================================
"""
    The snap_regfile is a fundamental variable when generating the ref_casm.txt. Its role is to register a snapshot of the current state of the regfile,
    as expected by the casm file. Having a copy of the regfile expected and comparing it with the regfile in Verilog, provides a fundamental diff for validating the design.
    N.B.: this has the strong side of validating also the hazard_unit with the forwarding technique.
"""
# SNAPSHOT of the regfile, cycle accurate
snap_regfile = {"0": 0,
                "1": 0,
                "2": 0,
                "3": 0,
                "4": 0,
                "5": 0,
                "6": 0,
                "7": 0,
                "8": 0,
                "9": 0,
                "10": 0,
                "11": 0,
                "12": 0,
                "13": 0,
                "14": 0,
                "15": 0,
                "XXX": "XXX"}
"""
    update_snap(regd, value) ; updates the snap_regfile with a specified value at the specified register
    regd: int, destination register
    value: int, value that updates the snap_regfile
"""
def update_snap(regd: int, value: int):
    snap_regfile[regd] = value
    return value


"""
    assign_reg_bin(reg) ; e.g. translates "$r1" in "001"
    reg: string, register to find dictonary correspondence
    return value: string, binary string
"""
# '$r0' -> 000 ; '$r1' -> 001 ; ...
def assign_reg_bin(reg):
    return reg_dict[reg]


"""
    check_value_from_bitsize(value, bitsize) ; checks if the value is in the specified range based on bitsize ; e.g. check_value_from_bitsize(300, 4)=False
    value: int, immediate value
    bitsize: int, specifies the range upper limit = 2**(bit_size)-1
"""
def check_value_from_bitsize(value: int, bitsize: int):
    if int(value)>((2**bitsize)-1):
        return False
    else:
        return True
    
"""
    check_range_imm(imm, bit_size) ; checks if the immediate is in the specified range based on bit_size ; e.g. check_range_imm(300, 4)=False
    imm: string, immediate value
    bit_size: int, specifies the range upper limit = 2**(bit_size)-1
"""
def check_range_imm(imm, bit_size):
    return check_value_from_bitsize(int(imm), bit_size)


"""
    assign_imm_bin(imm) ; converts immediate string in binary string of length=6 bits, as in SPECS. Accepts the format d'10, h'A and b'1010
    imm: string, immediate value
"""
def assign_imm_bin(imm):
    if imm[0]=='d':
        # decimal
        integer_value = int(imm[2:])
        binary_string = bin(integer_value)[2:]
        if integer_value>2**6-1:
            binary_string_padded = binary_string[-7:-1]
        else:
            binary_string_padded = binary_string.zfill(6)
        ret_val = binary_string_padded

    elif imm[0]=='b':
        # binary
        binary_string = imm[2:]
        if len(binary_string)>6:
            binary_string = binary_string[-7:-1]
        else:
            binary_string = imm[2:].zfill(6)

        ret_val = binary_string

    elif imm[0]=='h':
        # hexadecimal
        # h'22 -> 00100010
        integer_value = int(imm[2:], 16)
        binary_string = bin(integer_value)[2:]
        if integer_value>2**6-1:
            binary_string_padded = binary_string[-7:-1]
        else:
            binary_string_padded = binary_string.zfill(6)
        ret_val = binary_string_padded

    return ret_val


"""
    assign_shamt_bin(shamt) ; converts shamt string in binary string of length=3 bits, as in SPECS. Accepts the format d'10, h'A and b'1010
    shamt: string, immediate value
"""
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

    if check_range_imm(integer_value,3):
        pass
    else:
        print("ERROR!!!")
        sys.exit(1)

    return ret_val


"""
    assign_addr_bin(addr) ; converts addr string in binary string of length=12 bits, as in SPECS. This is udes for J instructions. Accepts the format d'10, h'A and b'1010.
    addr: string, jump value
"""
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


"""
    integer_it(fmt) ; EX.: converts d'10 in 10 ; EX.: converts h'B in 11
    fmt: string
    return value: int
"""
def integer_it(fmt):
    if fmt[0]=='d':
        return int(fmt[2:])
    elif fmt[0]=='b':
        return int(fmt[2:],2)
    elif fmt[0]=='h':
        return int(fmt[2:],16)
    else:
        print("[!] During integer_it found a bad representation. Literals can be represented in three ways: d'10, h'0A, b'1010. Make sure to input a valid format.")
        sys.exit(1)


# =================================================================================================================================================================================
#                                                                    __  __       _       
#                                                                   |  \/  |     (_)      
#                                                                   | \  / | __ _ _ _ __  
#                                                                   | |\/| |/ _` | | '_ \ 
#                                                                   | |  | | (_| | | | | |
#                                                                   |_|  |_|\__,_|_|_| |_|
#                                                                                        
# =================================================================================================================================================================================
def main():
    fh = open(asm_path, "r")
    fw = open(bins_path, "w") #file that goes into program.mem

    if GENERATE_REF:
        # GENERATE_REF local variables
        fref = open(ref_path, 'w') #reference file
        regfile_content="" #text block containing the body of regfile contents
        instr_pipeline = ["XXX", "XXX", "XXX", "XXX"] #keeps track of instructions processed, functions as in HW pipeline
        rs_pipeline = ["XXX", "XXX", "XXX", "XXX"] #keeps track of rs processed, functions as in HW pipeline
        rt_pipeline = ["XXX", "XXX", "XXX", "XXX"] #keeps track of rt processed, functions as in HW pipeline
        rdestination_pipeline = ["XXX", "XXX", "XXX", "XXX"] #keeps track of rd processed, functions as in HW pipeline
        we_pipeline = [0,0,0,0]
        we=0
        ram_we = 0
        ram_we_pipeline = [0,0,0,0]
        ram_wdata = 0
        ram_wdata_pipeline = [0,0,0,0]
        ram_waddr = 0
        ram_waddr_pipeline = [0,0,0,0]
        register_source = 0 #str, the rs of current instruction
        register_temp = 0 #str, the rt of current instruction
        register_dest = 0 #str, the rd of current instruction
        wdata_pipeline = [0,0,0,0]



    line_cnt = 0 #file line counter


    for line in fh.readlines():

        # default
        we=0
        ram_we = 0
        ram_wdata = 0
        ram_waddr=0

        # update snap_regfile pipeline

        line = line.strip() #strip /n

        line = line.lstrip() #remove leading blankspaces

        line_cnt += 1 #increase counter

        # print line advancement
        if line_cnt%5==0:
            print(line_cnt)

        # split line into string list
        line_list = line.split(" ")

        # handle comment line
        if line_list[0]==";":
            continue

        new_line_list = []
        # remove whitespaces, commas and ; when are sequential to code information
        for string in line_list:
            if str!=';':
                tmp_str = string.replace(" ","").replace(",", "").replace(";", "")
                new_line_list.append(tmp_str)
        
        line_list = new_line_list

        # parse line_list
        opcode = line_list[0].lower() 

        # remove adjacent ; to last string
        # if ";" in line_list[-1]:
        #     line_list[-1]=line_list[-1].replace(";", "")

        # handle in-line comments
        if ';' in line_list:
            comment_ix = line_list.index(';')
            not_opcode = line_list[1:comment_ix]
        else:
            # line w/ only code
            not_opcode = line_list[1:]

# =================================================================================================================================================================================
#                                                            _____     __                           _   
#                                                           |  __ \   / _|                         | |  
#                                                           | |__) | | |_ ___  _ __ _ __ ___   __ _| |_ 
#                                                           |  _  /  |  _/ _ \| '__| '_ ` _ \ / _` | __|
#                                                           | | \ \  | || (_) | |  | | | | | | (_| | |_ 
#                                                           |_|  \_\ |_| \___/|_|  |_| |_| |_|\__,_|\__|
# =================================================================================================================================================================================
        if opcode in R_ops:
            
            Opcode_bin = "0000"
            # sll and srl variation
            if opcode=="sll" or opcode=="srl":
                rs = not_opcode[0]
                rt = not_opcode[1]
                rd = not_opcode[2] # this is actually the shamt
                rd_bin = assign_shamt_bin(rd)
            # jr variation
            elif opcode=="jr":
                rs = not_opcode[0]
                rt = "$r0"
                rd = "$r0"
                rd_bin = assign_reg_bin(rd)
            # vanilla
            else:
                rs = not_opcode[1]
                rt = not_opcode[2] # or shamt
                rd = not_opcode[0]
                rd_bin = assign_reg_bin(rd)


            # SNAP REGFILE UPDATE
                # extract number of reg
            rs_idx=rs[-1]
            rt_idx=rt[-1]
            rd_idx=rd[-1]
            # UPDATE WDATA
            if opcode=="add":
                wdata = update_snap(rd_idx, snap_regfile[rs_idx]+snap_regfile[rt_idx])
            elif opcode=="and":
                wdata = update_snap(rd_idx, snap_regfile[rs_idx]&snap_regfile[rt_idx])
            elif opcode=="or":
                wdata = update_snap(rd_idx, snap_regfile[rs_idx]|snap_regfile[rt_idx])
            elif opcode=="sub":
                wdata = update_snap(rd_idx, snap_regfile[rs_idx]-snap_regfile[rt_idx])
            elif opcode=="slt":
                if snap_regfile[rs_idx]<snap_regfile[rt_idx]:
                    bit_set=1
                else:
                    bit_set=0
                wdata = update_snap(rd_idx, bit_set)
            #we pipeline
            we=1
            register_dest =int(rd_idx)

            # reg binary assignment
            rs_bin = assign_reg_bin(rs)
            # rd_bin = assign_reg_bin(rd)
            rt_bin = assign_reg_bin(rt)
            
            Fcode_bin = Fcode_dict[opcode]
            line_bin = Opcode_bin+rs_bin+rt_bin+rd_bin+Fcode_bin

            if GENERATE_REF:
                register_source = str(int(rs_bin,2))
                register_temp = str(int(rt_bin, 2))

# =================================================================================================================================================================================
#                                                        _____    __                           _   
#                                                       |_   _|  / _|                         | |  
#                                                         | |   | |_ ___  _ __ _ __ ___   __ _| |_ 
#                                                         | |   |  _/ _ \| '__| '_ ` _ \ / _` | __|
#                                                        _| |_  | || (_) | |  | | | | | | (_| | |_ 
#                                                       |_____| |_| \___/|_|  |_| |_| |_|\__,_|\__|
# =================================================================================================================================================================================
        elif opcode in I_ops:
            rs = not_opcode[0]
            rt = not_opcode[1]
            immediate = not_opcode[2]
            immediate_int = integer_it(immediate)
            if check_range_imm(immediate_int, 6):
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

            # SNAP REGFILE UPDATE
            # extract number of reg
            rs_idx=rs[-1]
            rt_idx=rt[-1] # destination in I format is rt
            # UPDATE WDATA
            if opcode=="addi":
                wdata = update_snap(rt_idx, snap_regfile[rs_idx]+immediate_int)
            elif opcode=="slti":
                if snap_regfile[rs_idx]<immediate_int:
                    bit_set=1
                else:
                    bit_set=0
                wdata = update_snap(rt_idx, bit_set)

            # UPDATE RAM_WE, RAM_WDTA, RAM_WADDR
            if opcode=="sw":
                ram_we = 1
                ram_wdata = snap_regfile[rt_idx]
                ram_waddr = snap_regfile[rs_idx]+immediate_int
            elif opcode=="lw":
                we=1
                register_dest = snap_ram[rs_idx]+immediate_int
            else:
                we=1
                register_dest = int(rt_idx)


            if GENERATE_REF:
                register_source = str(int(rs_bin,2))
                register_temp = str(int(rt_bin, 2))

# =================================================================================================================================================================================
#                                                             _    __                           _   
#                                                            | |  / _|                         | |  
#                                                            | | | |_ ___  _ __ _ __ ___   __ _| |_ 
#                                                        _   | | |  _/ _ \| '__| '_ ` _ \ / _` | __|
#                                                       | |__| | | || (_) | |  | | | | | | (_| | |_ 
#                                                        \____/  |_| \___/|_|  |_| |_| |_|\__,_|\__|
# =================================================================================================================================================================================
        elif opcode in J_ops:
            address = not_opcode[0]
            addr_bin = assign_addr_bin(address)
            Opcode_bin = Jcode_dict[opcode]
            line_bin = Opcode_bin+addr_bin

            if GENERATE_REF:
                register_source = "NONE"
                register_temp = "NONE"

        elif opcode=="nop" or opcode=="nope":
            line_bin = "0"*16

        else :
            # invalid code
            print("[!] ERROR AT LINE " + str(line_cnt))
            print__pointy_separator()
            print("invalid opcode.")
            exit

        fw.write(line_bin+'\n')


        if GENERATE_REF:
            # instruction pipeline
            instr_pipeline[1:4] = instr_pipeline[0:3]
            instr_pipeline[0] = hex(int(line_bin, 2))
            # rs pipeline
            rs_pipeline[1:4] = rs_pipeline[0:3]
            rs_pipeline[0] = register_source
            # rt pipeline
            rt_pipeline[1:4] = rt_pipeline[0:3]
            rt_pipeline[0] = register_temp
            # rd pipeline
            rdestination_pipeline[1:4] = rdestination_pipeline[0:3]
            rdestination_pipeline[0] = register_dest
            # we
            we_pipeline[1:4] = we_pipeline[0:3]
            we_pipeline[0] = we
            # wdata
            wdata_pipeline[1:4] = wdata_pipeline[0:3]
            wdata_pipeline[0] = wdata
            # ram_we
            ram_we_pipeline[1:4] = ram_we_pipeline[0:3]
            ram_we_pipeline[0] = ram_we
            # ram_wdata
            ram_wdata_pipeline[1:4] = ram_wdata_pipeline[0:3]
            ram_wdata_pipeline[0] = ram_wdata
            # ram_waddr
            ram_waddr_pipeline[1:4] = ram_waddr_pipeline[0:3]
            ram_waddr_pipeline[0] = ram_waddr
            # instructione pipeline HEADER
            pipeline = f"{instr_pipeline[0]}        | {instr_pipeline[1]}        | {instr_pipeline[2]}        | {instr_pipeline[3]}        |\n"
            # regfile access BODY
            regfile_content= f"\n"
            if we_pipeline[3]==1:
                regfile_content+=f"Write rd#{rdestination_pipeline[3]} wdata: {wdata_pipeline[3]}\n"
            if ram_we_pipeline[2]==1:
                regfile_content += f"Write RAM[{ram_waddr_pipeline[2]}] ram_wdata: {ram_wdata_pipeline[2]}\n"
            fref.write(BANNER)
            fref.write(pipeline)
            fref.write(regfile_content)
            fref.write("\n\n\n")


    fw.close()
    fh.close()

    if GENERATE_REF:
        fref.close()

    return



if __name__== "__main__":
    main()