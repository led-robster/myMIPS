# SOC GUIDE

Implementation of myMIPS on Intel 10 LP Cyclone evaluation kit.  
This project aims at running Doom (the well-known videogame) on my custom processor.  
This project requires:
* building a core
* enabling memory mapped devices
* run 

## CORE

## COMMUNICATION ON-CHIP


## COMMUNICATION OFF-CHIP

### HYPER-RAM

HyperRAM is the main memory for the chip. It communicates with chip via HyperBus. To enable mem-mapped function a bridge AXI4-HyperBus has to be built. A feasibility study must be conducted because HyperBus is an Intel IP and may not be accessible.