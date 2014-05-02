library verilog;
use verilog.vl_types.all;
entity execute_mul_booth32 is
    port(
        iDATA_0         : in     vl_logic_vector(31 downto 0);
        iDATA_1         : in     vl_logic_vector(31 downto 0);
        oDATA           : out    vl_logic_vector(63 downto 0);
        oHSF            : out    vl_logic;
        oHOF            : out    vl_logic;
        oHCF            : out    vl_logic;
        oHPF            : out    vl_logic;
        oHZF            : out    vl_logic;
        oLSF            : out    vl_logic;
        oLOF            : out    vl_logic;
        oLCF            : out    vl_logic;
        oLPF            : out    vl_logic;
        oLZF            : out    vl_logic
    );
end execute_mul_booth32;
