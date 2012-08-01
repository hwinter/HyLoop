function add_loop_chromo, loop, T0=T0, DEPTH=DEPTH, N_DEPTH=N_DEPTH, $
                          VERSION=VERSION, STARTNAME=STARTNAME,$
                          PERCENT_DIFFERENCE=PERCENT_DIFFERENCE,$
                          CHROMO_MODEL=CHROMO_MODEL,SET_SYSV=SET_SYSV,$
                          _EXTRA=extra_keywords
  Version=2.0
  n_surf=n_elements(loop[0].s)
  n_vol=n_surf-1
  n_vol_w_bc=n_surf+1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;calculate grid spacing
;valid indices run from 0 to is-2 (volume grid), missing ends
  ds1 = loop.s[1:n_surf-1]-loop.s[0:n_surf-2]
;ds1 interpolated onto the s grid, ends extrapolated.
  ds2 = [ds1[0],(ds1[0:n_surf-3] + ds1[1:n_surf-2])/2.0, ds1[n_surf-2]]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  Case 1 of
     size(CHROMO_MODEL, /TYPE) ne 7 :begin
        loop.chromo_model='Single Cell'
        loop.state=shrec_bcs(loop.state,loop.g, T0, ds2, n_surf)
        pressure=get_loop_pressure(loop)
        loop.P_BC[0]=pressure[0]
        loop.P_BC[1]=pressure[n_surf]
        print, 'SHrEC: Single Chromsphere Cell Set <default>'
        

     end
     strupcase(CHROMO_MODEL) eq 'STRATIFIED ATMOSPHERE':  begin
        print, 'SHrEC: Stratified Atmosphere Chromosphere Set'
        loop=add_strat_atmos_chromo( loop, T0=T0, DEPTH=DEPTH, N_DEPTH=N_DEPTH, $
                                     VERSION=VERSION, STARTNAME=STARTNAME,$
                                     PERCENT_DIFFERENCE=PERCENT_DIFFERENCE,$
                                     CHROMO_MODEL=CHROMO_MODEL, _EXTRA=extra_keywords)
        
     end
     
     
     strupcase(CHROMO_MODEL) eq 'CONSTANT CHROMOSPHERE' : begin
        print, 'SHrEC: Constant Chromosphere Set'
     end

     strupcase(CHROMO_MODEL) eq 'SLIDING CHROMOSPHERE': begin
        print, 'SHrEC: Sliding Chromosphere Set'
     end
     
     strupcase(CHROMO_MODEL) eq 'TEST CHROMO': begin
        loop=shrec_test_chromo(loop, T0=T0, DEPTH=DEPTH, N_DEPTH=N_DEPTH, $
                               VERSION=VERSION, STARTNAME=STARTNAME,$
                               PERCENT_DIFFERENCE=PERCENT_DIFFERENCE,$
                               MIN_STEP=MIN_STEP,$
                               SET_SYSV=SET_SYSV, SYSV_NAME=SYSV_NAME)
        print, 'SHrEC: Test Chromo Set' 
     end
     strupcase(CHROMO_MODEL) eq 'T0 APEX P0': begin
        loop=add_constant_t_apex_pressure_chromo(loop, T0=T0, DEPTH=DEPTH, N_DEPTH=N_DEPTH, $
                                                 VERSION=VERSION, STARTNAME=STARTNAME,$
                                                 PERCENT_DIFFERENCE=PERCENT_DIFFERENCE,$
                                                 SET_SYSV=SET_SYSV, SYSV_NAME=SYSV_NAME,$
                                                 _EXTRA=extra_keywords)
        print, 'SHrEC: T0 APEX P0 Set' 
     end
     strupcase(CHROMO_MODEL) eq 'T0 APEX P0 SET DEPTH': begin
        loop=add_constant_t_apex_pressure_chromo_set_depth(loop, T0=T0, DEPTH=DEPTH, N_DEPTH=N_DEPTH, $
                                                           VERSION=VERSION, STARTNAME=STARTNAME,$
                                                           PERCENT_DIFFERENCE=PERCENT_DIFFERENCE,$
                                                           SET_SYSV=SET_SYSV, SYSV_NAME=SYSV_NAME,$
                                                           _EXTRA=extra_keywords)
        print, 'SHrEC: T0 APEX P0 SET DEPTH Set' 
     end
     
     

     else: begin      
        print, 'SHrEC: Single Chromsphere Cell Set <default>' 
        CHROMO_MODEL= 'SINGLE CELL'
        state= shrec_bcs(loop.state,loop.g,T0, ds2, n_surf, N_E0=1d11)
        loop.state=state
        loop.n_depth=1
        loop.depth=depth
        defsysv,'!CHROMO_E_H',[[0],[0]]
        
     end
     
     
  endcase



  return, loop

END                             ; Of main
