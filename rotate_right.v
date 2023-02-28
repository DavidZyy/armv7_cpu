module rotate_right(SHIFT_OP, Shift_Data, Shift_Num, Carry_flag, Shift_Out,
Shift_Carry_Out);//要移位的数据，移位位数，移位的输出
    input [3:1] SHIFT_OP;
    input [32:1] Shift_Data;
    input [8:1] Shift_Num;
    input Carry_flag;
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
                else
                    begin
                        Shift_Out = {Carry_flag, Shift_Data[32:2]};
                        Shift_Carry_Out = Shift_Data[1];
                    end
            else if(Shift_Num >= 1 && Shift_Num <= 32)
                begin
                    //中间使用“|”连接，等价于循环右移。
                    Shift_Out <= (Shift_Data << (32-Shift_Num)) | (Shift_Data >>
                    Shift_Num);;
                    Shift_Carry_Out = Shift_Data[Shift_Num];
                end
            else
                begin
                    //中间使用“|”连接，等价于循环右移。
                    Shift_Out <= (Shift_Data << (32-Shift_Num[5:1])) | (Shift_Data >>
                    Shift_Num[5:1]);
                    if(Shift_Num[5:1] == 0)//加入Shift_Num是64，那么应该等价于右移32位
                        Shift_Carry_Out = Shift_Data[32];
                    else
                        Shift_Carry_Out = Shift_Data[Shift_Num[5:1]];
                end
        end

endmodule