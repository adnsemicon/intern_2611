module dynamic_array_tb;
// 1. Dynamic Array: new[], size(), delete() 
   int dyn_arr[];
   initial begin
        dyn_arr = new[5];           // Allocate 5 elements
        dyn_arr = '{10, 20, 30, 40, 50};
        $display("Dyn Size: %0d", dyn_arr.size()); // 5
        dyn_arr = new[10](dyn_arr); // Resize to 10 elements, preserving old contents
        dyn_arr.delete();           // Deallocate memory
    end

// 2. Associative Array: Sparse Key-Value Mapping
    int sparse_mem [logic [63:0]]; // Key: 64-bit address, Value: 32-bit int
    initial begin
        sparse_mem[64'hFFFF_0000] = 32'hDEADBEEF;
        sparse_mem[64'h0000_1000] = 32'hCAFEFEED;
        if (sparse_mem.exists(64'hFFFF_0000))
            $display("Address exists! Data: 0x%08h", sparse_mem[64'hFFFF_0000]);
    end

// 3. Queue: Double-Ended FIFO Buffer
     int pkt_queue [$]; // Bounded queue: int bounded_q [$ : 16];
     initial begin
         pkt_queue.push_back(100);   // Append to tail
         pkt_queue.push_back(200);
         pkt_queue.push_front(50);   // Insert at head
         $display("Queue: %p", pkt_queue);          // '{50, 100, 200}
         $display("Popped: %0d", pkt_queue.pop_front()); // 50
         $display("Remaining: %0d", pkt_queue.size());   // 2
    end
endmodule
