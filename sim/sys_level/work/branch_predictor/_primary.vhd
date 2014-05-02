library verilog;
use verilog.vl_types.all;
entity branch_predictor is
    port(
        iCLOCK          : in     vl_logic;
        inRESET         : in     vl_logic;
        iFLUSH          : in     vl_logic;
        iSEARCH_STB     : in     vl_logic;
        iSEARCH_INST_ADDR: in     vl_logic_vector(31 downto 0);
        oSEARCH_VALID   : out    vl_logic;
        iSEARCH_LOCK    : in     vl_logic;
        oSRARCH_PREDICT_BRANCH: out    vl_logic;
        oSEARCH_ADDR    : out    vl_logic_vector(31 downto 0);
        iJUMP_STB       : in     vl_logic;
        iJUMP_HIT       : in     vl_logic;
        iJUMP_ADDR      : in     vl_logic_vector(31 downto 0);
        iJUMP_INST_ADDR : in     vl_logic_vector(31 downto 0)
    );
end branch_predictor;
