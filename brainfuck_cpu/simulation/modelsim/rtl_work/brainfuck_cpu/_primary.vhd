library verilog;
use verilog.vl_types.all;
entity brainfuck_cpu is
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        prog_q_sig      : in     vl_logic_vector(3 downto 0);
        prog_data_sig   : out    vl_logic_vector(3 downto 0);
        prog_address_sig: out    vl_logic_vector(9 downto 0);
        prog_wren_sig   : out    vl_logic;
        prog_rden_sig   : out    vl_logic;
        q_sig           : in     vl_logic_vector(7 downto 0);
        data_sig        : out    vl_logic_vector(7 downto 0);
        address_sig     : out    vl_logic_vector(9 downto 0);
        wren_sig        : out    vl_logic;
        rden_sig        : out    vl_logic;
        flag_output_active: in     vl_logic;
        flag_output_begin: out    vl_logic
    );
end brainfuck_cpu;
