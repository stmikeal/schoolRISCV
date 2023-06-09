
module mult(
    input [7:0] a,
    input [7:0] b,
    input clk, 
    input rst,
    input start,
    
    output [13:0] res,
    output busy
    );
    reg [13:0] result;
    reg [3:0] state;
    reg [7:0] a_in;
    reg [7:0] b_in;
    reg busy_inner;
    assign busy = busy_inner;
    assign res = result;
    always @(posedge clk, posedge rst, posedge start) begin
        if (rst) begin
            a_in <= 0;
            b_in <= 0;
            state <= 0;
            result <= 0;
            busy_inner <= 0;
        end
        else if (start) begin
            a_in <= a;
            b_in <= b;
            state <= 0;
            result <= 0;
            busy_inner <= 0;
        end
        else begin
            if (state == 8)
                busy_inner <= 1;
            else begin 
                result <= result + b[state] * (a << state);
                state <= state + 1;
            end
        end
    end
endmodule