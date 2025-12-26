# SPI Master–Slave Design and Verification (SystemVerilog)



## Overview



This project implements and verifies a **Serial Peripheral Interface (SPI)** communication system using SystemVerilog.  

The design includes a **SPI Master** and **SPI Slave**, along with a fully functional **self-checking verification environment**.



The verification environment validates correct data transfer, synchronization, and protocol behavior using randomized stimulus.



---



## Design Overview



### SPI Master

- Generates serial clock (SCLK)

- Drives MOSI line

- Controls chip-select (CS)

- Handles transmission of parallel data serially



### SPI Slave

- Samples MOSI on clock edges

- Reconstructs received data

- Indicates successful reception



---



## RTL Architecture


**Top-Level Modules**

- `spi_master`

- `spi_slave`



**Interface**

- `spi_if` connects master, slave, and testbench



```systemverilog

module spi_master(

  input  clk,

  input  rst,

  input  newd,

  input  [11:0] din,

  output reg cs,

  output reg mosi,

  output reg sclk

);

  // SPI implementation

endmodule


module spi_slave(

input cs, 

input mosi, 

input sclk,

input rst,

  output reg done, 

  output [11:0] dout

);

  // SPI implementation

endmodule

