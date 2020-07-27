module seven_segment_controller(
    input i_Clk, // 100 Mhz clock source on Basys 3 FPGA
    input reset, // reset
    input  [3:0]     i_Binary_Num_1,
    input  [3:0]     i_Binary_Num_2,
    input  [3:0]     i_Binary_Num_3,
    input  [3:0]     i_Binary_Num_4,
    output reg [3:0] o_Cathode, // anode signals of the 7-segment LED display
    output reg [6:0] o_Segment// cathode patterns of the 7-segment LED display
    );
    
    reg [3:0] LED_BCD;
    reg [19:0] refresh_counter; // 20-bit for creating 10.5ms refresh period or 380Hz refresh rate
             // the first 2 MSB bits for creating 4 LED-activating signals with 2.6ms digit period
    wire [1:0] LED_activating_counter; 
                 // count     0    ->  1  ->  2  ->  3
              // activates    LED1    LED2   LED3   LED4
             // and repeat
             
    reg [3:0] i_Binary_Num_reg_1 = 0, i_Binary_Num_reg_2 = 0, i_Binary_Num_reg_3 = 0, i_Binary_Num_reg_4 = 0;
    always @(posedge i_Clk) begin 
        i_Binary_Num_reg_1 <= i_Binary_Num_1;
        i_Binary_Num_reg_2 <= i_Binary_Num_2;
        i_Binary_Num_reg_3 <= i_Binary_Num_3;
        i_Binary_Num_reg_4 <= i_Binary_Num_4;
        if(reset==1)
            refresh_counter <= 0;
        else
            refresh_counter <= refresh_counter + 20'h1;
    end 
    assign LED_activating_counter = refresh_counter[14:13];
    // anode activating signals for 4 LEDs, digit period of 2.6ms
    // decoder to generate anode signals 
    always @(posedge i_Clk)
    begin
        case(LED_activating_counter)
        2'b00: begin
            o_Cathode = 4'b0111; 
            // activate LED1 and Deactivate LED2, LED3, LED4
            LED_BCD = i_Binary_Num_reg_1;
            // the first digit of the 16-bit number
              end
        2'b01: begin
            o_Cathode = 4'b1011; 
            // activate LED2 and Deactivate LED1, LED3, LED4
            LED_BCD = i_Binary_Num_reg_2;
            // the second digit of the 16-bit number
              end
        2'b10: begin
            o_Cathode = 4'b1101; 
            // activate LED3 and Deactivate LED2, LED1, LED4
            LED_BCD = i_Binary_Num_reg_3;
            // the third digit of the 16-bit number
                end
        2'b11: begin
            o_Cathode = 4'b1110; 
            // activate LED4 and Deactivate LED2, LED3, LED1
            LED_BCD = i_Binary_Num_reg_4;
            // the fourth digit of the 16-bit number    
               end
        endcase
    end
    // Cathode patterns of the 7-segment LED display 
    always @(posedge i_Clk)
    begin
        case(LED_BCD)
        
        ////////////////////////GFEDCBA  1 = off, 0 = on
        4'b0000: o_Segment = 7'b1000000; // "0"     
        4'b0001: o_Segment = 7'b1111001; // "1" 
        4'b0010: o_Segment = 7'b0100100; // "2" 
        4'b0011: o_Segment = 7'b0110000; // "3" 
        4'b0100: o_Segment = 7'b0011001; // "4" 
        4'b0101: o_Segment = 7'b0010010; // "5" 
        4'b0110: o_Segment = 7'b0000010; // "6" 
        4'b0111: o_Segment = 7'b1111000; // "7" 
        4'b1000: o_Segment = 7'b0000000; // "8"     
        4'b1001: o_Segment = 7'b0010000; // "9" 
        4'b1010: o_Segment = 7'b0001000; // "A" 
        4'b1011: o_Segment = 7'b0000011; // "B" 
        4'b1100: o_Segment = 7'b1000110; // "C" 
        4'b1101: o_Segment = 7'b0100001; // "D" 
        4'b1110: o_Segment = 7'b0000110; // "E" 
        4'b1111: o_Segment = 7'b0001110; // "F" 
        
        default: o_Segment = 7'b1000000; // "0"
        
        endcase
    end
 endmodule