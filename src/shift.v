
module shift(
        input [7:0] in,
        input [5:0] s,
        output [8:0] res
    );
    reg rule;
    reg [8:0] res_inner;
    assign res = res_inner;
    always @* begin
        rule =  in < 2 & s < 8 | in < 4 & s < 7 | 
                in < 8 & s < 6 | in < 16 & s < 6 | 
                in < 32 & s < 4 | in < 64 & s < 5 | 
                in < 128 & s < 2 | in < 256 & s < 1 ;  
        if (rule) begin
            res_inner = (in << s);
        end
        else begin
            res_inner = 9'h1FF;
        end
    end
endmodule