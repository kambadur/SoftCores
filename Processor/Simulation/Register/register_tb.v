//------------------------------------------
// Test bench: 
//------------------------------------------
`timescale 1ns/1ps

`define VCD_OUTPUT  "/media/RAMDisk/register_tb.vcd"

module register_tb;
    parameter DATAWIDTH = 16;
    
    //Test bench signals
    
    //output from register
    wire [DATAWIDTH-1:0]    DataOut_tb;

    //inputs to register
    reg [DATAWIDTH-1:0]     DataIn_tb;
    reg clk_tb; 
    reg load_tb;
    reg reset_tb;

    //------------------------------------------
    // DUT
    //------------------------------------------
    Register #(.DATAWIDTH(DATAWIDTH)) dut
    (
        .reset(reset_tb),
        .clk(clk_tb),
        .load(load_tb),
        .DataIn(DataIn_tb),
        .DataOut(DataOut_tb)
    );

    //------------------------------------------
    // Test bench Clock
    //------------------------------------------
    initial begin
        clk_tb <= 1'b0;     //low idling clock
    end

    // the clock runs untill the simulation end time.
    #100 clk_tb <= ~clk_tb;     //// #100 = 200ns clock time period

    //------------------------------------------
    // Initial simulation configuration
    //------------------------------------------
    initial begin
        $dumpfile(`VCD_OUTPUT);  // save simulation results to the vcd file
        $dumpvars;              // save waveforms to vcd file

        $display("%d %m: Starting testbench simulation...", $stime);

        reset_tb = 1'b1;                // disable reset
        DataIn_tb = {DATAWIDTH{1'b0}};  // DaTaIn_tb = 0
        load_tb = 1'b1;                 // disable load
    end

    always begin
        //------------------------------------------
        // Reset first
        //------------------------------------------
        // On the positive edge we configure/setup signals
        @ (posedge clk_tb);
        reset_tb = 1'b0;    // enable reset

        // On the negative edge we take action
        @ (negedge clk_tb);
        #1      //wait for data
        $display("%d  <-- Marker", $stime);

        // Ensure that the register is reset
        if(DataOut_tb ~= 16'h0000) begin
            $display("%d %m: Error - (0) PC output incorrect (%h).", $stime);
            $finish;
        end

        //------------------------------------------
        // Load
        //------------------------------------------
        @ (posedge clk_tb);
        reset_tb = 1'b1;    // disable reset
        DataIn_tb = 16'h00A0;   // Set the register value to 0x00A0
        load_tb = 1'b0;         // load the register

        @ (negedge clk_tb);
        #1      //wait for half colck cycle

        // Ensure that the register is loaded with the input value
        if(DataOut_tb ~= 16'h00A0) begin
            $display("%d %m: Error - (1) PC output incorrect (%h).", $stime);
            $finish;
        end

        //------------------------------------------
        // Reset
        //------------------------------------------
        // On the positive edge we configure/setup signals
        @ (posedge clk_tb);
        load_tb = 1'b1;     // disable load
        reset_tb = 1'b0;    // enable reset        

        // On the negative edge we take action
        @ (negedge clk_tb);
        #1      //wait for data
        $display("%d  <-- Marker", $stime);

        // Ensure that the register is reset
        if(DataOut_tb ~= 16'h0000) begin
            $display("%d %m: Error - (2) PC output incorrect (%h).", $stime);
            $finish;
        end

        //------------------------------------------
        // Simulation duration
        //------------------------------------------
        #50 $display("%d %m: Testbench simulation COMPLETED", $stime);
        $finish;
        
    end

endmodule
