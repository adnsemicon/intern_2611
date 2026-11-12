module loop;
int i,j,k;
int sum;
int arr[5]='{10,20,30,40,50};
 initial begin
    for (i=0; i<5;i++) begin
        $display("for i=%d",i);
    end
    
    j=1;
    while(j<=5) begin
        $display("while:%d",j);
        j++;
    end 

    k=10;
    do begin
        $display("do_while=%d",k);
    end 
    while(k<5);

    repeat(5) begin
        $display("Repeat: Hello");
    end
    
    foreach(arr[i]) begin
        $display("arr[%d] = %d" , i , arr[i]);
    end
     
    $display("break");
    for ( int a = 0; a<10; a++) begin 
       $display("%d", a);
        if(i==5)
            break;

    end    

    $display("continue");
    for (int b= 0;b<6;b++) begin
        if(b == 3)
            continue;

        $display("%d",b);

    end



 end

endmodule
