typedef enum logic [1:0] {
  IDLE  = 2'b00,
  READ  = 2'b01,
  WRITE = 2'b10,
  ERROR = 2'b11
} state_t;

state_t current_state, next_state;
