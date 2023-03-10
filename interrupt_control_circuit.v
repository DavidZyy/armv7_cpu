module interrupt_control_circuit(
    input clk,
    input rst,
    input CPSR_7,
    input EX_irq,
    input INTA_irq,

    output INT_irq
    //output [1:0]PC_s
    );
    
    request request(
        .CPSR_7(CPSR_7),
        .EX_irq(EX_irq),
        .INTA_irq(INTA_irq),

        .INT_irq(INT_irq)
    );
    
    /*decode decode_mod(
        .clk(clk),
        .INT_irq(INT_irq),

        .INTA_irq(INTA_irq)
        //.PC_s(PC_s)
    );*/   
endmodule


module d_flip_flop(//D触发器模块？
    input d,
    input clk,
    input clr,
    output reg q
    );
        
    always@ (posedge clk or posedge clr) begin
        if(clr) begin
            q <= 0; 
        end
        else begin
            q <= d;
        end
    end
    
endmodule

module request(//中断请求模块？
    input CPSR_7,
    input INTA_irq,
    input EX_irq,
    
    output INT_irq,
    output Q
    );
    
    //wire Q;
    
    d_flip_flop D1(//第一个触发器
        .d(1'b1),//高电平默认为1
        .clk(~CPSR_7),//看图，输入有个小圆圈，取反
        .clr(INTA_irq),//如果传入的值已经为1，那么输出0，INTA_irq为1说明已经处在中断之中

        .q(Q)
    );
    
    d_flip_flop D2(
        .d(Q),
        .clk(EX_irq),
        .clr(INTA_irq),

        .q(INT_irq)
    );
endmodule

/*module decode(
    input clk,
    input INT_irq,
    
    output reg INTA_irq,
    output reg [1:0]PC_s,
    output reg Write_PC
    );
    always@(posedge clk) begin
        if(INT_irq) begin
            INTA_irq <= 1;
            PC_s <= 2'b11;
            Write_PC <= 1;
        end
        else begin
            INTA_irq <= 0;
            PC_s <= 2'b00;
            Write_PC <= 0;
        end
    end
endmodule*/