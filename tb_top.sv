`timescale 1ns / 1ps


//`include "apb_slave.sv"
//`include "apb_if.sv"
`include "tb_classes.sv"

module tb_top;
  bit pclk, presetn;
    
  always #5 pclk = ~pclk;

  apb_if vif(pclk, presetn);
    
  apb_slave dut (
    .pclk(vif.pclk), .presetn(vif.presetn),
    .paddr(vif.paddr), .psel(vif.psel), .penable(vif.penable),
    .pwrite(vif.pwrite), .pwdata(vif.pwdata), .prdata(vif.prdata),
    .pready(vif.pready), .pslverr(vif.pslverr)
  );

    generator gen;
    driver drv;
    monitor mon;
    scoreboard sco;
    mailbox #(transaction) gen2drv, mon2sco;

  initial begin
      
    pclk = 0; 
    presetn = 0;
        
    gen2drv = new(1); 
    mon2sco = new();
        
    gen = new(gen2drv);
    drv = new(gen2drv);
    mon = new(mon2sco);
    sco = new(mon2sco);
        
    drv.vif = vif;
    mon.vif = vif;
        
    #10 presetn = 1;
        
    fork
    gen.run();
    drv.run();
    mon.run();
    sco.run();
    join_any
        
    wait(gen.done.triggered);
      #200; 
      $finish();
    end
    
  initial begin
    
    $dumpfile("dump.vcd");
    $dumpvars;
    
   end
  
endmodule