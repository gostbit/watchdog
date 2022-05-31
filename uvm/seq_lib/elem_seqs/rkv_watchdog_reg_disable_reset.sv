`ifndef RKV_WATCHDOG_REG_DISABLE_RESET_SV
`define RKV_WATCHDOG_REG_DISABLE_RESET_SV

class rkv_watchdog_reg_disable_reset extends rkv_watchdog_base_element_sequence;

  `uvm_object_utils(rkv_watchdog_reg_disable_reset)

  function new (string name = "rkv_watchdog_reg_disable_reset");
    super.new(name);
  endfunction

  task body();
    super.body();
    `uvm_info("body", "disable reset entered...", UVM_LOW)
    rgm.WDOGCONTROL.RESEN.set(1'b0);
    rgm.WDOGCONTROL.update(status);
    `uvm_info("body", "disable reset exiting...", UVM_LOW)
  endtask

endclass


`endif //RKV_WATCHDOG_REG_DISABLE_RESET_SV
