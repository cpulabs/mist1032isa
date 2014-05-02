library verilog;
use verilog.vl_types.all;
entity sdi_debugger is
    port(
        iCLOCK          : in     vl_logic;
        inRESET         : in     vl_logic;
        oDEBUG_CMD_REQ  : out    vl_logic;
        iDEBUG_CMD_BUSY : in     vl_logic;
        oDEBUG_CMD_COMMAND: out    vl_logic_vector(3 downto 0);
        oDEBUG_CMD_TARGET: out    vl_logic_vector(7 downto 0);
        oDEBUG_CMD_DATA : out    vl_logic_vector(31 downto 0);
        iDEBUG_CMD_VALID: in     vl_logic;
        iDEBUG_CMD_ERROR: in     vl_logic;
        iDEBUG_CMD_DATA : in     vl_logic_vector(31 downto 0);
        iDEBUG_UART_RXD : in     vl_logic;
        oDEBUG_UART_TXD : out    vl_logic;
        iDEBUG_PARA_REQ : in     vl_logic;
        oDEBUG_PARA_BUSY: out    vl_logic;
        iDEBUG_PARA_CMD : in     vl_logic_vector(7 downto 0);
        iDEBUG_PARA_DATA: in     vl_logic_vector(31 downto 0);
        oDEBUG_PARA_VALID: out    vl_logic;
        iDEBUG_PARA_BUSY: in     vl_logic;
        oDEBUG_PARA_ERROR: out    vl_logic;
        oDEBUG_PARA_DATA: out    vl_logic_vector(31 downto 0)
    );
end sdi_debugger;
