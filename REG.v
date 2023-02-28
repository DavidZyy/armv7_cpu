/* general reg file */
module REG(
    // input clk, rst, R_Addr_A, R_Addr_B, R_Addr_C, M, W_Addr, Write_Reg, Write_PC, W_Data, PC_New,
    // output R_Data_A, R_Data_B, R_Data_C, R15
    input clk,
    input rst,
    input [3:0] R_Addr_A,
    input [3:0] R_Addr_B,
    input [3:0] R_Addr_C,
    input [4:0] M,
    input [3:0] W_Addr,
    input Write_Reg,
    input Write_PC,
    input [31:0] W_Data,
    input [31:0] PC_New,

    output reg [31:0] R_Data_A,
    output reg [31:0] R_Data_B,
    output reg [31:0] R_Data_C,
    output reg [31:0] R15
);
//输入
// wire clk;
// wire rst;
// wire [3:0] R_Addr_A;
// wire [3:0] R_Addr_B;
// wire [3:0] R_Addr_C;
// wire [4:0] M;
// wire [3:0] W_Addr;
// wire Write_Reg;
// wire Write_PC;
// wire [31:0] W_Data;
// wire [31:0] PC_New;
//输出
// reg [31:0] R_Data_A;
// reg [31:0] R_Data_B;
// reg [31:0] R_Data_C;
// reg [31:0] R15;


wire unclk;
assign unclk = ~clk;
//寄存器堆
//user/sys模式
reg [31:0] R[0:15];
//fiq模式
reg [31:0] R8_fiq;
reg [31:0] R9_fiq;
reg [31:0] R10_fiq;
reg [31:0] R11_fiq;
reg [31:0] R12_fiq;
reg [31:0] R13_fiq;
reg [31:0] R14_fiq;
//irq模式
reg [31:0] R13_irq;
reg [31:0] R14_irq;
//abt模式
reg [31:0] R13_abt;
reg [31:0] R14_abt;
//svc模式
reg [31:0] R13_svc;
reg [31:0] R14_svc;
//und模式
reg [31:0] R13_und;
reg [31:0] R14_und;
//mon模式
reg [31:0] R13_mon;
reg [31:0] R14_mon;
//hyp模式
reg [31:0] R13_hyp;

integer i;
initial
begin
    for(i=0;i<16;i=i+1) R[i]<=0;
    R8_fiq <= 0;
    R9_fiq <= 0;
    R10_fiq <= 0;
    R11_fiq <= 0;
    R12_fiq <= 0;
    R13_fiq <= 0;
    R14_fiq <= 0;
    R13_irq <= 0;
    R14_irq <= 0;
    R13_abt <= 0;
    R14_abt <= 0;
    R13_svc <= 0;
    R14_svc <= 0;
    R13_und <= 0;
    R14_und <= 0;
    R13_mon <= 0;
    R14_mon <= 0;
    R13_hyp <= 0;
end

/* wirte, choose register first, and then choose mode */
always@(posedge unclk or posedge rst)//寄存器写入
    begin
        if(rst)//清零信号
            begin
                for(i=0; i<16; i=i+1) R[i]<=0;
                R8_fiq <= 0;
                R9_fiq <= 0;
                R10_fiq <= 0;
                R11_fiq <= 0;
                R12_fiq <= 0;
                R13_fiq <= 0;
                R14_fiq <= 0;
                R13_irq <= 0;
                R14_irq <= 0;
                R13_abt <= 0;
                R14_abt <= 0;
                R13_svc <= 0;
                R14_svc <= 0;
                R13_und <= 0;
                R14_und <= 0;
                R13_mon <= 0;
                R14_mon <= 0;
                R13_hyp <= 0;
            end
                
        else
            if(M[4])//使能端开启。
            begin
                if(0 <= W_Addr && W_Addr <= 7)//0~7号寄存器是所有模式公用的
                    begin
                        if(Write_Reg) R[W_Addr]<=W_Data;
                    end
    
                else if(8 <= W_Addr && W_Addr <= 12)//只有fiq模式单独使用一套8~12号寄存器
                    begin
                        if(M[3:0] == 4'b0001)//如果是fiq模式
                            begin
                                if(Write_Reg)
                                    begin
                                        case(W_Addr)
                                            4'd8: begin
                                            R8_fiq <= W_Data;
                                            end
                                            4'd9: begin
                                            R9_fiq <= W_Data;
                                            end
                                            4'd10: begin
                                            R10_fiq <= W_Data;
                                            end
                                            4'd11: begin
                                            R11_fiq <= W_Data;
                                            end
                                            4'd12: begin
                                            R12_fiq <= W_Data;
                                            end
                                        endcase
                                    end
                            end
                        else//如果是其他模式
                            begin
                                if(Write_Reg) R[W_Addr]<=W_Data;
                            end
                    end
                else if(W_Addr == 13)
                    begin
                        if(Write_Reg)
                            begin
                                case(M[3:0])
                                    4'b0000: begin
                                      R[13] <= W_Data;
                                    end
                                    4'b0001: begin
                                      R13_fiq <= W_Data;
                                    end
                                    4'b0010: begin
                                      R13_irq <= W_Data;
                                    end
                                    4'b0011: begin
                                      R13_svc <= W_Data;
                                    end
                                    4'b0110: begin
                                      R13_mon <= W_Data;
                                    end
                                    4'b0111: begin
                                      R13_abt <= W_Data;
                                    end
                                    4'b1010: begin
                                      R13_hyp <= W_Data;
                                    end
                                    4'b1011: begin
                                      R13_und <= W_Data;
                                    end
                                    4'b1111: begin
                                      R[13] <= W_Data;
                                    end
                                endcase
                            end
                    end
                else if(W_Addr == 14)
                    begin
                        if(Write_Reg)
                            begin
                                case(M[3:0])
                                    4'b0000: begin
                                      R[14] <= W_Data;
                                    end
                                    4'b0001: begin
                                      R14_fiq <= W_Data;
                                    end
                                    4'b0010: begin
                                      R14_irq <= W_Data;
                                    end
                                    4'b0011: begin
                                      R14_svc <= W_Data;
                                    end
                                    4'b0110: begin
                                      R14_mon <= W_Data;
                                    end
                                    4'b0111: begin
                                      R14_abt <= W_Data;
                                    end
                                    4'b1011: begin
                                      R14_und <= W_Data;
                                    end
                                    4'b1111: begin
                                      R[14] <= W_Data;
                                    end
                                endcase
                            end
                    end
                else//R[15]
                    begin
                        if(Write_Reg && Write_PC) R[15]<=PC_New;
                    end
            end
   	end

/*read, choose mode first, than choose register */
always@(*)//寄存器读出
    begin
        R15 <= R[15];
        case (M[3:0])//根据模式选择读取的寄存器
            4'b0000: begin//user模式
                R_Data_A<=R[R_Addr_A];
                R_Data_B<=R[R_Addr_B];
                R_Data_C<=R[R_Addr_C];
            end
            4'b0001: begin//fiq模式
                if((0 <= R_Addr_A && R_Addr_A <= 7) || R_Addr_A == 15)
                    R_Data_A <= R[R_Addr_A];
                else
                    begin
                        case (R_Addr_A)
                            4'd8: begin
                                R_Data_A <= R8_fiq;
                            end
                            4'd9: begin
                                R_Data_A <= R9_fiq;
                            end
                            4'd10: begin
                                R_Data_A <= R10_fiq;
                            end
                            4'd11: begin
                                R_Data_A <= R11_fiq;
                            end
                            4'd12: begin
                                R_Data_A <= R12_fiq;
                            end
                            4'd13: begin
                                R_Data_A <= R13_fiq;
                            end
                            4'd14: begin
                                R_Data_A <= R14_fiq;
                            end
                        endcase
                    end 
                if((0 <= R_Addr_B && R_Addr_B<= 7 )|| R_Addr_B == 15)
                    R_Data_B <= R[R_Addr_B];
                else
                    begin
                        case (R_Addr_B)
                            4'd8: begin
                                R_Data_B <= R8_fiq;
                            end
                            4'd9: begin
                                R_Data_B <= R9_fiq;
                            end
                            4'd10: begin
                                R_Data_B <= R10_fiq;
                            end
                            4'd11: begin
                                R_Data_B <= R11_fiq;
                            end
                            4'd12: begin
                                R_Data_B <= R12_fiq;
                            end
                            4'd13: begin
                                R_Data_B <= R13_fiq;
                            end
                            4'd14: begin
                                R_Data_B <= R14_fiq;
                            end
                        endcase
                    end 
                if((0 <= R_Addr_C && R_Addr_C <= 7) || R_Addr_C == 15)
                    R_Data_C <= R[R_Addr_C];
                else
                    begin
                        case (R_Addr_C)
                            4'd8: begin
                                R_Data_C <= R8_fiq;
                            end
                            4'd9: begin
                                R_Data_C <= R9_fiq;
                            end
                            4'd10: begin
                                R_Data_C <= R10_fiq;
                            end
                            4'd11: begin
                                R_Data_C <= R11_fiq;
                            end
                            4'd12: begin
                                R_Data_C <= R12_fiq;
                            end
                            4'd13: begin
                                R_Data_C <= R13_fiq;
                            end
                            4'd14: begin
                                R_Data_C <= R14_fiq;
                            end
                        endcase
                    end 
            end
            4'b0010: begin//irq模式
                if((0 <= R_Addr_A && R_Addr_A <= 12) || R_Addr_A == 15)
                    R_Data_A = R[R_Addr_A];
                else
                    begin
                        case (R_Addr_A)
                            4'd13: begin
                                R_Data_A <= R13_irq;
                            end
                            4'd14: begin
                                R_Data_A <= R14_irq;
                            end
                        endcase
                    end 
                if((0 <= R_Addr_B && R_Addr_B <= 12) || R_Addr_B == 15)
                    R_Data_B = R[R_Addr_B];
                else
                    begin
                        case (R_Addr_B)
                            4'd13: begin
                                R_Data_B <= R13_irq;
                            end
                            4'd14: begin
                                R_Data_B <= R14_irq;
                            end
                        endcase
                    end 
                if((0 <= R_Addr_C && R_Addr_C <= 12) || R_Addr_C == 15)
                    R_Data_C = R[R_Addr_C];
                else
                    begin
                        case (R_Addr_C)
                            4'd13: begin
                                R_Data_C <= R13_irq;
                            end
                            4'd14: begin
                                R_Data_C <= R14_irq;
                            end
                        endcase
                    end 
            end
            4'b0011: begin//svc模式
                if((0 <= R_Addr_A && R_Addr_A <= 12)  || R_Addr_A == 15)
                    R_Data_A = R[R_Addr_A];
                else
                    begin
                        case (R_Addr_A)
                            4'd13: begin
                                R_Data_A <= R13_svc;
                            end
                            4'd14: begin
                                R_Data_A <= R14_svc;
                            end
                        endcase
                    end 
                if((0 <= R_Addr_B && R_Addr_B <= 12)  || R_Addr_B == 15)
                    R_Data_B = R[R_Addr_B];
                else
                    begin
                        case (R_Addr_B)
                            4'd13: begin
                                R_Data_B <= R13_svc;
                            end
                            4'd14: begin
                                R_Data_B <= R14_svc;
                            end
                        endcase
                    end 
                if((0 <= R_Addr_C && R_Addr_C <= 12) || R_Addr_C == 15)
                    R_Data_C = R[R_Addr_C];
                else
                    begin
                        case (R_Addr_C)
                            4'd13: begin
                                R_Data_C <= R13_svc;
                            end
                            4'd14: begin
                                R_Data_C <= R14_svc;
                            end
                        endcase
                    end 
            end
            4'b0110: begin//mon模式
                if((0 <= R_Addr_A && R_Addr_A <= 12) || R_Addr_A == 15)
                    R_Data_A = R[R_Addr_A];
                else
                    begin
                        case (R_Addr_A)
                            4'd13: begin
                                R_Data_A <= R13_mon;
                            end
                            4'd14: begin
                                R_Data_A <= R14_mon;
                            end
                        endcase
                    end 
                if((0 <= R_Addr_B && R_Addr_B <= 12) || R_Addr_B == 15)
                    R_Data_B = R[R_Addr_B];
                else
                    begin
                        case (R_Addr_B)
                            4'd13: begin
                                R_Data_B <= R13_mon;
                            end
                            4'd14: begin
                                R_Data_B <= R14_mon;
                            end
                        endcase
                    end 
                if((0 <= R_Addr_C && R_Addr_C <= 12) || R_Addr_C == 15)
                    R_Data_C = R[R_Addr_C];
                else
                    begin
                        case (R_Addr_C)
                            4'd13: begin
                                R_Data_C <= R13_mon;
                            end
                            4'd14: begin
                                R_Data_C <= R14_mon;
                            end
                        endcase
                    end 
            end
            4'b0111: begin//abt模式
                if((0 <= R_Addr_A && R_Addr_A <= 12) || R_Addr_A == 15)
                    R_Data_A = R[R_Addr_A];
                else
                    begin
                        case (R_Addr_A)
                            4'd13: begin
                                R_Data_A <= R13_abt;
                            end
                            4'd14: begin
                                R_Data_A <= R14_abt;
                            end
                        endcase
                    end 
                if((0 <= R_Addr_B && R_Addr_B <= 12)  || R_Addr_B == 15)
                    R_Data_B = R[R_Addr_B];
                else
                    begin
                        case (R_Addr_B)
                            4'd13: begin
                                R_Data_B <= R13_abt;
                            end
                            4'd14: begin
                                R_Data_B <= R14_abt;
                            end
                        endcase
                    end 
                if((0 <= R_Addr_C && R_Addr_C <= 12)  || R_Addr_C == 15)
                    R_Data_C = R[R_Addr_C];
                else
                    begin
                        case (R_Addr_C)
                            4'd13: begin
                                R_Data_C <= R13_abt;
                            end
                            4'd14: begin
                                R_Data_C <= R14_abt;
                            end
                        endcase
                    end 
            end
            4'b1010: begin//hyp模式，妹有R14寄存器
                if((0 <= R_Addr_A && R_Addr_A <= 12) || R_Addr_A == 15)
                    R_Data_A = R[R_Addr_A];
                else
                    begin
                        R_Data_A <= R13_hyp;
                    end 
                if((0 <= R_Addr_B && R_Addr_B <= 12) || R_Addr_B == 15)
                    R_Data_B = R[R_Addr_B];
                else
                    begin
                        R_Data_B <= R13_hyp;
                    end 
                if((0 <= R_Addr_C && R_Addr_C <= 12) || R_Addr_C == 15)
                    R_Data_C = R[R_Addr_C];
                else
                    begin
                        R_Data_C <= R13_hyp;
                    end 
            end
            4'b1011: begin//und模式
                if((0 <= R_Addr_A && R_Addr_A <= 12)  || R_Addr_A == 15)
                    R_Data_A = R[R_Addr_A];
                else
                    begin
                        case (R_Addr_A)
                            4'd13: begin
                                R_Data_A <= R13_und;
                            end
                            4'd14: begin
                                R_Data_A <= R14_und;
                            end
                        endcase
                    end 
                if((0 <= R_Addr_B && R_Addr_B <= 12) || R_Addr_B == 15)
                    R_Data_B = R[R_Addr_B];
                else
                    begin
                        case (R_Addr_B)
                            4'd13: begin
                                R_Data_B <= R13_und;
                            end
                            4'd14: begin
                                R_Data_B <= R14_und;
                            end
                        endcase
                    end 
                if((0 <= R_Addr_C && R_Addr_C <= 12)  || R_Addr_C == 15)
                    R_Data_C = R[R_Addr_C];
                else
                    begin
                        case (R_Addr_C)
                            4'd13: begin
                                R_Data_C <= R13_und;
                            end
                            4'd14: begin
                                R_Data_C <= R14_und;
                            end
                        endcase
                    end 
            end
            4'b1111: begin
                R_Data_A=R[R_Addr_A];
                R_Data_B=R[R_Addr_B];
                R_Data_C=R[R_Addr_C];
            end
            default:begin
                R_Data_A<=32'hxxxxxxxx;
                R_Data_B<=32'hxxxxxxxx;
                R_Data_C<=32'hxxxxxxxx;
            end
    endcase    
end
endmodule
