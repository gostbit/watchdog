`ifndef RKV_WATCHDOG_COV_SV
`define RKV_WATCHDOG_COV_SV

class rkv_watchdog_cov extends rkv_watchdog_subscriber;

  bit[31:0] reg_field_val;
  event     wdg_regacc_sve;
  event     wdg_load_sve;
  event     wdg_intrclr_sve;
  `uvm_component_utils(rkv_watchdog_cov)

  // Covergroup definition below
  // T1 Watchdog overall control
  // T1.1 Interrupt enable & disable (0->1 , 1->0)
  // T1.2 Reset enable & disable (0->1, 1->0)
  covergroup  rkv_wdg_t1_overall_control_cg (ref bit [31:0] val) @(wdg_regacc_sve);
    option.name = "T1 Watchdog overall control";
    INTEN : coverpoint val[0] {
      bins stat_en    = {1'b1};
      bins stat_dis   = {1'b0};
      bins to_enable  = (1'b0 => 1'b1);
      bins to_disable = (1'b1 => 1'b0);
    }
    RESEN : coverpoint val[1] {
      bins stat_en    = {1'b1};
      bins stat_dis   = {1'b0};
      bins to_enable  = (1'b0 => 1'b1);
      bins to_disable = (1'b1 => 1'b0);
    }
  endgroup

  // T2 Watchdog load & reload
  // T2.1 Initial load (counter 0 -> load value)
  // T2.2 Reloaded (load valule 1 -> load value 2)
  // T2.3 Load value range (min value, max value and others)
  covergroup rkv_wdg_t2_load_reload_cg (ref bit [31:0] val) @(wdg_load_sve);
    option.name = "T2 Watchdog load & reload";
    RELOAD      : coverpoint val {
      bins reload = ([1:32'hFFFFFFFF] => [1:32'hFFFFFFFF]);
    }
    LOADRANGE   : coverpoint val {
      bins min = {32'h1};
      bins max = {32'hFFF};
      bins others = {[32'h2 : 32'hFFFFFFE]};
    }
  endgroup

  // T3 Watchdog intrclr
  covergroup rkv_wdg_t3_intrclr_cg;
    option.name = "T3 Watchdog intrclr";
    CLR     : coverpoint vif.wdogint {
      bins intr = {1};
      bins disintr = {0};
      bins clr = (1 => 0);
    } 
  endgroup

  function new (string name = "rkv_watchdog_cov", uvm_component parent);
    super.new(name, parent);
    rkv_wdg_t1_overall_control_cg = new(this.reg_field_val);
    rkv_wdg_t2_load_reload_cg     = new(this.reg_field_val);
    rkv_wdg_t3_intrclr_cg         = new();
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  task run_phase (uvm_phase phase);
    super.run_phase(phase);
    do_intrclr_sample();
  endtask

  task do_listen_events();
    uvm_object tmp;
    uvm_reg r;
    fork
      forever begin
        wait(cfg.enable_cov);
        wdg_regacc_e.wait_trigger_data(tmp);
        void'($cast(r, tmp));
        if(r.get_name() == "WDOGCONTROL") begin
          reg_field_val  = rgm.WDOGCONTROL.get();
          ->wdg_regacc_sve;
        end
        else if(r.get_name() == "WDOGLOAD") begin
          reg_field_val  = rgm.WDOGLOAD.get();
          ->wdg_load_sve;
        end
        else begin
          reg_field_val  = 0;
        end

        // TODO:: other branches
      end
    join_none
  endtask

  task do_intrclr_sample();
      forever begin
        @(posedge vif.apb_clk iff vif.apb_rstn);
        if(vif.wdogint == 1)
          #2ns;
          this.rkv_wdg_t3_intrclr_cg.sample();
      end
  endtask


endclass

`endif 

