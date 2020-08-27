`timescale 1ns / 1ps

module cdiv(
    input clkin,
    input rst_n,
    output clkout
    );
    
    parameter DIVBY = 8'd20;
    reg[7:0] count;
    
    always@(posedge clkin or negedge rst_n) begin
        if(!rst_n) count <= 0;
        else begin
            if(count < DIVBY) count <= count + 1;
            else count <= 0;
        end
    end
    
    assign clkout = count==(DIVBY<<1)? 0 : 1;
    
endmodule
