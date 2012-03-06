function add_loop_chromo, loop, T0=T0, DEPTH=DEPTH, N_DEPTH=N_DEPTH, $
                          VERSION=VERSION, STARTNAME=STARTNAME,$
                          PERCENT_DIFFERENCE=PERCENT_DIFFERENCE,$
                          CHROMO_MODEL=CHROMO_MODEL, _EXTRA=extra_keywords
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

   strupcase(CHROMO_MODEL) eq 'SINGLE CELL': begin
      loop.chromo_model='Single Cell'
      loop.state=shrec_bcs(loop.state,loop.g, T0, ds2, n_surf)
      pressure=get_loop_pressure(loop)
      loop.P_BC[0]=pressure[0]
      loop.P_BC[1]=pressure[n_surf]
      print, 'SHrEC: Single Chromsphere Cell Set' 
   end

   else: begin
      loop.chromo_model='Single Cell'
      loop.state=shrec_bcs(loop.state,loop.g, T0, ds2, n_surf)
      presure=get_loop_pressure(loop)
      loop.P_BC[0]=presure[0]
      loop.P_BC[1]=presure[n_surf]
      print, 'SHrEC: Single Chromsphere Cell Set <default>' 
   end
   
   
endcase



return, loop

END; Of main
