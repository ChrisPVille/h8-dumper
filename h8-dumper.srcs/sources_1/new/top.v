`timescale 1ns / 1ps
module top(
    input CLK100MHZ,
    input CPU_RESETN,
    output[15:0] LED,
    input[15:0] SW,
    inout[7:1] dbus_pre,
    output textal,
    input twr_pre,
    input trd_pre,
    output tres,
    output uart_tx,
    input[10:1] JC,
    input[10:1] JD
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

wire[15:0] abus_pre, abus;
wire[7:0] dbus;
wire[7:0] dout;
wire trd;
wire twr;
//Might need to feed inverted clock depending on stray capacitance

ff_sync #(.WIDTH(16)) async(.clk(clk), .rst_n(rst_n), .in_async(abus_pre), .out(abus));
ff_sync #(.WIDTH(8)) dsync(.clk(clk), .rst_n(rst_n), .in_async(dbus_pre), .out(dbus));
ff_sync #(.WIDTH(1)) rsync(.clk(clk), .rst_n(rst_n), .in_async(trd_pre), .out(trd));
ff_sync #(.WIDTH(1)) wsync(.clk(clk), .rst_n(rst_n), .in_async(twr_pre), .out(twr));

assign dbus_pre = !trd ? dout : 8'bz;

assign abus_pre[15:0] = {JD[10:7],JD[4:1],JC[10:7],JC[4:1]};

reg[3:0] swsync;
always@(posedge clk) swsync <= {swsync[2:0],SW[15]};

wire capnow;
ila ila(.clk(clk),
        .probe0(abus),
        .probe1(dbus),
        .probe2(tres),
        .probe3(trd),
        .probe4(twr),
        .probe5(textal),
        .probe6(swsync[3]),
        .probe7(capnow)
        );

wire[7:0] fifo_data;
reg fifo_rden;
reg send_byte;

wire tx_active;
wire fifo_empty;

//ila ila(.clk(clk),
//        .probe0({8'h00,fifo_data}),
//        .probe1(dbus),
//        .probe2(fifo_rden),
//        .probe3(send_byte),
//        .probe4(fifo_empty),
//        .probe5(tx_active),
//        .probe6(uart_tx),
//        .probe7(1'b0)
//        );
        
glitchy glitchy(
        .clk(clk),
        .rst_n(rst_n),
        .go(swsync[3]),
        .tres(tres),
        .textal(textal),
        .capnow(capnow)
        );

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        fifo_rden <= 0;
        send_byte <= 0;
    end else begin
        send_byte <= 0;
        fifo_rden <= 0;
        if(!fifo_empty && !tx_active && !fifo_rden) begin
            fifo_rden <= 1;
        end
        if(fifo_rden) send_byte <= 1;
    end
end

dcontrol dcontrol(
    .clk(clk),
    .rst_n(rst_n),
    .addr(abus),
    .data(dbus),
    .data_out(dout),
    .rd(trd),
    .wr(twr),
    .fifo_rden(fifo_rden),
    .fifo_empty(fifo_empty),
    .fifo_data(fifo_data)
    );

uart_tx #(.CLKS_PER_BIT(868)) uart(
    .i_Clock(clk),
    .i_Tx_DV(send_byte),
    .i_Tx_Byte(fifo_data),
    .o_Tx_Active(tx_active),
    .o_Tx_Serial(uart_tx),
    .o_Tx_Done()
    );
    
assign LED = abus;
    
endmodule