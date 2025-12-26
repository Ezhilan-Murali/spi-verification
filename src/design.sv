// Code your design here

module spi_master(
input clk, newd, rst,
  input [11:0] din, 
  output reg cs, mosi, sclk
);
  
  typedef enum bit [1:0]{ideal=2'b00, enable=2'b01, send=2'b10, comp=2'b11} state_type;
  state_type state = ideal;
  
 int countc=0;
  int count=0;
  
  always @(posedge clk) begin
    
    if(rst==1) begin
      sclk<=0;
      countc<=0;
    end
      
      else if (countc<10) begin
      	  countc<=countc+1 ;
      end
    else begin
      countc<=0;
      sclk <= ~sclk;
    end
      
  end
  
  reg [11:0] temp;
  
  always @(posedge sclk) begin 
   		
    if(rst==1) begin
     	cs<=1;
      mosi<=0;
    end
    
    else begin
      case(state)
        ideal:
          begin
          if(newd==0) begin
            state<=ideal;
            temp<=0;
          end
        	else if(newd==1) begin
          		state<=send;
              temp<=din;
          		cs<=0;
        	end
          end
        
        send:
          begin
          	if(count<=11) begin
              mosi<=temp[count];
            	count<=count+1 ;
          	end
        	else begin
          		count<=0;
          		cs<=1;
              state<=ideal;
              mosi<=0;
        	end
          end
        default: state<=ideal;
      endcase
    end
    
  end

  
endmodule





module spi_slave(
input cs, mosi, sclk,rst,
  output reg done, 
  output [11:0] dout
);
  
  reg [11:0] temp=0;
  int count = 0;
  typedef enum bit{detect_start=0, read_data=1} state_type;
  state_type state = detect_start;
  
  always @(posedge sclk) begin
    case(state) 
      detect_start:
        begin
          done<=0;
          if(cs==0) begin
            state<=read_data;
            
          end
          else
            begin
              //temp<={ mosi, temp[11:1] };
              //count <= 1;
              state<=detect_start;
            end
        end
          read_data:
          begin
            if(count<=11) begin
              temp  <= { mosi, temp[11:1] }; // | temp[count] <= mosi; both works
              count<=count+1 ;
            end
            else begin
              count<=0;
              done<=1;
              state<=detect_start;
            end
          end
    endcase
  end
  assign dout=temp;
endmodule


module top(input clk, newd, rst,
           input [11:0] din,
           output done, 
           output [11:0] dout
                );
  wire cs, mosi, sclk;
  
  spi_master m1(clk, newd, rst, din, cs, mosi, sclk);
  spi_slave s1(cs, mosi, sclk,rst, done, dout);
  
  
endmodule
      
interface spi_if;
  logic clk, newd, rst, done;
  wire sclk;
  logic [11:0] din;
  logic [11:0] dout;
  
endinterface
  
  