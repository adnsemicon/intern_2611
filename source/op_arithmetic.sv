module op_arithmetic;
logic [1:0] a,b;
logic [1:0] add,sub,mul,div,mod,exp;

assign a = 2'b10;
assign b = 2'b11;

assign add = a + b;
assign sub = a - b;
assign mul = a * b;
assign div = a / b;
assign mod = a % b;
assign exp = a ** b;


initial begin
#1
$display("add : %b", add);
$display("sub : %b", sub);
$display("mul : %b", mul);
$display("div : %b", div);
$display("mod : %b", mod);
$display("exp : %b", exp);
end

endmodule
