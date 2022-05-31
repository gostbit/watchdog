`ifndef RKV_WATCHDOG_BASE_ELEMENT_SEQUENCE_SV
`define RKV_WATCHDOG_BASE_ELEMENT_SEQUENCE_SV


class rkv_watchdog_base_element_sequence extends uvm_sequence;

  rkv_watchdog_config cfg;
  virtual rkv_watchdog_if vif;
  rkv_watchdog_rgm rgm;
  bit[31:0] wr_val, rd_val;
  uvm_status_e status;

  `uvm_object_utils(rkv_watchdog_base_element_sequence)
  `uvm_declare_p_sequencer(rkv_watchdog_virtual_sequencer)

  function new (string name = "rkv_watchdog_base_element_sequence");
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info("body", "Entered...", UVM_LOW)
    //TODO in sub_class
    cfg = p_sequencer.cfg;
    vif = cfg.vif;
    rgm = cfg.rgm;
    `uvm_info("body", "Exiting...", UVM_LOW)
  endtask

  virtual function void compare_data(logic[31:0] val1, logic[31:0] val2);
    cfg.seq_check_count++;
    if(val1 === val2)
      `uvm_info("CMPSUC", $sformatf("val1 'h%0x === val2 'h%0x", val1, val2), UVM_LOW)
    else begin
      cfg.seq_check_error++;
      `uvm_info("CMPSUC", $sformatf("val1 'h%0x !== val2 'h%0x", val1, val2), UVM_LOW)
    end
  endfunction

endclass


`endif //RKV_WATCHDOG_BASE_ELEMENT_SEQUENCE_SV
