# APB
AMBA APB 3.0 Slave & Verification IP

SystemVerilog implementation and verification environment for an AMBA APB 3.0 compliant slave, designed to demonstrate protocol understanding, transaction handling, and structured verification methodology.

 Overview

This project implements an AMBA APB 3.0 slave along with a class-based verification environment. The design supports basic read and write transactions and verifies correct protocol behavior using simulation-based verification.

The objective of this project is to:

Understand AMBA APB protocol timing and signals

Design a synthesizable APB slave

Build a reusable verification environment

Validate protocol correctness through simulation waveforms and console outputs

Architecture
Design Components
| Module         | Description                                             |
| -------------- | ------------------------------------------------------- |
| `apb_slave.sv` | APB slave implementation handling read/write operations |
| `apb_if.sv`    | APB interface containing protocol signals               |
| Memory Logic   | Internal register/memory model for data storage         |


Verification Components
| Component       | Description                                                    |
| --------------- | -------------------------------------------------------------- |
| `tb_classes.sv` | Transaction, driver, monitor, and environment classes          |
| `tb_top.sv`     | Top-level testbench connecting DUT and verification components |



APB Protocol Features Implemented

APB 3.0 compliant transfer flow

Setup and Access phases

Read and write transactions

PSEL, PENABLE handshake

Ready and response handling

Address and data phase separation



 Verification Methodology

The verification environment follows a structured approach:

Transaction generation

Driver converts transactions into pin-level activity

Monitor captures bus activity

Output checked through simulation logs and waveform analysis

Verification ensures:

Correct data write/read

Proper protocol sequencing

Stable control signals during access phase


