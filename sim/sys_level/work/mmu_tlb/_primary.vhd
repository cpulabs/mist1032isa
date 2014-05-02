library verilog;
use verilog.vl_types.all;
entity mmu_tlb is
    port(
        iCLOCK          : in     vl_logic;
        inRESET         : in     vl_logic;
        iREMOVE         : in     vl_logic;
        iRD_REQ         : in     vl_logic;
        oRD_BUSY        : out    vl_logic;
        iRD_MOD         : in     vl_logic_vector(1 downto 0);
        iRD_PS          : in     vl_logic_vector(2 downto 0);
        iRD_ADDR        : in     vl_logic_vector(31 downto 0);
        oRD_VALID       : out    vl_logic;
        iRD_BUSY        : in     vl_logic;
        oRD_HIT         : out    vl_logic;
        oRD_FLAGS       : out    vl_logic_vector(23 downto 0);
        oRD_PHYS_ADDR   : out    vl_logic_vector(63 downto 0);
        iWR_REQ         : in     vl_logic;
        iWR_MOD         : in     vl_logic_vector(1 downto 0);
        iWR_PS          : in     vl_logic_vector(2 downto 0);
        iWR_ADDR        : in     vl_logic_vector(31 downto 0);
        iWR_PHYS_ADDR   : in     vl_logic_vector(63 downto 0)
    );
end mmu_tlb;
