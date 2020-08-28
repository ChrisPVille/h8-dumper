`timescale 1ns / 1ps

module glitchy(
    input clk,
    input rst_n,
    input go,
    output reg tres,
    output textal,
    output capnow
    );
    
    reg[2:0] state;
    reg[2:0] next_state;
    
    localparam RESET = 0;
    localparam INIT_CLOCKS = 1;
    localparam GLITCHY = 2;
    localparam FREERUN = 3;
    
    wire normalclk;
    cdiv #(.DIVBY(1000)) cdiv (.clkin(clk),
                             .rst_n(rst_n),
                             .enable(go),
                             .clkout(normalclk)
                             );
              
    reg[1:0] normalclk_edge;
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) normalclk_edge <= 0;
        else normalclk_edge <= {normalclk_edge[0],normalclk};
    end
    
    
    reg[31:0] count;
    localparam RESETTIME = 32'd100_000;
    localparam INITTIME = 32'd60 + RESETTIME; //60 worked once 
    localparam GLITCHYTIME = 32'd50000 + INITTIME;
    
    assign capnow = (state==GLITCHY);
    
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) count <= 0;
        else begin
            if(go) begin
                if(state == GLITCHY) count <= count + 1;
                else if(normalclk_edge==2'b01) count <= count + 1;
            end
        end
    end
    
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) tres <= 0;
        else if(state != RESET && normalclk==0) tres <= 1;
    end
    
    wire glitchclk;
    cdiv #(.DIVBY(3)) gdiv (.clkin(clk), //5 worked once
                             .rst_n(rst_n),
                             .enable(go),
                             .clkout(glitchclk)
                             );
                             
    assign textal = (state == GLITCHY) ? glitchclk : normalclk;
    
    always@(*) begin
        next_state = state;
        case(state)
            RESET: if(count==RESETTIME) next_state = INIT_CLOCKS;
            INIT_CLOCKS: if(count==INITTIME) next_state = GLITCHY;
            GLITCHY: if(count==GLITCHYTIME) next_state = FREERUN;
            FREERUN: ;
        endcase
    end              
    
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) state <= RESET;
        else state <= next_state;
    end
    
endmodule
