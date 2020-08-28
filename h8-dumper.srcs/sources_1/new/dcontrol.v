`timescale 1ns / 1ps

module dcontrol(
    input clk,
    input rst_n,
    input[15:0] addr,
    input[7:0] data,
    output reg[7:0] data_out,
    input rd,
    input wr,
    input fifo_rden,
    output fifo_empty,
    output[7:0] fifo_data
    );
        
    reg[15:0] src_addr;
    reg arm;
    localparam ENDADDR = 16'h3FFF;
    
    reg fifo_wren;
    reg already_wrote;
    reg done;

    fifo_generator_0 wfifo(
        .clk(clk),
        .rst(~rst_n),
        .din(data),
        .wr_en(fifo_wren),
        .empty(fifo_empty),
        .dout(fifo_data),
        .rd_en(fifo_rden)
        );
        
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            src_addr <= 0;
            fifo_wren <= 0;
            already_wrote <= 0;
            done <= 0;
        end else begin
            fifo_wren <= 0;
            if(arm && addr==16'hFB7F && !wr && !already_wrote) begin
                fifo_wren <= 1;
                already_wrote <= 1;
                if(src_addr <= ENDADDR) src_addr <= src_addr + 1;
                else done <= 1; 
            end
            else if(addr != 16'hFB7F) already_wrote <= 0;
        end
    end
    
    //This is ugly. Why? Becuase I'm trying to get this done quickly
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            data_out <= 8'b0;
            arm <= 0;
        end else begin
            if(!rd && addr==16'hFB70) data_out <= 8'h6A; //MOVE.B @src_addr, R0
            else if(!rd && addr==16'hFB71) data_out <= 8'h00;
            else if(!rd && addr==16'hFB72) data_out <= src_addr[15:8];
            else if(!rd && addr==16'hFB73) data_out <= src_addr[7:0];
            else if(!rd && addr==16'hFB74) begin //MOVE.B R0, @0xFB7F
                 data_out <= 8'h6A;
                 arm <= 1;
            end
            else if(!rd && addr==16'hFB75) data_out <= 8'h80;
            else if(!rd && addr==16'hFB76) data_out <= 8'hFB;
            else if(!rd && addr==16'hFB77) data_out <= 8'h7F;
            else if(!rd && addr==16'hFB78) data_out <= 8'h5A; //JMP 0xFB70
            else if(!rd && addr==16'hFB79) data_out <= 8'h00;
            else if(!rd && addr==16'hFB7A) data_out <= 8'hFB;
            else if(!rd && addr==16'hFB7B) begin
                if(!done) data_out <= 8'h70;
                else data_out <= 8'h78;
            end
            else data_out <= 8'h00;
        end 
    end 
endmodule
