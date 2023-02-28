//ALU的主函数，定义了复用开关给ALU的输入输出赋值，
//带桶型移位器。
module CPU_Main(clk, sw, swb, //输入
    led, which, seg, enable);//输出
    input clk;
    input [32:1] sw;
    input [6:1] swb;

    output reg [32:1] led;
    output [2:0] which;
    output [7:0] seg;
    output reg enable = 1;

    wire swb_rst = swb[1];
    wire swb_clk = swb[2];

    wire [31:0] IR;
    wire [31:0] A;
    wire [31:0] B;
    wire [31:0] C;
    wire [31:0] F;
    wire [31:0] Shift_Out;
    wire [31:0] W_Data;
    wire [3:0] NZCV;
    wire [7:0] PC;
    wire Write_PC;
    wire Write_IR;
    wire Write_Reg;
    wire LA;
    wire LB;
    wire LC;
    wire LF;
    wire [1:0] rm_imm_s;
    wire [2:0] rs_imm_s;
    wire [3:0] ALU_OP;
    wire [2:0] SHIFT_OP;
    wire S;
    
   

    reg [31:0]Display_Data;
    reg Display_Flag = 0;
    reg [3 :0]swb6_count = 1'b0;
    always @(posedge swb[6])
    begin
      swb6_count <= swb6_count + 1'b1;
      case (swb6_count % 6)
        4'd1:
        begin
          Display_Data <= IR;
          Display_Flag <= 0;
        end
        4'd2:
        begin
          Display_Data <= A;
          Display_Flag <= 0;
        end
        4'd3:
        begin
          Display_Data <= B;
          Display_Flag <= 0;
        end
        4'd4:
        begin
          Display_Data <= C;
          Display_Flag <= 0;
        end
        4'd5:
        begin
          Display_Data <= F;
          Display_Flag <= 0;
        end
        4'd6:
        begin
          Display_Data <= Shift_Out;
          Display_Flag <= 0;
        end
        4'd7:
        begin
          Display_Data <= W_Data;
          Display_Flag <= 0;
        end
        4'd0:
        begin
          Display_Flag <= 1;
        end
      endcase
    end


    always @(*) begin
        led[32:29] <= NZCV;
        led[27:22] <= PC[7:2];

        led[20] <= Write_PC;
        led[19] <= Write_IR;
        led[18] <= Write_Reg;
        led[17] <= L_A;
        led[16] <= L_B;
        led[15] <= L_C;
        led[14] <= L_F;

        led[13:12] <=  rm_imm_s;
        led[11:9] <= rs_imm_s;
        led[8:5] <= ALU_OP;
        led[4:2] <= SHIFT_OP;
        led[1] <= S;
    end

    CPU_10 CPU(
            .clk(swb_clk), 
            .rst(swb_rst),
            .IR(IR),
            .A(A),
            .B(B),
            .C(C),
            .F(F),
            .Shift_Out(Shift_Out),
            .W_Data(W_Data),
            .NZCV(NZCV),
            .PC(PC),
            .Write_PC(Write_PC),
            .Write_IR(Write_IR),
            .Write_Reg(Write_Reg),
            .L_A(L_A),
            .L_B(L_B),
            .L_C(L_C),
            .L_F(L_F),
            .rm_imm_s(rm_imm_s),
            .rs_imm_s(rs_imm_s),
            .ALU_OP(ALU_OP),
            .SHIFT_OP(SHIFT_OP),
            .S(S)
    );
    Display Display_Instance(.clk(clk), .data(Display_Data), .Display_Flag(Display_Flag),
        .which(which), .seg(seg));
endmodule