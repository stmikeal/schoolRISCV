
module adder(
    input [9:0] a,
    input [7:0] b,
    input sub,
    output [9:0] res
    );
    reg [9:0] a_in;
    reg [9:0] b_in;
    reg [9:0] res_in;
    assign res = res_in;
    always @* begin
        a_in = a;
        b_in = {2'b0, b};
        if (sub)
            res_in = a_in - b_in;
        else 
            res_in = a_in + b_in;
    end
endmodule