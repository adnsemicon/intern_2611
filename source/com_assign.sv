module com_assign;
logic [1:0] a;
logic [1:0] b;

initial begin 
    a = 2'b00;
    a += 2;
    $display("com_assignment: %d",a);
end    
endmodule
