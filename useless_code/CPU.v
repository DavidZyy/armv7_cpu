module CPU(
    input clk, rst,
    output IR, R_Date_rn, R_Date_rm, R_Date_rs, F, NZCV, PC, Write_PC, Write_IR, Write_Reg, L_rn, L_rm, L_rs, L_rd, rm_imm_s, rs_imm_s, ALU_OP, SHIFT_OP, S
    );

    //定义输出
    wire [31:0] R_Date_rn;
    wire [31:0] R_Date_rm;
    wire [31:0] R_Date_rs;
    reg [31:0] W_Data;
    wire [31:0] F;
    wire [31:0] A;
    wire [31:0] B;

    reg [3:0] NZCV;
    wire [3:0] NZCV_temp;//存储ALU输出的NZCV信号，根据S信号选择是否打入NZCV中
    
    wire [7:0] PC;
   
   //控制信号
    reg Write_PC;
    reg Write_IR;
    reg Write_Reg;
    reg L_rn;
    reg L_rm;
    reg L_rs;
    reg L_rd;
    reg [1:0] rm_imm_s;
    reg [2:0] rs_imm_s;
    reg S;//NZCV打入控制信号
    reg [1:0] PC_s;//PC新地址来源控制信号
    reg ALU_A_s;//输入ALU的A端口的选择信号
    reg ALU_B_s;//输入ALU的B端口的选择信号
    reg rd_s;

    //OP相关信号
    reg [3:0] OP_Code;
    reg [3:0] ALU_OP;
    reg [2:0] SHIFT_OP;
    

    reg Und_Ins;//译码失败标识，译码失败时为1

    //machine state decode,定义状态
    parameter IDLE = 4'd0;
    parameter S0 = 4'd1;
    parameter S1 = 4'd2;
    parameter S2 = 4'd3;
    parameter S3 = 4'd4;
    /********新增加7~11这5个阶段********/
    parameter S7 = 4'd8;
    parameter S8 = 4'd9;
    parameter S9 = 4'd10;
    parameter S10 = 4'd11;
    parameter S11 = 4'd12;
    /*******************************/
    parameter M = 5'b10000;
    //指令类型，根据指令的类型决定cpu的状态转化，目前有4种类型：
    //0表示：数据处理指令：S0->S1->S2->S3->S0
    //1表示：BX指令：S0->S1->S7
    //2表示：B指令：S0->S8->S9->S0
    //3表示：BL指令：S0->S10->S11->S9->S0
    parameter Instruction_Type = 4'd0;


    //下一个状态和当前状态寄存器
    reg [3:0] st_next ;
    reg [3:0] st_cur ;

    wire [31:0] IR;//来自指令寄存器的内容
    wire IR_Flag;//取指令成功的标志，成功时取1

    //立即数寄存器
    reg [4:0]imm5;
    reg [1:0]type;
    reg [11:0]imm12;
    reg [23:0] imm24;

    //寄存器堆读端口和写端口
    reg [3:0] R_Addr_rn;
    reg [3:0] R_Addr_rm;
    reg [3:0] R_Addr_rs;
    reg [3:0] W_Addr_rd;
    
    wire [3:0] W_Addr;

    //移位数据,移位位数,移位输出
    reg [31:0] Shift_Data;
    reg [7:0] Shift_Num;
    wire [31:0] Shift_Out;

    //(1) state transfer，状态转换
    always @(negedge clk or posedge rst) begin
        if (rst) begin
            //状态初始化
            st_cur <= IDLE;
        end
        else begin
            st_cur <= st_next;
        end
    end

    //(2) state switch, using block assignment for combination-logic
    //all case items need to be displayed completely    下一个状态
    always @(*) begin
        case(st_cur)
            IDLE:
                st_next = S0;
            S0: begin
                if(IR_Flag) begin//cond条件成立
                    case (Instruction_Type)
                        2: st_next = S8;//B指令
                        3: st_next = s10;//BL指令
                        default: st_next = S1;
                    endcase
                end
                else
                    st_next = S0;
            end
            S1:begin
                if(!Und_Ins)//译码成功
                    case (Instruction_Type)
                        1: st_next = S7;//BX指令
                        default: st_next = S1;
                    endcase
                else
                    st_next = S0;
            end
            S2:begin
                st_next = S3;
            end
            S3:begin
                st_next = S0;
            end
            S7: st_next = S0;
            S8: st_next = S9;
            S9: st_next = S0;
            S10: st_next = S11;
            S11: st_next = S9;
        endcase
    end

    //(3) output logic, using non-block assignment  控制信号。
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            //所有控制信号初始化
            NZCV <= 0;
            Write_PC <= 0;
            Write_IR <= 0;
            Write_Reg <= 0;
            L_rn <= 0;
            L_rs <= 0;
            L_rm <= 0;
            L_rd <= 0;
            rm_imm_s <= 0;
            rs_imm_s <= 0;
            SHIFT_OP <= 0;
            ALU_OP <= 0;
            ALU_A_s <= 0;
            ALU_B_s <= 0;
            PC_s <= 0;
        end
        else begin
            //修改Write_IR,Write_PC
            //只在S0状态下Write_IR,Write_PC = 1,。其他状态为0。
            case(st_cur)
                S0: begin
                    Write_IR <= 1;
                    Write_PC <= 1;
                end
                S7: begin
                    Write_PC <= 1;
                end
                default:begin
                    Write_IR <= 0;
                    Write_PC <= 0;
                end
            endcase

            case(st_cur)
                S8: begin
                    ALU_A_s <= 1;
                    ALU_B_s <= 1;
                end
                S10: begin
                    ALU_A_s <= 1;
                    ALU_B_s <= 0;
                end
                S11: begin
                    ALU_A_s <= 1;
                    ALU_B_s <= 1;
                end
                default:begin
                    ALU_A_s <= 0;
                    ALU_B_s <= 0;
                end
            endcase

            //修改Write_Reg
            //只在S3状态下Write_Reg = 1,。其他状态为0。
            case(st_cur)
                S3,s11: begin
                    Write_Reg <= 1;
                end
                default: begin
                    Write_Reg <= 0;
                end
            endcase

            case (sr_cur)
                S11: rd_s <= 1;
                default rd_s <= 0;
            endcase

            case(st_cur)
                S7: PC_s <= 1;
                S9: PC_s <= 2;
                default: PC_s <= 0;
            endcase

            //译码
            case(st_cur)
                S0: begin
                    Und_Ins <= 0;
                end
                S1: begin//s1时译码并读取寄存器内容
                        OP_Code <= IR[24:21];
                        S <= IR[20];
                        R_Addr_rn <= IR[19:16];
                        W_Addr_rd <= IR[15:12];
                        R_Addr_rs <= IR[11:8];
                        SHIFT_OP <= IR[6:4];
                        R_Addr_rm <= IR[3:0];
                        imm12 <= IR[11:0];
                        imm5 <= IR[11:7];
                        L_rn <= 1'b1;
                    if(IR[27:25] == 3'b000 && IR[4] == 0 && IR[15:12] != 4'b1111) begin //Dp0格式
                        rm_imm_s <= 1'b0;
                        rs_imm_s <= 2'b00;
                        L_rm <= 1;
                        L_rs <= 0;
                    end
                    else if(IR[27:25] == 3'b000 && IR[7] == 0 && IR[4] == 1 && IR[15:12] != 4'b1111) begin //Dp1格式
                        rm_imm_s <= 1'b0;
                        rs_imm_s <= 2'b01;
                        L_rm <= 1;
                        L_rs <= 1;
                    end
                    else if(IR[27:25] == 3'b001 && IR[15:12] != 4'b1111)begin //Dp2格式
                        rm_imm_s <= 1'b0;
                        rs_imm_s <= 2'b10;
                        L_rm <= 0;
                        L_rs <= 0;
                    end
                    else begin
                        Und_Ins <= 1;
                    end
                end
                S2: begin//s2时对译码内容进行运处理，输入到组合运算器中
                    case(OP_Code)//通过OPCODE获取ALU_OP
                        4'b0000: ALU_OP = 4'b0000;
                        4'b0001: ALU_OP = 4'b0001;
                        4'b0010: ALU_OP = 4'b0010;
                        4'b0011: ALU_OP = 4'b0011;
                        4'b0100: ALU_OP = 4'b0100;
                        4'b0101: ALU_OP = 4'b0101;
                        4'b0110: ALU_OP = 4'b0110;
                        4'b0111: ALU_OP = 4'b0111;
                        4'b1000: ALU_OP = 4'b0000;
                        4'b1001: ALU_OP = 4'b0001;
                        4'b1010: ALU_OP = 4'b0010;
                        4'b1011: ALU_OP = 4'b0100;
                        4'b1100: ALU_OP = 4'b1100;
                        4'b1101: ALU_OP = 4'b1101;
                        4'b1110: ALU_OP = 4'b1110;
                        4'b1111: ALU_OP = 4'b1111;
                    endcase

                    case (rm_imm_s)
                        1'b0:begin
                            Shift_Data <= R_Addr_rm;
                        end 
                        1'b1:begin
                            Shift_Data <= {24'h000000,imm12[7:0]};
                        end
                    endcase
                    case (rs_imm_s)//获取Shift相关信号
                        2'b00:begin
                            Shift_Num <= {3'b000,imm5};
                        end 
                        2'b01:begin
                            Shift_Num <= R_Date_rs[7:0];
                        end
                        2'b10:begin
                            Shift_Num <= {4'b0000,imm12[11:8],1'b0};
                            SHIFT_OP <= 3'b111;
                        end
                    endcase
                end

                S3:begin//s3将获取运算结果
                    W_Data <= F;
                    if(S) begin
                        NZCV <= NZCV_temp;
                    end
                end

                S7: begin
                    //前面的case语句已经把控制信号打开了，这里不用做什么了。
                end

                S8: begin
                    ALU_OP <= 0100;
                    S <= 0;
                    imm24 <= IR[23:0];
                    B <= {2'h00, imm24};//桶型移位器和Alu联合上面没有B的接口，待改。
                end

                S9: begin
                    //前面的case语句已经把控制信号打开了，这里不用做什么了。
                end

                S10: begin
                    //控制信号已经打开
                    ALU_OP <= 1000;
                    S <= 0;
                end

                S11: begin
                    ALU_OP <= 01000;
                    S <= 0;
                    imm24 <= IR[23:0];
                    B <= {2'h00, imm24};//桶型移位器和Alu联合上面没有B的接口，待改。
                end

            endcase
        end
    
    end

    //下跳沿IR读入指令后，判断指令的类型
    always @(negedge clk) begin
        if(st_cur == S0)begin
            case(IR[27:24])
                4'b1010: Instruction_Type <= 2;//B指令
                4'b1011: Instruction_Type <= 3;//BL指令
                4'b0001: Instruction_Type <= 1;//B指令
                default: Instruction_Type <= 0;//数据处理指令
            endcase
        end  
    end

    assign A = ALU_A_s ? PC : R_Date_rn;
    assign W_Addr = rd_s ? 4'b1100 : W_Addr_rd;

    IF IF (
        .clk(clk),
        .rst(rst),
        .NZCV(NZCV),
        .Write_IR(Write_IR),
        .Write_PC(Write_PC),
        .PC(PC),
        .IR(IR),
        .IR_Flag(IR_Flag),
        .PC_s(PC_s),
        .B(R_Date_rm),
        .F(F)
    );

    ALU_with_shifter AWS(.A(A),
                        .Shift_Data(Shift_Data),
                        .Shift_Num(Shift_Num),
                        .SHIFT_OP(SHIFT_OP),
                        .ALU_OP(ALU_OP),
                        .CF(NZCV[1]),
                        .VF(NZCV[0]),
                        .F(F),
                        .NZCV(NZCV_temp));


    REG REG (
        .clk(clk),
        .rst(rst),
        .R_Addr_A(R_Addr_rn),
        .R_Addr_B(R_Addr_rm),
        .R_Addr_C(R_Addr_rs),
        .M(5'b10000),
        .W_Addr(W_Addr),
        .W_Data(W_Data),
        .Write_Reg(Write_Reg),
        .R_Data_A(R_Date_rn),
        .R_Data_B(R_Date_rm),
        .R_Data_C(R_Date_rs)
    );


endmodule