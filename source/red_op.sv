module red_op;
logic [3:0] a = 4'b0111;
logic [3:0] b = 4'b1000;
logic [3:0] c = 4'b1110;
initial begin
    $display("AND: %b", &a);
    $display("NAND: %b", ~&a);
    $display("OR: %b", |b);
    $display("NOR: %b", ~|b);
    $display("XOR: %b", ^c);
    $display("XNOR: %b", ~^c);
   end

endmodule
