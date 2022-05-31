`ifndef RKV_WATCHDOG_SCOREBOARD_SV
`define RKV_WATCHDOG_SCOREBOARD_SV

class rkv_watchdog_scoreboard extends rkv_watchdog_subscriber;
   
    bit wdg_inten = 0;
    bit wdg_resen = 0;

    bit [31:0] cur_load;
    bit [31:0] cur_count;

    //events of scoreboard
    uvm_event wdg_disable_loadcount_check_e;

    typedef enum {CHECK_LOADCOUNTER} check_type_e;

  `uvm_component_utils(rkv_watchdog_scoreboard)

  function new (string name = "rkv_watchdog_scoreboard", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    wdg_disable_loadcount_check_e  = _ep.get("wdg_disable_loadcount_check_e");
  endfunction

  task run_phase (uvm_phase phase);
    super.run_phase(phase);
    do_countdown_check();
  endtask

  virtual task do_listen_events();
    fork
      forever begin
        wdg_inten_e.wait_trigger();
        wdg_inten = 1;
      end
      forever begin
        wdg_resen_e.wait_trigger();
        wdg_resen = 1;
      end
      forever begin : wait_wdg_load_thread
        wdg_load_e.wait_trigger();
        wdg_disable_loadcount_check_e.trigger();
        cfg.enable_scb_loadcounter_check = 1;
      end
      forever begin : wait_adg_intrclr_thread
        wdg_intrclr_e.wait_trigger();
        wdg_disable_loadcount_check_e.trigger();
        cfg.enable_scb_loadcounter_check = 1;
      end
    join_none
  endtask

  virtual task do_countdown_check();
    fork
      forever begin 
        wdg_disable_loadcount_check_e.wait_trigger();
        disable do_countdown_check_thread;
      end
      forever begin
        begin : do_countdown_check_thread
          do_loadcounter_check();
        end
      end

    join_none
  endtask

  virtual task do_loadcounter_check(); 
      bit check_enable = get_check_enable(CHECK_LOADCOUNTER);
      bit intr_checked = 0;
      bit res_check = 0;
      forever begin
        //front APB clock to WDOG clock sunc
        @(posedge vif.wdg_clk iff check_enable);
        cur_load = rgm.WDOGLOAD.LOADVAL.get();
        cur_count = cur_load;
        do begin
          @(posedge vif.wdg_clk);
          cur_count--;
        end while (cur_count != 0);
        wdg_intr_assert_e.trigger();
        //from logic timing after count reach zero
        repeat(2) @(negedge vif.wdg_clk);
        if(!res_check) begin  //do not check once reset check is done
          if(!intr_checked || !wdg_resen) begin 
            if(vif.wdogint != 1'b1) begin
            cfg.scb_check_error++;
            `uvm_error("CNTDWNCHECK", "WDOGINT signal should be asserted!")
            end
            intr_checked = 1;
          end
          else begin
            if(vif.wdogres != 1'b1) begin
              cfg.scb_check_error++;
              `uvm_error("CNTDWNCHECK", "WDOGRES signal should be asserted!")
            end
            res_check = 1;
          end
        cfg.scb_check_count++;
        end
        end
  endtask

  virtual function bit get_check_enable(check_type_e typ);
    case(typ)
      CHECK_LOADCOUNTER : return cfg.enable_scb && cfg.enable_scb_loadcounter_check && wdg_inten;
      default: return 0;
    endcase
  endfunction

endclass

`endif //RKV_WATCHDOG_SCOREBOARD_SV
