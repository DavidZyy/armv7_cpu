
`timescale 1ns / 1ps

module IF(// instruction fetch module
    input   clk,
    input   rst,
    input [3:0]   NZCV,
    input   Write_IR,
    input   Write_PC,
    input [7:0] B,
    input [7:0] F,
    input [1:0] PC_s,
    
    output  [31:0] IR,
    output reg IR_Flag,
    output  [7:0] PC_OUT
    );

    assign PC_OUT = PC[7:0];

    reg [31:0] IR;
    reg [31:0] PC;
    wire [31:0] Read_Data;
    reg flag;
    reg [7:0] PC_New;
    reg [1:0]PC_C_Flag = 0;
    
    always@(negedge clk or posedge rst) begin
        if(rst)
            PC <= 32'h0;
        else if(Write_PC)
        begin
            case (PC_s)
                2'b00: begin
                    PC  <= PC+4;
                end 
                2'b01: begin
                    PC  <= B;
                end 
                2'b10: begin
                    PC  <= F;
                end 
                2'b11: begin
                    PC <=   8'h20;//the interrupt address
                end
            endcase
        end
    end

    always@(negedge clk)
        if (IR_Flag & Write_IR)
        begin
            IR <= Read_Data;
        end
            

    ROM ROM (
    .clk(clk),    
    .raddr(PC[7:0]),

    .rdata(Read_Data)
    // .R_Data(Read_Data),
    // .R_Addr(PC[7:0])
    );

    always  @(*) begin
        case(Read_Data[31:28])
            /*4'b0000: IR_Flag <= NZCV[2];
            4'b0001: IR_Flag <= ~NZCV[2];
            4'b0010: IR_Flag <= NZCV[1];
            4'b0011: IR_Flag <= ~NZCV[1];
            4'b0100: IR_Flag <= NZCV[3];
            4'b0101: IR_Flag <= ~NZCV[3];
            4'b0110: IR_Flag <= NZCV[0];
            4'b0111: IR_Flag <= ~NZCV[0];
            4'b1000: IR_Flag <= (NZCV[1] && (~NZCV[2]));
            4'b1001: IR_Flag <= ((~NZCV[1]) || NZCV[2]);
            4'b1010: IR_Flag <= (NZCV[3] == NZCV[0]);
            4'b1011: IR_Flag <= (NZCV[3] != NZCV[0]);
            4'b1100: IR_Flag <= (~NZCV[2] && (NZCV[3] == NZCV[0]));
            4'b1101: IR_Flag <= (NZCV[2] || (NZCV[3] != NZCV[0]));
            4'b1110: IR_Flag <= 1;
            default: IR_Flag <= 0;*/
            4'b1110: IR_Flag <= 1;
            default: IR_Flag <= 1'b1;
        endcase
    end
endmodule

/*module IF(
    input   clk,
    input   rst,
    input [3:0]   NZCV,
    input   Write_PC,
    input   Write_IR,
    input [7:0] B,
    input [7:0] F,
    input [1:0] PC_s,
    
    output  [31:0] IR,
    output IR_Flag,
    output  [7:0] PC
    );

    reg [31:0] IR_1;
    reg [7:0] PC_1;
    wire [31:0] Read_Data;
    reg flag;
    reg [7:0] PC_New;
    reg [1:0]PC_C_Flag = 0;


    always @(negedge clk or posedge rst) begin
        if (rst) begin
         PC_1  <=  8'b00000000;
        end
        else begin
            if(Write_PC) begin
                case (PC_s)
                    2'b00: begin
                        PC_C_Flag <= 0;
                        PC_1  <= PC_New;
                    end 
                    2'b01: begin
                        //PC_C_Flag <= PC_C_Flag+1;
                        PC_1  <= B;
                    end 
                    2'b10: begin
                        PC_C_Flag <= PC_C_Flag+1;
                        PC_1  <= F;
                    end 
                endcase
            end
            if (PC_C_Flag == 2'd2) begin
                PC_1 <= PC_New;
                PC_C_Flag <= 0;
            end
            if(flag && Write_IR) begin
                IR_1  <=  Read_Data;
            end
        end
    end

    ROM ROM (
    .clk(clk),    
    .R_Data(Read_Data),
    .R_Addr(PC_1)
    );
    always  @(*) begin
        PC_New <= PC_1 + 4;
        case(Read_Data[31:28])
            4'b0000: flag <= NZCV[2];
            4'b0001: flag <= ~NZCV[2];
            4'b0010: flag <= NZCV[1];
            4'b0011: flag <= ~NZCV[1];
            4'b0100: flag <= NZCV[3];
            4'b0101: flag <= ~NZCV[3];
            4'b0110: flag <= NZCV[0];
            4'b0111: flag <= ~NZCV[0];
            4'b1000: flag <= (NZCV[1] && (~NZCV[2]));
            4'b1001: flag <= ((~NZCV[1]) || NZCV[2]);
            4'b1010: flag <= (NZCV[3] == NZCV[0]);
            4'b1011: flag <= (NZCV[3] != NZCV[0]);
            4'b1100: flag <= (~NZCV[2] && (NZCV[3] == NZCV[0]));
            4'b1101: flag <= (NZCV[2] || (NZCV[3] != NZCV[0]));
            4'b1110: flag <= 1;
            default: flag <= 0;
        endcase
    end
    assign PC = PC_1;
    assign IR = IR_1;
    assign IR_Flag = flag;
endmodule*/