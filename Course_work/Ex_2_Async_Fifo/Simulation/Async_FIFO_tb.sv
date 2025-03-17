// Testbench for Async_FIFO
module Async_FIFO_tb;

// Signals
logic RST_top;
logic WCLK_top;
logic RCLK_top;
logic [0:0] WRITE_ENABLE_TOP;
logic [0:0] READ_ENABLE_TOP;
logic FULL_top;
logic EMPTY_top;
logic [7:0] WRITE_DATA_IN_top;
logic [7:0] WRITE_DATA_OUT_top;

// Clock periods
parameter CLK_PERIOD_WR = 10; // Write clock period (e.g., 100MHz)
parameter CLK_PERIOD_RD = 12; // Read clock period (e.g., 66.6MHz)

// FIFO instance
Async_FIFO uut (
    .RST_top(RST_top),
    .WCLK_top(WCLK_top),
    .RCLK_top(RCLK_top),
    .WRITE_ENABLE_TOP(WRITE_ENABLE_TOP),
    .READ_ENABLE_TOP(READ_ENABLE_TOP),
    .FULL_top(FULL_top),
    .EMPTY_top(EMPTY_top),
    .WRITE_DATA_IN_top(WRITE_DATA_IN_top),
    .WRITE_DATA_OUT_top(WRITE_DATA_OUT_top)
);

// Clock Generation
always #(CLK_PERIOD_WR/2) WCLK_top = ~WCLK_top;
always #(CLK_PERIOD_RD/2) RCLK_top = ~RCLK_top;

// Predefined data array
logic [7:0] predefined_data [0:18] = '{
    8'h11, 8'h22, 8'h33, 8'h44, 8'h55, 8'h66, 8'h77, 8'h88,
    8'h99, 8'haa, 8'hbb, 8'hcc, 8'hdd, 8'hee, 8'hff, 8'h01,
    8'h03, 8'h05, 8'h06
};

// Queue for verification
logic [7:0] fifo_queue [$];

initial begin
    // Initialize
    WCLK_top = 0;
    RCLK_top = 0;
    RST_top = 0; //reset active low
    WRITE_ENABLE_TOP = 0;
    READ_ENABLE_TOP = 0;
    //WRITE_DATA_IN_top = 8'h00;
    
    // Apply Reset
    #(5*CLK_PERIOD_WR);
    RST_top = 1;
    #(5*CLK_PERIOD_WR);

    // Write to FIFO
    for (int i = 0; i < 19; i++) begin
        @(posedge WCLK_top);
        if (!FULL_top) begin
            WRITE_ENABLE_TOP = 1;
            //#5;
            WRITE_DATA_IN_top = predefined_data[i];
            fifo_queue.push_back(predefined_data[i]); // Store for verification
            $display("Written: %h", predefined_data[i]);
        end else begin
            WRITE_ENABLE_TOP = 0;
        end
    end
    WRITE_ENABLE_TOP = 0;

    // Small delay before reading
    #(5*CLK_PERIOD_WR);

    // Read from FIFO
    for (int i = 0; i < 20; i++) begin
        @(posedge RCLK_top);
        if (!EMPTY_top) begin
            READ_ENABLE_TOP = 1;
            //#7;
            //@(posedge RCLK_top); // Wait for data to be valid
            if (fifo_queue.size() > 0) begin
                automatic logic [7:0] expected_value = fifo_queue.pop_front();
                $display("Read Data: %h, Expected: %h, Match: %s", 
                         WRITE_DATA_OUT_top, expected_value, 
                         (WRITE_DATA_OUT_top == expected_value) ? "YES" : "NO");
            end
        end else begin
            READ_ENABLE_TOP = 0;
        end
    end
    READ_ENABLE_TOP = 0;

    // End Simulation
    #(20*CLK_PERIOD_WR);
    $stop;
end

endmodule