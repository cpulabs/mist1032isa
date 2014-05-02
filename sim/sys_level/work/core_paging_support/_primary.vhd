library verilog;
use verilog.vl_types.all;
entity core_paging_support is
    port(
        iSYSREG_PSR     : in     vl_logic_vector(31 downto 0);
        iPDTR_WRITEBACK : in     vl_logic;
        oCACHE_FLASH    : out    vl_logic
    );
end core_paging_support;
