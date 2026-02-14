`timescale 1ns / 1ps

module apb_slave #(
  parameter DATA_WIDTH = 32,
  parameter ADDR_WIDTH = 8 )
(
    input pclk,
    input presetn,
    input [ADDR_WIDTH-1:0] paddr,
    input psel,
    input penable,
    input pwrite,
    input [DATA_WIDTH-1:0] pwdata,
    output reg [DATA_WIDTH-1:0] prdata,
    output reg pready,
    output reg pslverr
  
);

  reg [DATA_WIDTH-1:0] mem [0:(1 << ADDR_WIDTH) - 1];
  
  // Memory Array (256 x 32-bit)
    reg [DATA_WIDTH-1:0] mem [0:(1<<ADDR_WIDTH)-1];

    // --- ADD THIS BLOCK ---
    initial begin
        // Initialize memory to 0 for simulation to avoid 'X' on reads
        for (int i = 0; i < (1<<ADDR_WIDTH); i++) begin
            mem[i] = 0;
        end
    end
    // ----------------------

    typedef enum logic [1:0] {IDLE = 2'b00,SETUP = 2'b01,ACCESS = 2'b10} state_t;

    state_t state, nstate;
    reg [1:0] wait_count; 

    //FSM seq
    always @(posedge pclk or negedge presetn) begin
      
      if (!presetn) state <= IDLE;
      
      else state <= nstate;
      
    end

    //FSM Comb
    always @(*) begin
      
      nstate = state;
      case (state)
        
        IDLE: begin
          
          if (psel && !penable) nstate = SETUP;
          
        end
        
        SETUP: begin
          
                if (psel && penable) nstate = ACCESS;
          
            end
        
        ACCESS: begin
          
          if (pready) begin
            
            if (psel && !penable) nstate = SETUP; 
            
            else if (!psel)       nstate = IDLE;
            
          end
          
        end
      endcase
    end

    // Op 
    always @(posedge pclk or negedge presetn) begin
      if (!presetn) begin
        pready <= 0;
        prdata <= 0;
        pslverr <= 0;
        wait_count <= 0;
      end 
      
      else begin
      // Wait logic
        if (state == SETUP) begin

          wait_count <= 1; // 1 cycle wait
          pready <= 0;
          
        end 

        else if (state == ACCESS) begin

          if (wait_count > 0) begin
            wait_count <= wait_count - 1;
            pready <= 0;
          end

          else begin
            pready <= 1;
          end
        
      end 
        
        
      else begin
        pready <= 0;
      end

       // error logic
      if (state == SETUP) begin
        pslverr <= (paddr > 200); 
      end
            
      // data transfer
      if (state == ACCESS && pready && !pslverr) begin
        
        if (pwrite) mem[paddr] <= pwdata;
        else prdata <= mem[paddr];
        
      end
        
    end
      
  end
  
endmodule