library verilog;
use verilog.vl_types.all;
entity altera_primitive_sync_fifo_34in_34out_8depth is
    port(
        aclr            : in     vl_logic;
        clock           : in     vl_logic;
        data            : in     vl_logic_vector(33 downto 0);
        rdreq           : in     vl_logic;
        sclr            : in     vl_logic;
        wrreq           : in     vl_logic;
        almost_empty    : out    vl_logic;
        almost_full     : out    vl_logic;
        empty           : out    vl_logic;
        full            : out    vl_logic;
        q               : out    vl_logic_vector(33 downto 0);
        usedw           : out    vl_logic_vector(2 downto 0)
    );
end altera_primitive_sync_fifo_34in_34out_8depth;
