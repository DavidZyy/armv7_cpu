module logical_shift_left(SHIFT_OP, Shift_Data, Shift_Num, Shift_Out,
Shift_Carry_Out);//要移位的数据，移位位数，移位的输出
    input [3:1] SHIFT_OP;
    input [32:1] Shift_Data;
    input [8:1] Shift_Num;
    output reg [32:1] Shift_Out;
    output reg Shift_Carry_Out;
    always@(*)
    begin
        if(Shift_Num == 0)
            begin
                Shift_Out = Shift_Data;
                Shift_Carry_Out = 1'bx;//不移位，进位位为未定态
            end
        else if(Shift_Num >= 1 && Shift_Num <= 32)
            begin
                Shift_Out <= (Shift_Data << Shift_Num[8:1]);
                Shift_Carry_Out = Shift_Data[33-Shift_Num];
            end
        else
            begin
                Shift_Out <= (Shift_Data << Shift_Num[8:1]);
                Shift_Carry_Out = 0;
            end
    end
endmodule