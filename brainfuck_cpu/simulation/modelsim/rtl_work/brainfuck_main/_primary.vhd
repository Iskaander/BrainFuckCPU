library verilog;
use verilog.vl_types.all;
entity brainfuck_main is
    generic(
        c_CLKS_PER_BIT  : integer := 200
    );
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        led             : out    vl_logic_vector(3 downto 0);
        uart_out        : out    vl_logic;
        Segments        : out    vl_logic_vector(6 downto 0);
        Cathodes        : out    vl_logic_vector(3 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of c_CLKS_PER_BIT : constant is 1;
end brainfuck_main;
