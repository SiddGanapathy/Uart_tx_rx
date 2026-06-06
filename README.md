# UART_TX_RX

UART Transmitter and Receiver implementation in Verilog HDL with simulation support using Quartus and ModelSim.

## Overview

This project implements a basic UART (Universal Asynchronous Receiver/Transmitter) communication system including both:

- UART Transmitter (TX)
- UART Receiver (RX)

The repository contains RTL source files, Quartus project files, and ModelSim simulation setup for functional verification.

---

## Repository Structure

```text
UART_TX_RX/
│
├── uart_tx_rx/
│   ├── simulation/
│   │   └── modelsim/
│   │       ├── *.do
│   │       ├── vsim.wlf
│   │       └── simulation files
│   │
│   ├── *.v
│   ├── *.qpf
│   ├── *.qsf
│   ├── *.qws
│   └── nativeLinkSimulation.rpt
│
└── README.md
```

---

## Features

- UART transmitter implementation
- UART receiver implementation
- Serial data communication
- RTL simulation support
- Quartus project setup
- ModelSim automation scripts

---

## Tools Used

- Verilog HDL
- Intel Quartus Prime
- ModelSim

---

## UART Basics

UART communication uses:

- TX line for transmission
- RX line for reception
- Start bit
- Data bits
- Optional parity bit
- Stop bit

This project demonstrates asynchronous serial communication using Verilog HDL.

---

## Running Simulation

1. Open the project in Quartus Prime.
2. Compile the design.
3. Open ModelSim.
4. Run the generated simulation script.

Example:

```tcl
do uart_tx_rx_run_msim_rtl_verilog.do
```

---

## Future Improvements

- Configurable baud rate generator
- FIFO buffering
- Parity support
- Error detection
- FPGA hardware validation
- Loopback testing

---
