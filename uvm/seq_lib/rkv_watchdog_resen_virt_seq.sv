`ifndef RKV_WATCHDOG_RESEN_VIRT_SEQ_SV
`define RKV_WATCHDOG_RESEN_VIRT_SEQ_SV

class rkv_watchdog_resen_virt_seq extends rkv_watchdog_base_virtual_sequence;

  `uvm_object_utils(rkv_watchdog_resen_virt_seq)

  function new (string name = "rkv_watchdog_resen_virt_seq");
    super.new(name);
  endfunction

  task body();
    super.body();
    `uvm_info("body", "Entered...", UVM_LOW)
    `uvm_do(reg_enable_intr)
    `uvm_do(reg_enable_reset)
    `uvm_do_with(reg_loadcount, {load_val == 'hFF;})
    //`uvm_do_with(reg_intr_wait_clear, {intval == 50; delay == 1;})
    fork
      wait_intr_signal_assertted();
      wait_intr_signal_released();
    join_none
    `uvm_do(reg_disable_intr)
    `uvm_do(reg_disable_reset)
    #30us;
    `uvm_info("body", "Exiting...", UVM_LOW)
  endtask

endclass


`endif //RKV_WATCHDOG_RESEN_VIRT_SEQ_SV
