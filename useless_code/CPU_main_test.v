`timescale 1ns/1ps
module CPU_main_test;
    reg clk = 1;
    reg [32:1] sw;
    reg [6:1] swb;

    wire [32:1] led;
    wire [2:0] which;
    wire [7:0] seg;
    wire enable = 1;

    CPU_Main CPU_Main(.clk(clk), .sw(sw), .swb(swb),
                .led(led), .which(which), .seg(seg), .enable(enable));
    initial begin
        sw <= 0;
        swb <= 0;
        
        swb[1] <= 1;
        #10
        swb[1] <= 0;

        #100

        swb[6] <= 1;
        #10
        swb[6] <= 0;
        #10
        swb[6] <= 1;
        #10
        swb[6] <= 0;
#10
        swb[6] <= 1;
        #10
        swb[6] <= 0;
#10
        swb[6] <= 1;
        #10
        swb[6] <= 0;
#10
        swb[6] <= 1;
        #10
        swb[6] <= 0;
#10
        swb[6] <= 1;
        #10
        swb[6] <= 0;
#10
        swb[6] <= 1;
        #10
        swb[6] <= 0;

    end

    always @(*) begin
        #5 swb[2] <= ~swb[2];
    end
    
endmodule