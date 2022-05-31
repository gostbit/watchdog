`ifndef RKV_WATCHDOG_DISABLE_INTR_VIRT_SEQ_SV
`define RKV_WATCHDOG_DISABLE_INTR_VIRT_SEQ_SV

class rkv_watchdog_disable_intr_virt_seq extends rkv_watchdog_base_virtual_sequence;

  `uvm_object_utils(rkv_watchdog_disable_intr_virt_seq)

  function new (string name = "rkv_watchdog_disable_intr_virt_seq");
    super.new(name);
  endfunction

  task body();
    super.body();
    `uvm_info("body", "Entered...", UVM_LOW)
    `uvm_do(reg_enable_intr)
    `uvm_do_with(reg_loadcount, {load_val == 'hFF;})
    wait_intr_signal_assertted();
    check_intr_ris_mis(1'b1, 1'b1);
    repeat(20) @(posedge vif.wdg_clk);
    fork
      `uvm_do(reg_disable_intr)
      wait_intr_signal_released();
    join
    check_intr_ris_mis(1'b1, 1'b0);
    #1us;
    //Enable interrupt again to check count reload and interrupt
    `uvm_do(reg_enable_intr)
    //check immediately interrupt is asserted and also the register value
    compare_data(vif.wdogint, 1'b1);
    check_intr_ris_mis(1'b1, 1'b1);
    #1us;
    `uvm_info("body", "Exiting...", UVM_LOW)
  endtask

  //ris: row interrupt 
  //mis: interrupt status
  task check_intr_ris_mis(input bit ris, input bit mis);
    rgm.WDOGRIS.mirror(status);
    compare_data(ris, rgm.WDOGRIS.RAWINT.get());
    rgm.WDOGMIS.mirror(status);
    compare_data(mis, rgm.WDOGMIS.INT.get());
  endtask
endclass


`endif //RKV_WATCHDOG_DISABLE_INTR_VIRT_SEQ_SV
