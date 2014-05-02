library verilog;
use verilog.vl_types.all;
entity sdi_interface_control is
    port(
        iCLOCK          : in     vl_logic;
        inRESET         : in     vl_logic;
        iIF_SELECT      : in     vl_logic;
        iDEBUG_UART_RXD : in     vl_logic;
        oDEBUG_UART_TXD : out    vl_logic;
        iDEBUG_PARA_REQ : in     vl_logic;
        oDEBUG_PARA_BUSY: out    vl_logic;
        iDEBUG_PARA_CMD : in     vl_logic_vector(7 downto 0);
        iDEBUG_PARA_DATA: in     vl_logic_vector(31 downto 0);
        oDEBUG_PARA_VALID: out    vl_logic;
        iDEBUG_PARA_BUSY: in     vl_logic;
        oDEBUG_PARA_ERROR: out    vl_logic;
        oDEBUG_PARA_DATA: out    vl_logic_vector(31 downto 0);
        oDEBUG_COM_REQ  : out    vl_logic;
        iDEBUG_COM_BUSY : in     vl_logic;
        oDEBUG_COM_CMD  : out    vl_logic_vector(7 downto 0);
        oDEBUG_COM_DATA : out    vl_logic_vector(31 downto 0);
        iDEBUG_COM_VALID: in     vl_logic;
        oDEBUG_COM_BUSY : out    vl_logic;
        iDEBUG_COM_ERROR: in     vl_logic;
        iDEBUG_COM_DATA : in     vl_logic_vector(31 downto 0)
    );
end sdi_interface_control;
