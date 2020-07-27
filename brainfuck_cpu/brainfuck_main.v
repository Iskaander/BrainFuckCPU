module brainfuck_main (
        input clk,
        input rst,

        output [3:0] led,
        output uart_out,
        output [6:0] Segments,
        output [3:0] Cathodes
        );
        
parameter c_CLKS_PER_BIT = 50; //5208 for 9600 baudrate 50MHz clk
                                //434 for 115200 at 50 MHz
                                //200 for 250000
                                //50 for 1000000
wire   clk_slow; 
reg    clk_slow_reg = 0;
assign clk_slow = clk_slow_reg;
//assign clk_slow = clk_pll;
wire clk_pll, clk_pll1;

PLL PLL_INST( //200 MHz
	clk,
	clk_pll
    );

PLL1 PLL_INST1(//100 MHz
	clk,
	clk_pll1
    );


//data memory initialization
wire [9:0] address_sig;
wire [7:0]  q_sig, data_sig;
wire        wren_sig, rden_sig;

ram RAM_INST (
    .address (address_sig),
    .clock   (clk_slow),
    .data    (data_sig),
    .rden    (rden_sig),
    .wren    (wren_sig),
    .q       (q_sig)
    );

//program memory initialization
wire [9:0] prog_address_sig;
wire [3:0]  prog_q_sig, prog_data_sig;
wire        prog_wren_sig, prog_rden_sig;

prog_ram PROG_RAM_INST (
    .address (prog_address_sig),
    .clock   (clk_slow),
    .data    (prog_data_sig),
    .rden    (prog_rden_sig),
    .wren    (prog_wren_sig),
    .q       (prog_q_sig)
    );

//uart module initialization
wire       w_Tx_Done, r_Tx_DV, w_Tx_Active;
wire [7:0] r_Tx_Byte;
reg  [7:0] r_Tx_Byte_reg = 0;
reg        r_Tx_DV_reg = 0;
assign     r_Tx_Byte = r_Tx_Byte_reg;
assign     r_Tx_DV = r_Tx_DV_reg;

uart_tx #(.CLKS_PER_BIT(c_CLKS_PER_BIT)) UART_TX_INST (
    .i_Clock     (clk),
    .i_Tx_DV     (r_Tx_DV),
    .i_Tx_Byte   (r_Tx_Byte),
    .o_Tx_Active (w_Tx_Active),
    .o_Tx_Serial (uart_out),
    .o_Tx_Done   (w_Tx_Done)
    );
    
reg flag_output_active_reg = 0;
wire flag_output_active, flag_output_begin;
assign flag_output_active = flag_output_active_reg;

brainfuck_cpu BRAINFUCK_INST(

        .clk (clk_slow),
        .rst (rst),
        
        //imem
        .prog_q_sig (prog_q_sig),
        .prog_data_sig (prog_data_sig),
        .prog_address_sig (prog_address_sig),
        .prog_wren_sig (prog_wren_sig),
        .prog_rden_sig (prog_rden_sig),
        
        //dmem
        .q_sig (q_sig),
        .data_sig (data_sig),
        .address_sig (address_sig),
        .wren_sig (wren_sig),
        .rden_sig (rden_sig),
        
        //uart connect
        .flag_output_active (flag_output_active),
        .flag_output_begin (flag_output_begin)
        );
        
wire [3:0] Binary_Num_1, Binary_Num_2, Binary_Num_3, Binary_Num_4;
reg [3:0] Binary_Num_reg_1 = 0, Binary_Num_reg_2 = 0, Binary_Num_reg_3 = 0, Binary_Num_reg_4 = 0;

assign Binary_Num_1 = Binary_Num_reg_1;
assign Binary_Num_2 = Binary_Num_reg_2;
assign Binary_Num_3 = Binary_Num_reg_3;
assign Binary_Num_4 = Binary_Num_reg_4;

seven_segment_controller SEVEN_SEG_INST (
    .i_Clk (clk),
    .i_Binary_Num_1 (Binary_Num_1),
    .i_Binary_Num_2 (Binary_Num_2),
    .i_Binary_Num_3 (Binary_Num_3),
    .i_Binary_Num_4 (Binary_Num_4),
    .o_Segment (Segments),
    .o_Cathode (Cathodes)
   );
    
    
reg [31:0] clk_counter = 0;

always @ (posedge clk) begin
    clk_counter <= (~rst) | (clk_counter > 20) ? 0 : clk_counter + 1;
    clk_slow_reg <= ~rst           ? 1'b1 : 
                clk_counter == 20 ? ~clk_slow_reg ://200000
                clk_slow_reg;
end

reg [3:0] led_reg = 0;
assign led = led_reg;


always @ (posedge clk_slow) begin

    led_reg <= ~prog_address_sig[3:0];
    Binary_Num_reg_1 <= address_sig[7:4]; //left display
    Binary_Num_reg_2 <= address_sig[3:0];
    Binary_Num_reg_3 <= q_sig[7:4];
    Binary_Num_reg_4 <= q_sig[3:0]; //right display
    
end

reg flag_output_edge_detect = 0;

always @(posedge clk) begin

    flag_output_edge_detect <= flag_output_begin;
    
    if (flag_output_begin & (~flag_output_edge_detect) & (flag_output_active_reg == 0)) begin
        flag_output_active_reg <= 1;
        r_Tx_DV_reg <= 1;
        r_Tx_Byte_reg <= q_sig;
    end
    else if(flag_output_active_reg == 1) begin
        r_Tx_DV_reg <= 0;
        if((w_Tx_Done == 1)) begin
            flag_output_active_reg <= 0;
        end
    end
    
end

endmodule
