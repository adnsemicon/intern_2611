module user_defined_types;
    // 1. ENUM: Names for numbers
    typedef enum logic [1:0] {RED, YELLOW, GREEN} light_t;

    // 2. STRUCT: Group variables into one box
    typedef struct packed {
        light_t     color;  // 2 bits
        logic [1:0] time_s; // 2 bits
    } signal_t;             // Total = 4 bits

    // 3. UNION: Two ways to view the SAME 4 bits
    typedef union packed {
        signal_t    info;   // View as 'color' and 'time_s'
        logic [3:0] raw;    // View as 4 raw bits
    } data_u;

    data_u traffic; // Create our variable

    initial begin
        // Set values using easy names
        traffic.info.color  = GREEN;
        traffic.info.time_s = 2'd3;

        // Print both views of the exact same data!
        $display("Color = %s, Time = %0d", traffic.info.color.name(), traffic.info.time_s);
        $display("Same data as 4 raw bits = %b", traffic.raw);
    end

endmodule

