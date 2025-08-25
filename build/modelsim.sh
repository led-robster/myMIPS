# usage: ./modelsim.sh -f test_alu.vcd -e tb


#!/bin/bash


# INITIALIZATION
FILE=""
TB_ENTITY=""
VERBOSE=false
BUILD_DIR="C:\\Users\\fea\\Documents\\PERSONAL_AREA\\myMIPS\\build"

# FUNCTION UTILITIES

log() {
  if $VERBOSE; then
    echo -e "[DEBUG] $*"
  fi
}

# ARGUMENT PARSER 

while getopts "f:e:vh" opt; do
  case $opt in
    f) 
      FILE="$OPTARG"
      ;;
    e)
      TB_ENTITY="$OPTARG"
      ;;
    v)
      VERBOSE=true
      ;;
    h)
      echo "Usage: $0 [-f vcd_filename.vcd] [-e tb] [-v]"
      exit 0
      ;;
    \?) 
      echo "Invalid option: -$OPTARG"
      exit 1
      ;;

  esac
done
shift $((OPTIND - 1))  # Shift past parsed options



echo "Executing .do ..."
log "Executing following command\n>> C:\\Microsemi\\Libero_SoC_v11.9\\ModelsimPro\\win32acoem\\modelsim.exe -do "compile.do $TB_ENTITY""
C:\\Microsemi\\Libero_SoC_v11.9\\ModelsimPro\\win32acoem\\modelsim.exe -do "do compile.do $TB_ENTITY"


sleep 4

while true; do
    if powershell -Command "Get-Process -Name 'vish' -ErrorAction SilentlyContinue" > /dev/null; then
        log "modelsim still running."
        sleep 4
    else
        log "modelsim has stopped."
        break;
    fi
    
done

mv test_vcd.vcd $FILE

echo "SUCCESS. Waveform exported as $FILE"

