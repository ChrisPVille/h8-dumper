`timescale 1ns / 1ps

module cdiv(
    input clkin,
    input rst_n,
    input enable,
    output clkout
    );
    
    parameter DIVBY = 16'd20;
    reg[15:0] count;
    
    always@(posedge clkin or negedge rst_n) begin
        if(!rst_n) count <= 0;
        else begin
            if(enable) begin
                if(count < DIVBY-1) count <= count + 1;
                else count <= 0;
            end
        end
    end
    
    assign clkout = count>=(DIVBY>>1)? 0 : 1;
    
endmodule
