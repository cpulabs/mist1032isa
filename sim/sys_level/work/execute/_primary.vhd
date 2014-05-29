library verilog;
use verilog.vl_types.all;
entity execute is
    port(
        iCLOCK          : in     vl_logic;
        inRESET         : in     vl_logic;
        iRESET_SYNC     : in     vl_logic;
        iFREE_REGISTER_LOCK: in     vl_logic;
        iFREE_PIPELINE_STOP: in     vl_logic;
        iFREE_REFRESH   : in     vl_logic;
        oEXCEPTION_LOCK : out    vl_logic;
        oEXCEPTION_LDST_LOCK: out    vl_logic;
        oSYSREG_FLAGR   : out    vl_logic_vector(31 downto 0);
        iPREVIOUS_VALID : in     vl_logic;
        iPREVIOUS_FAULT_PAGEFAULT: in     vl_logic;
        iPREVIOUS_FAULT_PRIVILEGE_ERROR: in     vl_logic;
        iPREVIOUS_FAULT_INVALID_INST: in     vl_logic;
        iPREVIOUS_PAGING_ENA: in     vl_logic;
        iPREVIOUS_KERNEL_ACCESS: in     vl_logic;
        iPREVIOUS_BRANCH_PREDICT: in     vl_logic;
        iPREVIOUS_BRANCH_PREDICT_ADDR: in     vl_logic_vector(31 downto 0);
        iPREVIOUS_SYSREG_PSR: in     vl_logic_vector(31 downto 0);
        iPREVIOUS_SYSREG_TIDR: in     vl_logic_vector(31 downto 0);
        iPREVIOUS_SYSREG_PDTR: in     vl_logic_vector(31 downto 0);
        iPREVIOUS_DESTINATION_SYSREG: in     vl_logic;
        iPREVIOUS_DESTINATION: in     vl_logic_vector(4 downto 0);
        iPREVIOUS_WRITEBACK: in     vl_logic;
        iPREVIOUS_FLAGS_WRITEBACK: in     vl_logic;
        iPREVIOUS_CMD   : in     vl_logic_vector(4 downto 0);
        iPREVIOUS_CC_AFE: in     vl_logic_vector(3 downto 0);
        iPREVIOUS_SPR   : in     vl_logic_vector(31 downto 0);
        iPREVIOUS_SOURCE0: in     vl_logic_vector(31 downto 0);
        iPREVIOUS_SOURCE1: in     vl_logic_vector(31 downto 0);
        iPREVIOUS_ADV_DATA: in     vl_logic_vector(5 downto 0);
        iPREVIOUS_SOURCE0_POINTER: in     vl_logic_vector(4 downto 0);
        iPREVIOUS_SOURCE1_POINTER: in     vl_logic_vector(4 downto 0);
        iPREVIOUS_SOURCE0_SYSREG: in     vl_logic;
        iPREVIOUS_SOURCE1_SYSREG: in     vl_logic;
        iPREVIOUS_SOURCE1_IMM: in     vl_logic;
        iPREVIOUS_SOURCE0_FLAGS: in     vl_logic;
        iPREVIOUS_ADV_ACTIVE: in     vl_logic;
        iPREVIOUS_EX_SYS_REG: in     vl_logic;
        iPREVIOUS_EX_SYS_LDST: in     vl_logic;
        iPREVIOUS_EX_LOGIC: in     vl_logic;
        iPREVIOUS_EX_SHIFT: in     vl_logic;
        iPREVIOUS_EX_ADDER: in     vl_logic;
        iPREVIOUS_EX_MUL: in     vl_logic;
        iPREVIOUS_EX_SDIV: in     vl_logic;
        iPREVIOUS_EX_UDIV: in     vl_logic;
        iPREVIOUS_EX_LDST: in     vl_logic;
        iPREVIOUS_EX_BRANCH: in     vl_logic;
        iPREVIOUS_PC    : in     vl_logic_vector(31 downto 0);
        oPREVIOUS_LOCK  : out    vl_logic;
        oDATAIO_REQ     : out    vl_logic;
        iDATAIO_BUSY    : in     vl_logic;
        oDATAIO_ORDER   : out    vl_logic_vector(1 downto 0);
        oDATAIO_MASK    : out    vl_logic_vector(3 downto 0);
        oDATAIO_RW      : out    vl_logic;
        oDATAIO_TID     : out    vl_logic_vector(13 downto 0);
        oDATAIO_MMUMOD  : out    vl_logic_vector(1 downto 0);
        oDATAIO_MMUPS   : out    vl_logic_vector(2 downto 0);
        oDATAIO_PDT     : out    vl_logic_vector(31 downto 0);
        oDATAIO_ADDR    : out    vl_logic_vector(31 downto 0);
        oDATAIO_DATA    : out    vl_logic_vector(31 downto 0);
        iDATAIO_REQ     : in     vl_logic;
        iDATAIO_MMU_FLAGS: in     vl_logic_vector(11 downto 0);
        iDATAIO_DATA    : in     vl_logic_vector(31 downto 0);
        oNEXT_VALID     : out    vl_logic;
        oNEXT_DATA      : out    vl_logic_vector(31 downto 0);
        oNEXT_DESTINATION: out    vl_logic_vector(4 downto 0);
        oNEXT_DESTINATION_SYSREG: out    vl_logic;
        oNEXT_WRITEBACK : out    vl_logic;
        oNEXT_SPR_WRITEBACK: out    vl_logic;
        oNEXT_SPR       : out    vl_logic_vector(31 downto 0);
        oNEXT_PC        : out    vl_logic_vector(31 downto 0);
        oNEXT_BRANCH    : out    vl_logic;
        oNEXT_BRANCH_PC : out    vl_logic_vector(31 downto 0);
        oPDTR_WRITEBACK : out    vl_logic;
        oBRANCH_ADDR    : out    vl_logic_vector(31 downto 0);
        oJUMP_VALID     : out    vl_logic;
        oINTR_VALID     : out    vl_logic;
        oIDTSET_VALID   : out    vl_logic;
        oPDTSET_VALID   : out    vl_logic;
        oFAULT_VALID    : out    vl_logic;
        oFAULT_NUM      : out    vl_logic_vector(6 downto 0);
        oFAULT_FI0R     : out    vl_logic_vector(31 downto 0);
        oBPREDICT_PREDICT: out    vl_logic;
        oBPREDICT_HIT   : out    vl_logic;
        oBPREDICT_JUMP  : out    vl_logic;
        oBPREDICT_JUMP_ADDR: out    vl_logic_vector(31 downto 0);
        oBPREDICT_INST_ADDR: out    vl_logic_vector(31 downto 0);
        iDEBUG_CTRL_REQ : in     vl_logic;
        iDEBUG_CTRL_STOP: in     vl_logic;
        iDEBUG_CTRL_START: in     vl_logic;
        oDEBUG_CTRL_ACK : out    vl_logic;
        oDEBUG_REG_OUT_FLAGR: out    vl_logic_vector(31 downto 0)
    );
end execute;