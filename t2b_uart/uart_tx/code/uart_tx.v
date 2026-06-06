// MazeSolver Bot: Task 2B - UART Transmitter
/*
Module UART Transmitter
Input:  clk_3125 - 3125 KHz clock
        parity_type - even(0)/odd(1) parity type
        tx_start - signal to start the communication.
        data    - 8-bit data line to transmit
Output: tx      - UART Transmission Line
        tx_done - message transmitted flag
Baudrate : 115200 bps
*/
module uart_tx(
    input clk_3125,
    input parity_type, tx_start,
    input [7:0] data,
    output reg tx, tx_done
);

// ---------- Parameters ----------
parameter CLK_FREQ = 3125000;
parameter BAUD     = 115200;
parameter DIVISOR  = 27;

// ---------- State Definition ----------
localparam IDLE   = 3'd0,
           START  = 3'd1,
           DATA   = 3'd2,
           PARITY = 3'd3,
           STOP   = 3'd4;

// ---------- Registers ----------
reg [2:0] state, next_state;
reg [7:0] data_buf, next_data_buf;
reg [3:0] bit_idx, next_bit_idx;
reg [5:0] clk_count, next_clk_count;
reg parity_bit, next_parity_bit;
reg tx_start_prev;

// ---------- Initialization ----------
initial begin
    tx = 1'b1;
    tx_done = 1'b0;
    state = IDLE;
    clk_count = 0;
    bit_idx = 0;
    tx_start_prev = 0;
end

// ---------- Sequential Logic (State Register) ----------
always @(posedge clk_3125) begin
    state <= next_state;
    clk_count <= next_clk_count;
    bit_idx <= next_bit_idx;
    data_buf <= next_data_buf;
    parity_bit <= next_parity_bit;
    tx_start_prev <= tx_start;
end

// ---------- Combinational Logic (Next State & Output Logic) ----------
always @(*) begin
    // Default values to avoid latches
    next_state = state;
    next_clk_count = clk_count;
    next_bit_idx = bit_idx;
    next_data_buf = data_buf;
    next_parity_bit = parity_bit;
    tx = 1'b1;
    tx_done = 1'b0;
    
    case (state)
        IDLE: begin
            tx = 1'b1;
            next_clk_count = 0;
            next_bit_idx = 0;
            
            if (tx_start && !tx_start_prev) begin
                next_data_buf = data;
                next_parity_bit = (parity_type) ? ~(^data) : (^data);
                next_state = START;
                next_clk_count = 0;
            end else begin
                next_state = state;
                next_data_buf = data_buf;
                next_parity_bit = parity_bit;
                next_clk_count = clk_count;
            end
        end
        
        START: begin
            tx = 1'b0;
            
            if (clk_count == DIVISOR-1) begin
                next_clk_count = 0;
                next_bit_idx = 7;
                next_state = DATA;
            end else begin
                next_clk_count = clk_count + 1;
                next_state = state;
                next_bit_idx = bit_idx;
            end
        end
        
        DATA: begin
            tx = data_buf[bit_idx];
            
            if (clk_count == DIVISOR-1) begin
                next_clk_count = 0;
                if (bit_idx == 0) begin
                    next_state = PARITY;
                    next_bit_idx = bit_idx;
                end else begin
                    next_bit_idx = bit_idx - 1;
                    next_state = state;
                end
            end else begin
                next_clk_count = clk_count + 1;
                next_state = state;
                next_bit_idx = bit_idx;
            end
        end
        
        PARITY: begin
            tx = parity_bit;
            
            if (clk_count == DIVISOR-1) begin
                next_clk_count = 0;
                next_state = STOP;
            end else begin
                next_clk_count = clk_count + 1;
                next_state = state;
            end
        end
        
        STOP: begin
            tx = 1'b1;
            
            if (clk_count == DIVISOR-1) begin
                tx_done = 1'b1;
                next_clk_count = 0;
                next_state = IDLE;
            end else begin
                next_clk_count = clk_count + 1;
                next_state = state;
            end
        end
        
        default: begin
            next_state = IDLE;
            next_clk_count = 0;
            next_bit_idx = 0;
            next_data_buf = data_buf;
            next_parity_bit = parity_bit;
        end
    endcase
end

endmodule