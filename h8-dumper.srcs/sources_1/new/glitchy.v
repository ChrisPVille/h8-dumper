`timescale 1ns / 1ps

module glitchy(
    input clk,
    input rst_n,
    output tres,
    output textal
    );
    
    reg[2:0] state;
    reg[2:0] next_state;
    
    localparam RESET = 0;
    localparam INIT_CLOCKS = 1;
    localparam GLITCHY = 2;
    localparam FREERUN = 3;
    
    wire normalclk;
    cdiv #(.DIVBY(200)) cdiv (.clkin(clk),
                             .rst_n(rst_n),
                             .clkout(normalclk)
                             );
              
    reg[1:0] normalclk_edge;
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) normalclk_edge <= 0;
        else normalclk_edge <= {normalclk_edge[0],normalclk};
    end
    
    
    reg[31:0] count;
    localparam RESETTIME = 32'd1_000_000;
    localparam INITTIME = 32'd10 + RESETTIME;
    localparam GLITCHYTIME = 32'd50000 + INITTIME;
    
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) count <= 0;
        else begin
            if(state == GLITCHY) count <= count + 1;
            else if(normalclk_edge==2'b01) count <= count + 1;
        end
    end
    
    assign tres = (state != RESET);
    assign textal = (state == GLITCHY) ? clk : normalclk;
    
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
