\# SPI Master–Slave Design and Verification (SystemVerilog)



\## Overview



This project implements and verifies a \*\*Serial Peripheral Interface (SPI)\*\* communication system using SystemVerilog.  

The design includes a \*\*SPI Master\*\* and \*\*SPI Slave\*\*, along with a fully functional \*\*self-checking verification environment\*\*.



The verification environment validates correct data transfer, synchronization, and protocol behavior using randomized stimulus.



---



\## Design Overview



\### SPI Master

\- Generates serial clock (SCLK)

\- Drives MOSI line

\- Controls chip-select (CS)

\- Handles transmission of parallel data serially



\### SPI Slave

\- Samples MOSI on clock edges

\- Reconstructs received data

\- Indicates successful reception



---



\## RTL Architecture



\*\*Top-Level Modules\*\*

\- `spi\_master`

\- `spi\_slave`



\*\*Interface\*\*

\- `spi\_if` connects master, slave, and testbench



```systemverilog

module spi\_master(

&nbsp; input  clk,

&nbsp; input  rst,

&nbsp; input  newd,

&nbsp; input  \[11:0] din,

&nbsp; output reg cs,

&nbsp; output reg mosi,

&nbsp; output reg sclk

);

&nbsp; // SPI implementation

endmodule


module spi\_slave(

input cs, 

input mosi, 

input sclk,

input rst,

&nbsp; output reg done, 

&nbsp; output \[11:0] dout

);

  // SPI implementation

endmodule

