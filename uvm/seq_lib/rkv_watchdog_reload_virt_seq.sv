`ifndef RKV_WATCHDOG_RELOAD_VIRT_SEQ_SV
`define RKV_WATCHDOG_RELOAD_VIRT_SEQ_SV

class rkv_watchdog_reload_virt_seq extends rkv_watchdog_base_virtual_sequence;

  `uvm_object_utils(rkv_watchdog_reload_virt_seq)

  function new (string name = "rkv_watchdog_reload_virt_seq");
    super.new(name);
  endfunction

  task body();
    super.body();
    `uvm_info("body", "Reload entered...", UVM_LOW)
    `uvm_do(reg_enable_intr)
    `uvm_do_with(reg_loadcount, {load_val == 'h1;})
    repeat(2) begin
      fork
        `uvm_do_with(reg_intr_wait_clear, {intval == 50; delay inside {[1:10]};})
        wait_intr_signal_released();
      join
    `uvm_do_with(reg_loadcount, {load_val == 'hFFF;})
      end
    `uvm_info("body", "Reload exiting...", UVM_LOW)
  endtask

endclass


`endif //RKV_WATCHDOG_RELOAD_VIRT_SEQ_SV
