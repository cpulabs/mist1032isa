library verilog;
use verilog.vl_types.all;
entity fetch is
    port(
        iCLOCK          : in     vl_logic;
        inRESET         : in     vl_logic;
        iSYSREG_PSR     : in     vl_logic_vector(31 downto 0);
        iEXCEPTION_EVENT: in     vl_logic;
        iEXCEPTION_ADDR_SET: in     vl_logic;
        iEXCEPTION_ADDR : in     vl_logic_vector(31 downto 0);
        iEXCEPTION_RESTART: in     vl_logic;
        oBRANCH_PREDICT_FETCH_FLUSH: out    vl_logic;
        iBRANCH_PREDICT_RESULT_PREDICT: in     vl_logic;
        iBRANCH_PREDICT_RESULT_HIT: in     vl_logic;
        iBRANCH_PREDICT_RESULT_JUMP: in     vl_logic;
        iBRANCH_PREDICT_RESULT_JUMP_ADDR: in     vl_logic_vector(31 downto 0);
        iBRANCH_PREDICT_RESULT_INST_ADDR: in     vl_logic_vector(31 downto 0);
        iPREVIOUS_INST_VALID: in     vl_logic;
        iPREVIOUS_MMU_FLAGS: in     vl_logic_vector(11 downto 0);
        iPREVIOUS_INST  : in     vl_logic_vector(31 downto 0);
        oPREVIOUS_LOCK  : out    vl_logic;
        oPREVIOUS_FETCH_REQ: out    vl_logic;
        iPREVIOUS_FETCH_LOCK: in     vl_logic;
        oPREVIOUS_MMUMOD: out    vl_logic_vector(1 downto 0);
        oPREVIOUS_MMUPS : out    vl_logic_vector(2 downto 0);
        oPREVIOUS_FETCH_ADDR: out    vl_logic_vector(31 downto 0);
        oNEXT_INST_VALID: out    vl_logic;
        oNEXT_MMU_FLAGS : out    vl_logic_vector(11 downto 0);
        oNEXT_PAGING_ENA: out    vl_logic;
        oNEXT_KERNEL_ACCESS: out    vl_logic;
        oNEXT_BRANCH_PREDICT: out    vl_logic;
        oNEXT_BRANCH_PREDICT_ADDR: out    vl_logic_vector(31 downto 0);
        oNEXT_INST      : out    vl_logic_vector(31 downto 0);
        oNEXT_PC        : out    vl_logic_vector(31 downto 0);
        iNEXT_FETCH_STOP: in     vl_logic;
        iNEXT_LOCK      : in     vl_logic
    );
end fetch;
