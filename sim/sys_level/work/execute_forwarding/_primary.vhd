library verilog;
use verilog.vl_types.all;
entity execute_forwarding is
    port(
        iCLOCK          : in     vl_logic;
        inRESET         : in     vl_logic;
        iRESET_SYNC     : in     vl_logic;
        iWB_GR_VALID    : in     vl_logic;
        iWB_GR_DATA     : in     vl_logic_vector(31 downto 0);
        iWB_GR_DEST     : in     vl_logic_vector(4 downto 0);
        iWB_GR_DEST_SYSREG: in     vl_logic;
        iWB_SPR_VALID   : in     vl_logic;
        iWB_SPR_DATA    : in     vl_logic_vector(31 downto 0);
        iPREV_WB_GR_VALID: in     vl_logic;
        iPREV_WB_GR_DATA: in     vl_logic_vector(31 downto 0);
        iPREV_WB_GR_DEST: in     vl_logic_vector(4 downto 0);
        iPREV_WB_GR_DEST_SYSREG: in     vl_logic;
        iPREV_WB_SPR_VALID: in     vl_logic;
        iPREV_WB_SPR_DATA: in     vl_logic_vector(31 downto 0);
        iPREVIOUS_SOURCE_SYSREG: in     vl_logic;
        iPREVIOUS_SOURCE_POINTER: in     vl_logic_vector(4 downto 0);
        iPREVIOUS_SOURCE_IMM: in     vl_logic;
        iPREVIOUS_SOURCE_DATA: in     vl_logic_vector(31 downto 0);
        oNEXT_SOURCE_DATA: out    vl_logic_vector(31 downto 0);
        oNEXT_SOURCE_SPR: out    vl_logic_vector(31 downto 0)
    );
end execute_forwarding;
