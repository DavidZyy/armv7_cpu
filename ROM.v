`timescale 1ns / 1ps
// module ROM (
//     clk,R_Addr,R_Data
// );
//     input clk;
//     input [7:0]R_Addr;
//     output wire [31:0]R_Data;
//     ROM_B RB(
//         .clka(clk),
//         .addra(R_Addr[7:2]),
//         .douta(R_Data)
//     );
// endmodule

module ROM (
    input      clk,
    input [7:0] raddr,

    output reg [31:0] rdata
);
    localparam addr_width = 8;
    localparam mem_size = 2**addr_width;

    reg [31:0] mem [mem_size-1:0];

    initial $readmemh("./test.hex", mem);

    always @(posedge clk) begin
        rdata <= mem[raddr];
    end 
endmodule //ROM
