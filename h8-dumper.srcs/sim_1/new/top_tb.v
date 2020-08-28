`timescale 1ns / 1ps

module top_tb();
    
    reg clk_100mhz, rst_n;
    wire[15:0] LED;
    reg[15:0] SW;

    top top(
        .CLK100MHZ(clk_100mhz),
        .CPU_RESETN(rst_n),
        .LED(LED),
        .SW(SW),
        .JA(),
        .JB(),
        .JC(),
        .JD()
        );
    
    initial begin
        clk_100mhz = 1;
        forever #5 clk_100mhz = ~clk_100mhz;
    end

    initial
    begin
        rst_n = 0;
        SW = 16'h0000;

        #15 rst_n = 1;

        #800 SW = 16'hffff;

        #100000 $finish;
    end
endmodule
