
`ifndef RKV_WATCHDOG_CONFIG_SV
`define RKV_WATCHDOG_CONFIG_SV

class rkv_watchdog_config extends uvm_object;

  int seq_check_count;
  int seq_check_error;

  int scb_check_count;
  int scb_check_error;
  
  bit enable_cov = 1;
  bit enable_scb = 1;
  bit enable_scb_loadcounter_check = 0;

  apb_config apb_cfg;
  virtual rkv_watchdog_if vif;
  rkv_watchdog_rgm rgm;

  `uvm_object_utils(rkv_watchdog_config)

  // USER to specify the config items
  
  function new (string name = "rkv_watchdog_config");
    super.new(name);
    apb_cfg = apb_config::type_id::create("apb_cfg");
  endfunction : new


endclass

`endif // RKV_WATCHDOG_CONFIG_SV
