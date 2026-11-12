module inc_dec;
logic [3:0] a,b;
logic [3:0] c;

initial begin
c = 4'b0101;
a = c++;
b = c--;

	#1
	$display("increment: %d", a);
	$display("decrement: %d", b);
	$display("number: %d", c);
end

endmodule
