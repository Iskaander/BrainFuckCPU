library verilog;
use verilog.vl_types.all;
entity seven_segment_controller is
    port(
        i_Clk           : in     vl_logic;
        reset           : in     vl_logic;
        i_Binary_Num_1  : in     vl_logic_vector(3 downto 0);
        i_Binary_Num_2  : in     vl_logic_vector(3 downto 0);
        i_Binary_Num_3  : in     vl_logic_vector(3 downto 0);
        i_Binary_Num_4  : in     vl_logic_vector(3 downto 0);
        o_Cathode       : out    vl_logic_vector(3 downto 0);
        o_Segment       : out    vl_logic_vector(6 downto 0)
    );
end seven_segment_controller;
