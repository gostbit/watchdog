`ifndef RKV_WATCHDOG_REG_ENABLE_INTR_SV
`define RKV_WATCHDOG_REG_ENABLE_INTR_SV

class rkv_watchdog_reg_enable_intr extends rkv_watchdog_base_element_sequence;

  `uvm_object_utils(rkv_watchdog_reg_enable_intr)

  function new (string name = "rkv_watchdog_reg_enable_intr");
    super.new(name);
  endfunction

  task body();
    super.body();
    `uvm_info("body", "Enable reset entered...", UVM_LOW)
    rgm.WDOGCONTROL.INTEN.set(1'b1);
    rgm.WDOGCONTROL.update(status);
    `uvm_info("body", "Enable reset exiting...", UVM_LOW)
  endtask

endclass


`endif //RKV_WATCHDOG_REG_ENABLE_INTR_SV
