module uart_rx(
    input  clk_3125,
    input  rx,
    output reg [7:0] rx_msg,
    output reg rx_parity,
    output reg rx_complete
    );

initial begin
    rx_msg = 8'b0;
    rx_parity = 1'b0;
    rx_complete = 1'b0;
end
//////////////////DO NOT MAKE ANY CHANGES ABOVE THIS LINE//////////////////

localparam IDLE = 3'b000,
           START = 3'b001,
           DATA = 3'b010,
           PARITY = 3'b011,
           STOP = 3'b100;
           
localparam integer BAUD_COUNT = 27;

reg [2:0] state;
reg [4:0] bit_counter;
reg [2:0] data_bit_index;
reg [7:0] rx_msgs;
reg rx_paritys;

reg rx_sync1, rx_sync2;

initial begin
    rx_msgs = 0;
	 rx_paritys = 0;
	 bit_counter = -1;
    state = IDLE;
    data_bit_index = 0;
	 rx_sync1 = 1'b1;
    rx_sync2 = 1'b1;
end

// Double-buffer the rx signal to mitigate metastability
always @(posedge clk_3125) begin
    rx_sync1 <= rx;
    rx_sync2 <= rx_sync1;
end

// State and data handling
always @(posedge clk_3125) begin
    case (state)
        IDLE: begin
            rx_complete = 0;
            if (!rx_sync2) begin
                state = START;
            end
        end

        START: begin
		      bit_counter = bit_counter + 1;
            if (bit_counter == BAUD_COUNT-3) begin
                state = DATA;
                bit_counter = 0;
                data_bit_index = 0;
            end 
 
        end

        DATA: begin
                rx_msgs[7-data_bit_index] = rx_sync2;
				    bit_counter = bit_counter + 1;	 // Sample at the end of the bit period
					 
				if (bit_counter == BAUD_COUNT) begin	 
                bit_counter = 0;
					 
                if (data_bit_index == 7) begin
                    state = PARITY;
                end else begin
                    data_bit_index = data_bit_index + 1;
                end
            end 
        end

        PARITY: begin
            rx_paritys=rx_sync2;
				bit_counter = bit_counter + 1;
				if(bit_counter == BAUD_COUNT) begin
                state = STOP;
                bit_counter = 0;
					 end
        end

        STOP: begin
		      bit_counter = bit_counter + 1;
            if (bit_counter == BAUD_COUNT) begin  
				    rx_parity = rx_paritys;
				    rx_msg=(~(^rx_msgs)==rx_parity)?8'h3F:rx_msgs;
                rx_complete = 1;
                state = IDLE;
                bit_counter = 0;
            end 
        end

        default: state = IDLE;
    endcase
end


//////////////////DO NOT MAKE ANY CHANGES BELOW THIS LINE//////////////////

endmodule
