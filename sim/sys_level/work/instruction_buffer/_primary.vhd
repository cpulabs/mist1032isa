library verilog;
use verilog.vl_types.all;
entity instruction_buffer is
    port(
        iCLOCK          : in     vl_logic;
        inRESET         : in     vl_logic;
        iFREE_REFRESH   : in     vl_logic;
        iPREVIOUS_INST_VALID: in     vl_logic;
        iPREVIOUS_MMU_FLAGS: in     vl_logic_vector(11 downto 0);
        iPREVIOUS_PAGING_ENA: in     vl_logic;
        iPREVIOUS_KERNEL_ACCESS: in     vl_logic;
        iPREVIOUS_BRANCH_PREDICT: in     vl_logic;
        iPREVIOUS_BRANCH_PREDICT_ADDR: in     vl_logic_vector(31 downto 0);
        iPREVIOUS_INST  : in     vl_logic_vector(31 downto 0);
        iPREVIOUS_PC    : in     vl_logic_vector(31 downto 0);
        oPREVIOUS_FETCH_STOP: out    vl_logic;
        oPREVIOUS_LOCK  : out    vl_logic;
        oNEXT_INST_VALID: out    vl_logic;
        oNEXT_FAULT_PAGEFAULT: out    vl_logic;
        oNEXT_FAULT_PRIVILEGE_ERROR: out    vl_logic;
        oNEXT_FAULT_INVALID_INST: out    vl_logic;
        oNEXT_PAGING_ENA: out    vl_logic;
        oNEXT_KERNEL_ACCESS: out    vl_logic;
        oNEXT_BRANCH_PREDICT: out    vl_logic;
        oNEXT_BRANCH_PREDICT_ADDR: out    vl_logic_vector(31 downto 0);
        oNEXT_INST      : out    vl_logic_vector(31 downto 0);
        oNEXT_PC        : out    vl_logic_vector(31 downto 0);
        iNEXT_LOCK      : in     vl_logic
    );
end instruction_buffer;
