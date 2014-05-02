library verilog;
use verilog.vl_types.all;
entity mmu_table_load is
    port(
        iCLOCK          : in     vl_logic;
        inRESET         : in     vl_logic;
        iRESET_SYNC     : in     vl_logic;
        iLD_REQ         : in     vl_logic;
        iLD_ADDR        : in     vl_logic_vector(31 downto 0);
        oLD_BUSY        : out    vl_logic;
        oMEM_REQ        : out    vl_logic;
        iMEM_LOCK       : in     vl_logic;
        oMEM_ADDR       : out    vl_logic_vector(31 downto 0);
        iMEM_VALID      : in     vl_logic;
        iMEM_DATA       : in     vl_logic_vector(63 downto 0);
        oDONE_VALID     : out    vl_logic;
        oDONE_DATA      : out    vl_logic_vector(31 downto 0);
        oDONE_FLAG0     : out    vl_logic_vector(11 downto 0);
        oDONE_FLAG1     : out    vl_logic_vector(11 downto 0)
    );
end mmu_table_load;
