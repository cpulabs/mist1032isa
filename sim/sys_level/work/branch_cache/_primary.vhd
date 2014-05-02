library verilog;
use verilog.vl_types.all;
entity branch_cache is
    generic(
        LRU_TIMER_N     : integer := 8
    );
    port(
        iCLOCK          : in     vl_logic;
        inRESET         : in     vl_logic;
        iFLUSH          : in     vl_logic;
        iSEARCH_STB     : in     vl_logic;
        iSEARCH_INST_ADDR: in     vl_logic_vector(31 downto 0);
        oSEARCH_VALID   : out    vl_logic;
        oSEARCH_HIT     : out    vl_logic;
        oSRARCH_PREDICT_BRANCH: out    vl_logic;
        oSEARCH_ADDR    : out    vl_logic_vector(31 downto 0);
        iJUMP_STB       : in     vl_logic;
        iJUMP_HIT       : in     vl_logic;
        iJUMP_ADDR      : in     vl_logic_vector(31 downto 0);
        iJUMP_INST_ADDR : in     vl_logic_vector(31 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of LRU_TIMER_N : constant is 1;
end branch_cache;
