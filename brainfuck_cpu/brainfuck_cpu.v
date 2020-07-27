module brainfuck_cpu (

        input clk,
        input rst,
        
        //imem
        input [3:0]  prog_q_sig,
        output [3:0] prog_data_sig,
        output [9:0] prog_address_sig,
        output prog_wren_sig,
        output prog_rden_sig,
        
        //dmem
        input [7:0]  q_sig,
        output [7:0] data_sig,
        output [9:0] address_sig,
        output wren_sig,
        output rden_sig,
        
        //uart connect
        input flag_output_active,
        output flag_output_begin
        );

reg  [9:0] address_sig_reg = 0;
reg  [7:0]  data_sig_reg = 0;
reg         wren_sig_reg = 0, rden_sig_reg = 0;

assign data_sig    = data_sig_reg;
assign address_sig = address_sig_reg;
assign wren_sig    = wren_sig_reg;
assign rden_sig    = rden_sig_reg;

reg  [9:0] prog_address_sig_reg = 0;
reg  [3:0]  prog_data_sig_reg = 0;
reg         prog_wren_sig_reg = 0, prog_rden_sig_reg = 0;

assign prog_data_sig    = prog_data_sig_reg;
assign prog_rden_sig    = prog_rden_sig_reg;
assign prog_address_sig = prog_address_sig_reg;
assign prog_wren_sig    = prog_wren_sig_reg;

reg [9:0] program_counter = 0;
reg [7:0] cpu_state = 0;
reg [3:0] bracket_flag = 0;
reg [9:0] bracket_delta = 10'h0;

reg flag_output_begin_reg = 0;
assign flag_output_begin = flag_output_begin_reg;

localparam  NOP   = 0, //
            CMOVR = 1, // >
            CMOVL = 2, // <
            CADD  = 3, // +
            CRED  = 4, // -
            COUT  = 5, // .
            CIN   = 6, // ,
            CBEG  = 7, // [
            CEND  = 8; // ]
            
localparam  RESTART = 0,
            INSTR_FETCH = 1,
            INSTR_ANALYSIS = 2,
            HALT = 4,
            WAIT = 5,
            WAIT1 = 3,
            WAIT2 = 6,
            WAITtest = 7;
            
localparam  UPDATE = 1,
            STOP = 0;
            
localparam  DEFAULT = 0,
            FIND_OPENING_BRACKET = 1,
            FIND_CLOSING_BRACKET = 2;
            

//instruction fetch
always @ (posedge clk) begin
    
    prog_address_sig_reg <= program_counter;
    prog_wren_sig_reg <= 0;
    prog_rden_sig_reg <= 1;
    
end

//cpu control
always @ (posedge clk) begin
    
    case (cpu_state)
        
        RESTART: begin 
            
            address_sig_reg <= 0;
            data_sig_reg <= 0;
            rden_sig_reg <= 1;
            wren_sig_reg <= 0;
            program_counter <= 0;
            cpu_state <= WAIT;
            bracket_flag <= DEFAULT;
            bracket_delta <= 10'h0;
            flag_output_begin_reg <= 0;
            
        end
        
        HALT: begin
        
            //good night 
        
        end
        
        WAIT: begin
            
            flag_output_begin_reg <= 0;
            wren_sig_reg <= 0;
            rden_sig_reg <= 1;
            
            if(program_counter < 1023) begin 
                //cpu_state <= INSTR_ANALYSIS;
                cpu_state <= WAIT1;
            end
            else begin
                cpu_state <= HALT;
            end
        
        end
        
        WAIT1: begin

            cpu_state <= WAIT2;
        
        end
        
        WAIT2: begin

            cpu_state <= INSTR_ANALYSIS;
        
        end

        INSTR_ANALYSIS: begin
            
            case (bracket_flag)
                
                DEFAULT: begin
                
                    case (prog_q_sig)
                    
                        CMOVL: begin
                        
                            if(address_sig_reg != 0) begin
                                address_sig_reg <= address_sig_reg - 10'h1;
                            end
                            cpu_state <= WAIT;
                            program_counter <= program_counter + 10'h1;
                            
                        end
                        
                        CMOVR: begin
                        
                            address_sig_reg <= address_sig_reg + 10'h1;
                            cpu_state <= WAIT;
                            program_counter <= program_counter + 10'h1;
                            
                        end
                        
                        CADD: begin
                        
                            data_sig_reg <= q_sig + 8'h1;
                            cpu_state <= WAIT;
                            program_counter <= program_counter + 10'h1;
                            wren_sig_reg <= 1;
                            rden_sig_reg <= 0;
                            
                        end
                        
                        CRED: begin
                        
                            data_sig_reg <= q_sig - 8'h1;
                            cpu_state <= WAIT;
                            program_counter <= program_counter + 10'h1;
                            wren_sig_reg <= 1;
                            rden_sig_reg <= 0;
                            
                        end
                        
                        CIN: begin
                        
                            cpu_state <= WAIT;
                            program_counter <= program_counter + 10'h1;
                            
                        end
                        
                        COUT: begin
                            if(flag_output_active == 0) begin
                                cpu_state <= WAIT;
                                program_counter <= program_counter + 10'h1;
                                flag_output_begin_reg <= 1;
                            end
                            else if(flag_output_active == 1) begin
                                cpu_state <= INSTR_ANALYSIS;
                            end
                        end
                        
                        CBEG: begin
                        
                            if(q_sig == 0) begin
                                bracket_flag <= FIND_CLOSING_BRACKET;
                            end

                            cpu_state <= WAIT;
                            program_counter <= program_counter + 10'h1;
                            
                        end
                        
                        CEND: begin
                            
                            if (q_sig != 0) begin
                                bracket_flag <= FIND_OPENING_BRACKET;
                                program_counter <= program_counter - 10'h1;
                            end
                            else begin //q == 0
                                program_counter <= program_counter + 10'h1;
                            end
                            
                            cpu_state <= WAIT;
                            
                        end
                        
                        //NOP or every other operation
                        default: begin
                        
                            cpu_state <= WAIT;
                            program_counter <= program_counter + 10'h1;
                            
                        end
                        
                    endcase
                end
                
                FIND_OPENING_BRACKET: begin
                    
                    cpu_state <= WAIT;
                    
                    case (prog_q_sig)
                       
                        CBEG: begin
                        
                            if((bracket_delta) == 10'h0) begin
                                bracket_flag <= DEFAULT;
                                program_counter <= program_counter + 10'h1;
                            end
                            else begin 
                                bracket_delta <= bracket_delta - 10'h1;
                                program_counter <= program_counter - 10'h1;
                            end
                            
                        end
                        
                        CEND: begin
                        
                            bracket_delta <= bracket_delta + 10'h1;
                            program_counter <= program_counter - 10'h1;
                            
                        end
                        
                        default: begin
                        
                            program_counter <= program_counter - 10'h1;
                            
                        end
                        
                    endcase
                    
                end
                
                FIND_CLOSING_BRACKET: begin
                    
                    program_counter <= program_counter + 10'h1;
                    cpu_state <= WAIT;
                    
                    case (prog_q_sig)
                        
                        CBEG: begin
                        
                            bracket_delta <= bracket_delta + 10'h1;
                            
                        end
                        
                        CEND: begin
                        
                            if((bracket_delta) == 10'h0) begin
                                bracket_flag <= DEFAULT;
                            end
                            else begin 
                                bracket_delta <= bracket_delta - 10'h1;
                            end
                            
                        end
                        
                        default: begin
                        
                        end
                        
                    endcase
                    
                end
            
            endcase
            
        end
        
    endcase
    
end

endmodule
