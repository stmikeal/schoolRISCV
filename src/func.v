`timescale 1ns / 1ps

module func(
    input clk,
    input rst,
    input start,
    input [7:0] a,
    input [7:0] b,
    
    output [9:0] res,
    output busy
    );
    
    localparam START    = 3'h0;
    localparam MUL2     = 3'h1;
    localparam CNTB     = 3'h2;
    localparam LOOP     = 3'h3;
    localparam CNT3A    = 3'h4;
    localparam RESULT   = 3'h5;
    
    reg [9:0] X;
    reg [8:0] B;
    reg [3:0] Y;
    reg [5:0] S;
    reg [2:0] state;
    reg busy_inner;
    reg [9:0] res_inner;
    reg [2:0] load;
    assign busy = busy_inner;
    assign res = res_inner;
    
    reg [7:0] a_mul_1;
    reg [7:0] b_mul_1;

    wire [13:0] res_mul_1;
    wire busy_mul_1;
    reg rst_mul_1;
    
    mult mult1(
        .a(a_mul_1),
        .b(b_mul_1),
        .clk(clk), 
        .rst(rst),
        .start(rst_mul_1),
        .res(res_mul_1),
        .busy(busy_mul_1)
    );
    
    reg [7:0] a_mul_2;
    reg [7:0] b_mul_2;
    wire [13:0] res_mul_2;
    wire busy_mul_2;
    reg rst_mul_2;
    
    mult mult2(
        .a(a_mul_2),
        .b(b_mul_2),
        .clk(clk), 
        .rst(rst),
        .start(rst_mul_2),
        .res(res_mul_2),
        .busy(busy_mul_2)
    );
    
    reg [9:0] a_adder;
    reg [7:0] b_adder;
    reg sub_adder;
    wire [9:0] res_adder;
    
    adder adder(
        .a(a_adder),
        .b(b_adder),
        .sub(sub_adder),
        .res(res_adder)
    );
    
    wire [8:0] res_shift;
    
    shift shift(
        .in(res_adder),
        .s(S),
        .res(res_shift)
    );
    
    always @(posedge clk, posedge rst, posedge start) begin
        if (rst) begin
            state <= 0;
            busy_inner <= 0;
            X <= 0;
            B <= 0;
            Y <= 0;
            S <= 0;
            res_inner <= 0;
            load <= 0;
        end 
        if (start) begin
            state <= START;
            busy_inner <= 0;
            res_inner <= 0;
            load <= 0;
        end
        else begin
            case (state)
                START: begin 
                    X <= b;
                    B <= 0;
                    Y <= 0;
                    S <= 6;
                    state <= MUL2;
                    load <= 0;
                    busy_inner <= 0;
                    res_inner <= 0;
                end
                MUL2: begin 
                    if (!load) begin
                        a_mul_1 <= Y;
                        b_mul_1 <= 2;
                        load <= 1;
                        rst_mul_1 <= 1;
                    end
                    else if (load == 1) begin
                        rst_mul_1 <= 0;
                        if (busy_mul_1) begin
                            load <= 2;
                            Y <= res_mul_1;
                        end
                    end else begin
                        load <= 0;
                        if (S < 31) begin
                            state <= CNTB;
                        end else begin
                            state <= CNT3A;
                        end
                    end
                end
                CNTB: begin 
                    if (!load) begin
                        sub_adder <= 0;
                        a_adder <= Y;
                        b_adder <= 1;
                        a_mul_1 <= 3;
                        b_mul_1 <= Y;
                        load <= 1;
                        rst_mul_1 <= 1;
                    end
                    else begin
                        rst_mul_1 <= 0;
                        if (busy_mul_1) begin
                            if (load == 1) begin
                                a_mul_2 <= res_mul_1;
                                b_mul_2 <= res_adder;
                                rst_mul_2 <= 1;
                                load <= 2;
                            end 
                            else if (load == 2) begin
                                rst_mul_2 <= 0;
                                if (busy_mul_2) begin
                                    sub_adder <= 0;
                                    a_adder <= res_mul_2;
                                    b_adder <= 1;
                                    load <= 3;
                                end
                            end
                            else if (load == 3) begin
                                    B <= res_shift;
                                    //$display("B: %d", B);
                                    load <= 0;
                                    a_adder <= S;
                                    sub_adder <= 1;
                                    b_adder <= 8'd3;
                                    load <= 4;
                            end
                            else begin
                                load <= 0;
                                S <= res_adder;
                                if (X >= B) begin
                                    state <= LOOP;
                                end
                                else begin
                                    state <= MUL2;
                                end
                            end
                        end
                    end
                end
                LOOP: begin 
                    if (!load) begin
                        a_adder <= Y;
                        b_adder <= 1;
                        sub_adder <= 0;
                        load <= 1;
                    end 
                    else if (load == 1) begin
                        Y <= res_adder;
                        a_adder <= X;
                        sub_adder <= 1;
                        b_adder <= B;
                        load <= 2;
                    end
                    else if (load == 2) begin
                        X <= res_adder;
                        state <= MUL2;
                        load <= 0;
                    end
                end
                CNT3A: begin 
                    if (!load) begin
                        X <= a;
                        a_mul_1 <= a;
                        b_mul_1 <= 3;
                        rst_mul_1 <= 1;
                        load <= 1;
                    end
                    else begin
                        rst_mul_1 <= 0;
                        if (busy_mul_1) begin
                            X <= res_mul_1;
                            load <= 0;
                            state <= RESULT;
                        end
                    end
                end
                RESULT: begin 
                    if (!load) begin
                        $display("X: %d", X);
                        $display("Y: %d", Y);
                        $display("a: %d", a);
                        $display("b: %d", b);
                        a_adder <= X;
                        sub_adder <= 0;
                        b_adder <= Y;
                        load <= 1;
                    end
                    else begin 
                        $display("res: %d", res_adder);
                        res_inner <= res_adder;
                        load <= 0;
                        busy_inner <= 1;
                        load <= 0;
                        state <= RESULT + 1;
                    end
                end
            endcase
        end 
    end
endmodule
