`timescale 1ns / 1ps
module top(
    input CLK100MHZ,
    input CPU_RESETN,
    output[15:0] LED,
    inout[10:1] JA,
    inout[10:1] JB,
    inout[10:1] JC,
    inout[10:1] JD
    );

wire clk;
wire rst_n;
wire locked;

clk_wiz_0 mclk(.clkin(CLK100MHZ),
               .clkout(clk),
               .locked(locked)
               );

//Who needs synchronization anyway
assign rst_n = CPU_RESETN & locked;

wire[15:0] abus;
wire[7:0] dbus;
wire tres;
wire trd;
wire twr;
wire textal; //Might need to feed inverted clock depending on stray capacitance

ila ila(.clk(clk),
        .probe0(abus),
        .probe1(dbus),
        .probe2(tres),
        .probe3(trd),
        .probe4(twr),
        .probe5(textal)
        );

glitchy glitchy(
        .clk(clk),
        .rst_n(rst_n),
        .tres(tres),
        .textal(textal)
        );

assign LED = abus;
    
endmodule