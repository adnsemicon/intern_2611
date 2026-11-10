module task_udt;
typedef struct packed {
         logic [7:0] addr;
         logic [31:0] data;
         logic  wr_en;
 }bus_pkt_t;
 
 //enum 
 typedef enum logic [1:0]{
          IDLE =2'b00,
          READ =2'b01,
          WRITE =2'b10,
          ERROR =2'b11
  }state_t;
  
  bus_pkt_t pkt;
  state_t current_state;
  
  initial begin
          current_state = WRITE;
          pkt ='{addr: 8'hA5, data: 32'hdeadbeef, wr_en:1'b1};
          $display("User defined Types Test");
          // Test 
          $display("current State: %s(Value: %0b)",current_state.name(),current_state);
          $display("Next State : %s", current_state.next().name());
          $display("Total States: %0d", current_state.num());
          
          $display("Packet -> Addr: %h, Data:%h, WE: %b", pkt.addr,pkt.data,pkt.wr_en);
          $display("Packed Struct: %h",pkt);
  end     
  
  endmodule
