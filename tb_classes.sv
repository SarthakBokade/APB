
// Transaction class

class transaction;
    rand bit [7:0] paddr;
    rand bit [31:0] pwdata;
    rand bit pwrite;
    bit [31:0] prdata;
    bit pslverr;
    
    constraint c_addr{ paddr dist { [0:200]:=80, [201:255]:=20 }; }
  
endclass


//Generator class

class generator;
  
  transaction tr;
  mailbox #(transaction) mbx;
  
  event done;
    
  function new(mailbox #(transaction) mbx);
    
    this.mbx = mbx;
    
  endfunction

  task run();
    
    repeat(20) begin
      
  tr = new();
  assert(tr.randomize());
  mbx.put(tr);
      
  end
    
  -> done;
    
  endtask
  
endclass


// Driver
class driver;
  virtual apb_if vif;
  mailbox #(transaction) mbx;
  transaction tr;

  function new(mailbox #(transaction) mbx);
    this.mbx = mbx;
  endfunction

  task run();
    vif.psel <= 0; vif.penable <= 0;
        
  forever begin
    mbx.get(tr); 
            
    // setup phase
    @(posedge vif.pclk);
    vif.psel    <= 1;
    vif.penable <= 0;
    vif.paddr   <= tr.paddr;
    vif.pwrite  <= tr.pwrite;
    vif.pwdata  <= (tr.pwrite) ? tr.pwdata : 0;
            
    // access phase
    @(posedge vif.pclk);
    vif.penable <= 1;
            
    // wait state
    @(posedge vif.pclk);
    while(vif.pready == 0) begin
    @(posedge vif.pclk);
    end

   // IDLE
   vif.psel    <= 0;
   vif.penable <= 0;
  end
    
  endtask
  
endclass


// Monitor class

class monitor;
  virtual apb_if vif;
  mailbox #(transaction) mbx;
  transaction tr;
    
  covergroup cg_apb;
    cp_addr: coverpoint tr.paddr {
      bins valid = {[0:200]};
        bins error = {[201:255]};
      
        }
    
      cp_write: coverpoint tr.pwrite;
      cross cp_addr, cp_write;
    
    endgroup

  function new(mailbox #(transaction) mbx);
    this.mbx = mbx;
    cg_apb = new();
  endfunction

  task run();
    forever begin
      @(posedge vif.pclk);
      if (vif.psel && vif.penable && vif.pready) begin
      tr = new(); 
      tr.paddr = vif.paddr;
      tr.pwrite = vif.pwrite;
      tr.pwdata = vif.pwdata;
      tr.prdata = vif.prdata;
      tr.pslverr = vif.pslverr;
                
      cg_apb.sample(); 
      mbx.put(tr);
        
      end
      
    end

  endtask
  
endclass

// Scoreboard class
class scoreboard;
  mailbox #(transaction) mbx;
  transaction tr;
  bit [31:0] mem_ref [256];

  function new(mailbox #(transaction) mbx);
    this.mbx = mbx;
  endfunction

  task run();
    
    forever begin
      
      mbx.get(tr);
      if (tr.pslverr) begin 
        
        $display("[SCO] Expected Error (Addr > 200)");
        
      end 
      
      else if (tr.pwrite) begin 
        
        mem_ref[tr.paddr] = tr.pwdata;
        $display("[SCO] WRITE Addr:%0d Data:%0h", tr.paddr, tr.pwdata);
        
      end 
      
      else begin
        
        if (mem_ref[tr.paddr] == tr.prdata)
          $display("[SCO] READ MATCH Addr:%0d", tr.paddr);
        else
          $error("[SCO] MISMATCH! Addr:%0d Exp:%0h Act:%0h", tr.paddr, mem_ref[tr.paddr], tr.prdata);
        end
      
    end
    
  endtask
  
  
endclass



