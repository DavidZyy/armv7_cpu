`timescale 1ns / 1ps
module barrel_shift(Shift_Data, Shift_Num, SHIFT_OP, Carry_flag, Shift_Out, Shift_Carry_Out);
    input [32:1]Shift_Data;
    input [3:1]SHIFT_OP;
    input [8:1]Shift_Num;
    input Carry_flag;

    output reg Shift_Carry_Out;
    output reg [32:1]Shift_Out;

    wire Shift_Carry_Out_temp[4:1];
    wire [32:1]LSL_out;//每种移位的输出
    wire [32:1]LRL_out;
    wire [32:1]ASR_out;
    wire [32:1]RSR_out;
    
    //生成移位实例
    logical_shift_left LSL(.SHIFT_OP(SHIFT_OP),.Shift_Data(Shift_Data),.Shift_Num(Shift_Num),.Shift_Out(LSL_out),.Shift_Carry_Out(Shift_Carry_Out_temp[1]));
    
    logical_shift_right LRL(.SHIFT_OP(SHIFT_OP),.Shift_Data(Shift_Data),.Shift_Num(Shift_Num),.Shift_Out(LRL_out),.Shift_Carry_Out(Shift_Carry_Out_temp[2]));
    
    arithmetic_shift_right ASR(.SHIFT_OP(SHIFT_OP),.Shift_Data(Shift_Data),.Shift_Num(Shift_Num),.Shift_Out(ASR_out),.Shift_Carry_Out(Shift_Carry_Out_temp[3]));
    
    rotate_right ROR(.SHIFT_OP(SHIFT_OP),.Shift_Data(Shift_Data),.Shift_Num(Shift_Num),.Carry_flag(Carry_flag),.Shift_Out(RSR_out),.Shift_Carry_Out(Shift_Carry_Out_temp[4]));


    always @(*) 
    begin
            case (SHIFT_OP[3:2])
                2'b00: begin
                    Shift_Out[32:1] <= LSL_out[32:1];
                    Shift_Carry_Out <= Shift_Carry_Out_temp[1];
                end
                2'b01: begin
                    Shift_Out[32:1] <= LRL_out[32:1];
                    Shift_Carry_Out <= Shift_Carry_Out_temp[2];
                end
                2'b10: begin
                    Shift_Out[32:1] <= ASR_out[32:1];
                    Shift_Carry_Out <= Shift_Carry_Out_temp[3];
                end

                2'b11: begin
                    Shift_Out[32:1] <= RSR_out[32:1];
                    Shift_Carry_Out <= Shift_Carry_Out_temp[4];
                end 
            endcase    
    end

endmodule
