// Code your testbench here
// or browse Examples
class transaction;
  bit newd;
  rand bit [11:0] din;
  bit [11:0] dout;
  
  function transaction copy();
    copy = new();
    copy.newd=this.newd;
    copy.din=this.din;
    copy.dout=this.dout;
  endfunction
endclass

class generator;
  transaction tr_g;
  mailbox #(transaction) mbx_gd;
  
  event done;
  event sconext;
  
  int count;
  
  function new(mailbox #(transaction) mbx_gd);
    this.mbx_gd = mbx_gd;
    tr_g=new();
  endfunction
  
  task run();
    repeat(count) begin
      assert(tr_g.randomize) else $error("Randomization failed");
      mbx_gd.put(tr_g.copy);
      $display("[GEN]: din = %0d", tr_g.din);
      @(sconext);
      
    end
    ->done;
    
  endtask
endclass

class driver;
  transaction tr_d;
  mailbox #(transaction) mbx_gd;
  mailbox #(bit [11:0]) mbx_ds;
  
  virtual spi_if vif;
  
  
  function new(mailbox #(transaction) mbx_gd, mailbox #(bit [11:0]) mbx_ds);
    this.mbx_gd=mbx_gd;
    this.mbx_ds=mbx_ds;
  endfunction
  
  task reset();
  	vif.rst<=1;
    vif.newd<=0;
    vif.din<=0;
    repeat(5) @(posedge vif.clk);
    vif.rst<=0;
    repeat(5) @(posedge vif.clk);
    $display("reset done");
    $display("----------------------------");
  endtask
  
  task run();
    forever begin
      mbx_gd.get(tr_d);
      vif.newd<=1;
      vif.din<=tr_d.din;
      //mbx_ds.put(vif.din);
      @(posedge vif.sclk);
      vif.newd<=0;
      @(posedge vif.done);
      $display("[DRV] : DATA SENT TO DAC : %0d",tr_d.din);
      mbx_ds.put(vif.din);
      @(posedge vif.sclk);
    
    end
  endtask
  
endclass

class monitor;
  transaction tr_m;
  mailbox #(bit [11:0]) mbx_ms;
  
  virtual spi_if vif;
  
  function new(mailbox #(bit [11:0]) mbx_ms);
    
    this.mbx_ms=mbx_ms;
  endfunction
  
  task run();
    tr_m=new();
    forever begin
      @(posedge vif.sclk);
      @(posedge vif.done);
      tr_m.dout = vif.dout;
      @(posedge vif.sclk);
      $display("[MON] : DATA received : %0d", tr_m.dout);
      mbx_ms.put(tr_m.dout);
      @(posedge vif.sclk);
    end
  endtask
endclass

class scoreboard;
  mailbox #(bit [11:0]) mbx_ds, mbx_ms; // Mailboxes for data from driver and monitor
  bit [11:0] ds;                       // Data from driver
  bit [11:0] ms;                       // Data from monitor
  event sconext;                       // Event to synchronize with environment
  
  function new(mailbox #(bit [11:0]) mbx_ds, mailbox #(bit [11:0]) mbx_ms);
    this.mbx_ds = mbx_ds;                // Initialize mailboxes
    this.mbx_ms = mbx_ms;
  endfunction
  
  task run();
    forever begin
      mbx_ds.get(ds);                   // Get data from driver
      mbx_ms.get(ms);                   // Get data from monitor
      $display("[SCO] : DRV : %0d MON : %0d", ds, ms);
      
      if(ds == ms)
        $display("[SCO] : DATA MATCHED");
      else
        $display("[SCO] : DATA MISMATCHED");
      
      $display("-----------------------------------------");
      ->sconext;                        // Synchronize with the environment
    end
  endtask
endclass



class environment;
    generator gen;                   // Generator object
    driver drv;                     // Driver object
    monitor mon;                   // Monitor object
    scoreboard sco;                 // Scoreboard object
    
    event nextgd;                   // Event for generator to driver communication
    event nextgs;                   // Event for generator to scoreboard communication
   
  mailbox #(transaction) mbxgd;   // Mailbox for generator to driver communication
    mailbox #(bit [11:0]) mbxds;    // Mailbox for driver to monitor communication
    mailbox #(bit [11:0]) mbxms;    // Mailbox for monitor to scoreboard communication
  
    virtual spi_if vif;             // Virtual interface
  
  function new(virtual spi_if vif);
       
    mbxgd = new();                  // Initialize mailboxes
    mbxms = new();
    mbxds = new();
    gen = new(mbxgd);               // Initialize generator
    drv = new(mbxgd,mbxds);         // Initialize driver
    mon = new(mbxms);               // Initialize monitor
    sco = new(mbxds, mbxms);        // Initialize scoreboard
    
    this.vif = vif;
    drv.vif = this.vif;
    mon.vif = this.vif;
    
    gen.sconext = nextgs;           // Set synchronization events
    sco.sconext = nextgs;
    
  endfunction
  
  task pre_test();
    drv.reset();                    // Perform driver reset
  endtask
  
  task test();
  fork
    gen.run();                      // Run generator
    drv.run();                      // Run driver
    mon.run();                      // Run monitor
    sco.run();                      // Run scoreboard
  join_any
  endtask
  
  task post_test();
    wait(gen.done.triggered);       // Wait for generator to finish  
    $finish();
  endtask
  
  task run();
    pre_test();
    test();
    post_test();
  endtask
endclass

module tb;
  spi_if vif();                    // Virtual interface instance
  
  top dut(vif.clk, vif.newd, vif.rst, vif.din, vif.done, vif.dout);
  
  initial begin
    vif.clk <= 0;
  end
    
  always #10 vif.clk <= ~vif.clk;
  
  environment env;
  
  assign vif.sclk = dut.m1.sclk;
  
  initial begin
    env = new(vif);
    env.gen.count = 4;
    env.run();
  end
      
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
endmodule


