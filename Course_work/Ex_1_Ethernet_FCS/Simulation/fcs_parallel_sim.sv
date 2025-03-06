//Author Daniel Duggan

module FCS_para;

  timeunit 1ns;
  timeprecision 1ps; //time precision specifies how delay values are rounded relative to timeunit

  logic sysclk_p;
  logic sysclk_n;
  logic rst; //reset logic
  logic start_of_frame_top, end_of_frame_top, fcs_error_top;
  logic [7:0] data_in;
  parameter clk_period = 4ns; // Since sys_clock every 2ns

  // clock generation -------------------------------------------------------------------
  logic sys_clk = 0;
  always #2ns sys_clk = ~sys_clk; // Toggle every 2 ns (1 cycle = 4 ns)
  assign sysclk_p = sys_clk;
  assign sysclk_n = ~sys_clk;
  //--------------------------------------------------------------------------------------

  // Data in (Ethernet Frame) ---------------------------------------------------------------
  logic [511:0] ethernet_frame = {
          128'h00_10_A4_7B_EA_80_00_12_34_56_78_90_08_00_45_00,
          128'h00_2E_B3_FE_00_00_80_11_05_40_C0_A8_00_2C_C0_A8,
          128'h00_04_04_00_04_00_00_1A_2D_E8_00_01_02_03_04_05,
          128'h06_07_08_09_0A_0B_0C_0D_0E_0F_10_11_E6_C5_3D_B2
        };

  logic [511:0] ethernet_frame_incorrect = {
          128'h00_10_A4_7B_EA_80_00_12_34_56_78_90_08_00_45_00,
          128'h00_2E_B3_FE_00_00_80_11_05_40_C0_A8_00_2C_C0_A8,
          128'h00_04_04_00_04_00_00_1A_2D_E8_00_01_02_03_04_05,
          128'h06_07_08_09_0A_0B_0C_0D_0E_0F_10_11_FF_FF_FF_FF
        };

  //--------------------------------------------------------------------------------------

  // DUT ----------------------------------------------------------------------------------
  Sys_Top_para Sys_Top_para_DUT(
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
  begin
    // Initialize signals
    start_of_frame_top = 0;
    end_of_frame_top   = 0;
    data_in           = 0;
    rst = 1'b0;

    // Apply Reset
    repeat (5) @(posedge sys_clk);
    rst = 1'b1;
    repeat (5) @(posedge sys_clk);

    // Begin Transmission

    @(posedge sys_clk);
    start_of_frame_top = 1'b1;  // Assert start_of_frame_top one cycle before the first byte

    for (int i = ($bits(ethernet_frame)/8) - 1; i >= 0; i--)
    begin
      @(posedge sys_clk);
      start_of_frame_top = 1'b0;  // Deassert start_of_frame_top after the first cycle

      data_in = ethernet_frame[((i+1)*8 - 1) -: 8];  // Send data in bytes

      if (i == 3) // Indicate the last 3 bytes
        end_of_frame_top = 1'b1;
      else
        end_of_frame_top = 1'b0;
    end

    @(posedge sys_clk);
    end_of_frame_top = 1'b0;  // Deassert end_of_frame_top after the last byte

    repeat (3) @(posedge sys_clk);
    $finish;
  end
endmodule
