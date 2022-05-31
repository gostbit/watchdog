`ifndef RKV_WATCHDOG_LOCK_VIRT_SEQ_SV
`define RKV_WATCHDOG_LOCK_VIRT_SEQ_SV

class rkv_watchdog_lock_virt_seq extends rkv_watchdog_base_virtual_sequence;

  `uvm_object_utils(rkv_watchdog_lock_virt_seq)

  function new (string name = "rkv_watchdog_lock_virt_seq");
    super.new(name);
  endfunction

  task body();
    super.body();
    `uvm_info("body", "Entered...", UVM_LOW)
    //Normal access to REG by default (unlocked status)
    check_wdog_unlocked_control_status();
    rgm.WDOGLOCK.mirror(status);
    compare_data(rgm.WDOGLOCK.WRACC.get(), 1'b0);

    //set locked status
    rgm.WDOGLOCK.write(status, 1'b1 << 1);
    rgm.WDOGLOCK.mirror(status);
    compare_data(rgm.WDOGLOCK.WRACC.get(), 1'b1);
    
    //Check locked status control
    check_wdog_locked_control_status();

    //set unlocked status control
    rgm.WDOGLOCK.write(status, 'h1ACCE551);
    rgm.WDOGLOCK.mirror(status);
    compare_data(rgm.WDOGLOCK.WRACC.get(), 1'b0);
 
    //Check unlocked status control
    check_wdog_unlocked_control_status();


      `uvm_info("body", "Exiting...", UVM_LOW)
  endtask

  task check_wdog_unlocked_control_status();
    rgm.WDOGCONTROL.mirror(status);
    compare_data(rgm.WDOGCONTROL.INTEN.get(), 1'b0);
 
    rgm.WDOGCONTROL.INTEN.set(1'b1);
    rgm.WDOGCONTROL.update(status);
    rgm.WDOGCONTROL.mirror(status);
    compare_data(rgm.WDOGCONTROL.INTEN.get(), 1'b1);

    rgm.WDOGCONTROL.INTEN.set(1'b0);
    rgm.WDOGCONTROL.update(status);
    rgm.WDOGCONTROL.mirror(status);
    compare_data(rgm.WDOGCONTROL.INTEN.get(), 1'b0);
    
    rgm.WDOGCONTROL.INTEN.set(1'b1);
    rgm.WDOGCONTROL.update(status);
    rgm.WDOGCONTROL.mirror(status);
    compare_data(rgm.WDOGCONTROL.INTEN.get(), 1'b1);

  endtask

  task check_wdog_locked_control_status();
    rgm.WDOGCONTROL.mirror(status);
    compare_data(rgm.WDOGCONTROL.INTEN.get(), 1'b1);

    rgm.WDOGCONTROL.INTEN.set(1'b0);
    rgm.WDOGCONTROL.update(status);
    rgm.WDOGCONTROL.mirror(status);
    compare_data(rgm.WDOGCONTROL.INTEN.get(), 1'b1);
  endtask

endclass


`endif //RKV_WATCHDOG_LOCK_VIRT_SEQ_SV
