interface apb_if (input logic pclk, input logic presetn);
    logic [7:0] paddr;
    logic psel;
    logic penable;
    logic pwrite;
    logic [31:0] pwdata;
    logic [31:0] prdata;
    logic pready;
    logic pslverr;

    //checks
    property p_setup;
      
      @(posedge pclk) $rose(psel) |-> !penable;
      
    endproperty
    
    property p_access;
      
      @(posedge pclk) $rose(psel) |=> $rose(penable);
      
    endproperty

    assert property (p_setup)  else $error("APB Violation: Setup Phase");
    assert property (p_access) else $error("APB Violation: Access Phase");
      
      
endinterface