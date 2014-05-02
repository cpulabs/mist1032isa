library verilog;
use verilog.vl_types.all;
entity execute_forwarding_register is
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
        iWB_AUTO_SPR_VALID: in     vl_logic;
        iWB_AUTO_SPR_DATA: in     vl_logic_vector(31 downto 0);
        iCUUR_SPR_DATA  : in     vl_logic_vector(31 downto 0);
        oFDR_GR_VALID   : out    vl_logic;
        oFDR_GR_DATA    : out    vl_logic_vector(31 downto 0);
        oFDR_GR_DEST    : out    vl_logic_vector(4 downto 0);
        oFDR_GR_DEST_SYSREG: out    vl_logic;
        oFDR_SPR_VALID  : out    vl_logic;
        oFDR_SPR_DATA   : out    vl_logic_vector(31 downto 0)
    );
end execute_forwarding_register;
