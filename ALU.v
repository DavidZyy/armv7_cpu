`timescale 1ns / 1ps
module ALU(A,B,ALU_OP,Shift_Carry_Out,CF,VF,F,NZCV);
    input [32:1] A;
    input [32:1] B;
    input [4:1] ALU_OP;
    input Shift_Carry_Out;
    input CF;
    input VF;

    reg [33:1]F33;
    output reg[32:1] F;
    output reg [4:1]NZCV;

    always@(*)
    begin
        case (ALU_OP)
            4'b0000: begin
                F <= A & B;
            end
            4'b0001: begin
                F <= A ^ B;
            end
            4'b0010: begin
                F33[33:1] <= A - B;
                NZCV[2] <= ~F33[33];
                F[32:1] <= F33[32:1];
                NZCV[1] <= A[32]^B[32]^F[32]^F33[33];
            end
            4'b0011: begin
                F33[33:1] <= B - A;
                NZCV[2] <= ~F33[33];
                F[32:1] <= F33[32:1];
                NZCV[1] <= A[32]^B[32]^F[32]^F33[33];
            end
            4'b0100: begin
                {NZCV[2],F} <= A + B;
                NZCV[1] <= A[32]^B[32]^F[32]^NZCV[2];
            end
            4'b0101: begin
                {NZCV[2],F} <= A + B + CF;
                NZCV[1] <= A[32]^B[32]^F[32]^NZCV[2];
            end
            4'b0110: begin
                F33[33:1] <= A - B + CF - 1;
                NZCV[2] <= ~F33[33];
                F[32:1] <= F33[32:1];
                NZCV[1] <= A[32]^B[32]^F[32]^F33[33];
            end
            4'b0111: begin
                F33[33:1] <= B - A + CF - 1;
                NZCV[2] <= ~F33[33];
                F[32:1] <= F33[32:1];
                NZCV[1] <= A[32]^B[32]^F[32]^F33[33];
            end
            4'b1000: begin
                F <= A;
            end
            4'b1010: begin
                F33[33:1] <= A - B + 4;
                NZCV[2] <= ~F33[33];
                F[32:1] <= F33[32:1];
                NZCV[1] <= A[32]^B[32]^F[32]^F33[33];
            end
            4'b1100: begin
                F <= A | B;
            end
            4'b1101: begin
                F <= B;
            end
            4'b1110: begin
                F <= A & (~B);
            end
            4'b1111: begin
                F <= ~B;
            end
            default:begin
               F[32:1] <= 32'hxxxxxxxx; 
            end
        endcase
        
        NZCV[4] <= F[32];
        if (F == 0) 
            begin
                NZCV[3] <= 1;
            end 
        else
            begin
                NZCV[3] <= 0;
            end
        if((ALU_OP >= 4'b0010 && ALU_OP <= 4'b0111) ||ALU_OP == 4'b1010)
            begin
                //NZCV[2]已经在运算中赋值
                //NZCV[1] <= A[32]^B[32]^F[32]^F33;
            end
        else
            begin
                NZCV[2] <= Shift_Carry_Out;
                NZCV[1] <= VF;
            end
    end
endmodule
