//Author Daniel Duggan

module FCS_serial;

    timeunit 1ns;
    timeprecision 1fs; //time precision specifies how delay values are rounded relative to timeunit

    logic sysclk_p;
    logic sysclk_n;
    logic rst; //reset logic
    logic start_of_frame_top, end_of_frame_top, data_in, fcs_error_top;

    
    // clock generation -------------------------------------------------------------------   
    logic sys_clk = 0;
    always #2ns sys_clk = ~sys_clk; // Toggle every 2 ns (1 cycle = 4 ns)
    assign sysclk_p = sys_clk;
    assign sysclk_n = ~sys_clk;
    //--------------------------------------------------------------------------------------

    // Data in (Ethernet Frame) ---------------------------------------------------------------
    logic [367:0] ethernet_frame = 368'h00_10_A4_7B_EA_80_00_12_34_56_78_90_08_00_45_00_00_2E_B3_FE_00_00_80_11_05_40_C0_A8_00_2C_C0_A8_00_04_04_00_04_00_00_1A_2D_E8_00_01_02_03_04_05_06_07_08_09_0A_0B_0C_0D_0E_0F_10_11;
    logic [31:0] fcs_correct = 32'hE6C53DB2;
    logic [31:0] fcs_incorrect = 32'hDEADBEEF; 
    //--------------------------------------------------------------------------------------

    // Task to Send Frame ------------------------------------------------------------------
    task send_ethernet_frame(input logic [367:0] frame_data, input logic [31:0] fcs_bits);
    integer i;

    // Indicate start of frame
    start_of_frame_top = 1;
    data_in = frame_data[367];  // First data bit
    #4ns;
    start_of_frame_top = 0;

    // Send Data Bits (367 remaining)
    for (i = 1; i < 368; i++) begin
        data_in = frame_data[367 - i];
        #4ns;
    end

    // Indicate start of FCS
    end_of_frame_top = 1;
    data_in = fcs_bits[31];  // First FCS bit
    #4ns;
    end_of_frame_top = 0;

    // Send Remaining FCS (31 bits)
    for (i = 1; i < 32; i++) begin
        data_in = fcs_bits[31 - i];
        #4ns;
    end
endtask

    // DUT ----------------------------------------------------------------------------------
    Sys_top Sys_top_DUT(
        .SYS_CLOCK_P (sysclk_p), 
        .SYS_CLOCK_N (sysclk_n),
        .RST (rst),
        .START_OF_FRAME_top (start_of_frame_top), 
        .END_OF_FRAME_top (end_of_frame_top),
        .DATA_IN_top (data_in),
        .FCS_ERROR_top (fcs_error_top)    
        );    
    //--------------------------------------------------------------------------------------  

    initial 
    begin:drive_reset
        rst = 1'b1; 
        rst = 1'b0; //reset is active low

        #10ns //wait tell ns

        rst = 1'b1; //not in reset now        
    end
    

