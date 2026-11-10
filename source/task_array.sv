module task_array;
int fa[5]; //fixed-length
int da[]; //dynamic
int assa[string]; //associative
int q[$];//queue

initial begin 
	$display("Fixed array");
	fa = '{10,20,30,40,50};
	$display("size:%0d, element[2]:%0d", $size(fa), fa[2]);

	$display("Dynamic");
	da = new[5];
	foreach (da[i]) da[i] = i*5; 
	$display("size: %0d", da.size());

	da = new[6](da);
	da[5] = 100;

	da.shuffle();
	$display("after shuffle:");
	foreach (da[i]) $display("da[%0d]=%0d", i, da[i]);

	$display("associative array");
	assa["Core_a"]= 100;
	assa["Core_b"]= 200;
	assa["ALU"]= 50;

	if (assa.exists("ALU")) begin 
		$display("ALU exists, Value : %0d", assa["ALU"]); end
		assa.delete("Core_a");
		$display("after deletion: %0d", assa.num());

	$display("QUEUE");
	q.push_back(7);
	q.push_back(3);
	q.push_front(9);

	$display("pop at the back: %0d", q.pop_back());
	$display("size after pop: %0d", q.size());

	q.sort();
	$display("Queue after sort : ");
	foreach (q[i]) $display("queue[%0d]=%0d",i, q[i]);

end

endmodule



