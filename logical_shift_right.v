module logical_shift_right(SHIFT_OP, Shift_Data, Shift_Num, Shift_Out,
Shift_Carry_Out);//要移位的数据，移位位数，移位的输出
    input [3:1] SHIFT_OP;
    input [32:1] Shift_Data;
    input [8:1] Shift_Num;
    output reg [32:1] Shift_Out;
    output reg Shift_Carry_Out;
    always@(*)
        begin
            if(Shift_Num == 0)
                if(SHIFT_OP[1])
                    begin
                        Shift_Out = Shift_Data;
                        Shift_Carry_Out = 1'bx; 
                    end
                else//当Shift_Num和Shift_OP[1]都为0时，等价于右移32位。
                    begin
                        Shift_Out = 0;
                        Shift_Carry_Out = Shift_Data[32];
                    end
            else if(Shift_Num >= 1 && Shift_Num <= 32)
                begin
                    Shift_Out <= (Shift_Data >> Shift_Num[8:1]);
                    Shift_Carry_Out = Shift_Data[Shift_Num];
                end
            else
                begin
                    Shift_Out <= (Shift_Data >> Shift_Num[8:1]);
                    Shift_Carry_Out = 0;
                end 
        end
endmodule