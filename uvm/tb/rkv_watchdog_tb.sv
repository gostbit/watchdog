
module rkv_watchdog_tb;

  bit apb_clk;
  bit apb_rstn;
  bit wdg_clk;
  bit wdg_rstn;

  cmsdk_apb_watchdog dut(
    .PCLK               (apb_clk),
    .PRESETn            (apb_rstn),
    .PENABLE            (apb_if_inst.penable),
    .PSEL               (apb_if_inst.psel),
    .PADDR              (apb_if_inst.paddr[11:2]),
    .PWDATA             (apb_if_inst.pwdata[31:0]),
    .PWRITE             (apb_if_inst.pwrite),
    
    .WDOGCLK            (wdg_clk),
    .WDOGCLKEN          (1'b1),
    .WDOGRESn           (wdg_rstn),
    .ECOREVNUM          (wdg_if_inst.ecorevnum),
    .PRDATA             (apb_if_inst.prdata),
    .WDOGINT            (wdg_if_inst.wdogint),
    .WDOGRES            (wdg_if_inst.wdogres)
  );


  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import rkv_watchdog_pkg::*;

  apb_if             apb_if_inst(apb_clk, apb_rstn);

  rkv_watchdog_if    wdg_if_inst();
  assign wdg_if_inst.apb_clk = apb_clk;
  assign wdg_if_inst.apb_rstn = apb_rstn;
  assign wdg_if_inst.wdg_clk = wdg_clk;
  assign wdg_if_inst.wdg_rstn = wdg_rstn;

  initial begin : clk_gen
    fork
      forever #5ns  apb_clk <= !apb_clk; //100MHz
      forever #25ns wdg_clk <= !wdg_clk; //20MHz
    join
  end

  initial begin : rstn_gen
    #2ns;
    apb_rstn <= 1;
    #20ns;
    apb_rstn <= 0;
    #20ns;
    apb_rstn <= 1;
  end

  initial begin : vif_assign
    uvm_config_db#(virtual apb_if)::         set(uvm_root::get(), "uvm_test_top.env.apb_mst", "vif", apb_if_inst);
    uvm_config_db#(virtual rkv_watchdog_if)::set(uvm_root::get(), "uvm_test_top",             "vif", wdg_if_inst);
    uvm_config_db#(virtual rkv_watchdog_if)::set(uvm_root::get(), "uvm_test_top.env",         "vif", wdg_if_inst);
    uvm_config_db#(virtual rkv_watchdog_if)::set(uvm_root::get(), "uvm_test_top.env.virt_sqr","vif", wdg_if_inst);
    run_test("");
  end

  assign wdg_rstn = apb_rstn;


endmodule
