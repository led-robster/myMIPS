# usage: ./modelsim.sh test_alu.vcd
#        ./modelsim.sh -g test_alu.vcd ; to run gtkwave after modelsim


echo "Executing .do ..."
C:\\Microsemi\\Libero_SoC_v11.9\\ModelsimPro\\win32acoem\\modelsim.exe -do compile.do

sleep 4

while true; do
    if powershell -Command "Get-Process -Name 'vish' -ErrorAction SilentlyContinue" > /dev/null; then
        echo "modelsim still running."
        sleep 2
    else
        echo "modelsim has stopped."
        break;
    fi
    
done

mv test_vcd.vcd $2

echo "SUCCESS. Waveform exported as $2"

#!/bin/bash

while getopts ":g" opt; do
  case $opt in
    g) gtkwave -o $2 ;;
    \?) echo "Invalid option: -$OPTARG" ;;
    :) echo "Option -$OPTARG requires an argument." ;;
  esac
done
shift $((OPTIND - 1))  # Shift past parsed options
