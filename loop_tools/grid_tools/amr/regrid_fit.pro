;+
; NAME:
;	REGRID_STEP3
;
; PURPOSE:
;	Regrid a loop structure based on Characteristic Length Scales
;
; CATEGORY:
;	Loop tools
;
; CALLING SEQUENCE:
;	
;
; INPUTS:
;	
;
; OPTIONAL INPUTS:
;	
;	
; KEYWORD PARAMETERS:
;	
;
; OUTPUTS:
;	
;
; OPTIONAL OUTPUTS:
;	
;
; COMMON BLOCKS:
;	
;
; SIDE EFFECTS:
;	The tags of the loop structure will have a 
;       different number of elements than before.
;
; RESTRICTIONS:
;    Not fully vectorized
;    No exlicit effort is made here to conserve mass, momentum or energy!  
;    Use at your own risk,.  However it performs well in tests
	
;
; PROCEDURE:
;	
;
; EXAMPLE:
;	
;
; MODIFICATION HISTORY:
; 	Written by:
;-


function regrid_step3, loop, $
                 infile=infile, outfile=outfile,showme=showme,$
                 nosave=nosave,GRID_SAFETY=GRID_SAFETY, $
                 PERCENT_DIFFERENCE=PERCENT_DIFFERENCE, $
                 NEW_LOOP=NEW_LOOP, MAX_STEP=MAX_STEP, $
                 QUADRATIC=QUADRATIC, LSQUADRATIC=LSQUADRATIC, $
                 SPLINE=SPLINE,$
                 ENERGY_PD=ENERGY_PD, PARTICLE_PD=PARTICLE_PD, $
                 MOMENTUM_PD=MOMENTUM_PD, VOLUME_PD=VOLUME_PD, $
                 ENERGY_CHANGE=ENERGY_CHANGE, $
                 MOMENTUM_CHANGE=MOMENTUM_CHANGE, $
                 VOLUME_CHANGE=VOLUME_CHANGE, $
                 WINDOW=WINDOW, CHROMO=CHROMO

;redistribute grid by picking minimum step 
;
;Set so that () is for functions and [] is for array indices  
compile_opt strictarr
old_except=!except
!except=2
;original_loop=!MSULoop_loop
loop_counter=100
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Set keywords
if NOT  keyword_set(GRID_SAFETY) THEN GRID_SAFETY=10d
if NOT  keyword_set(PERCENT_DIFFERENCE) then PERCENT_DIFFERENCE=.1d
if NOT  keyword_set(MAX_STEP) THEN MAX_STEP=1D8 ;100km
if NOT  keyword_set(MIN_STEP) THEN MIN_STEP=3D4 ;300m
if keyword_set(infile) then restore,infile

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
for big_counter=0ul, loop_counter do begin
    old_loop=loop
;Determine the loop center.
    center=old_loop.l/2d

    ds=get_loop_min_cls(old_loop,center ,grid_safety )
    
    ds_0=(ds/2d)
    rhs_surface=center-ds_0
    lhs_surface=center+ds_0
    
    done=0
    counter=0UL
    ds_array=ds
    while not done do begin  
        ds_0=get_loop_min_cls(old_loop,rhs_surface[counter] ,grid_safety )
        PD_test=(ds_0-ds)/ds
        if ds_0 gt max_step THEN ds_0=max_step
        if ds_0 lt min_step THEN ds_0=min_step
        
        case 1 of
            (abs(PD_test) gt PERCENT_DIFFERENCE and PD_test lt 0): $
              ds_0=ds*PERCENT_DIFFERENCE
            (abs(PD_test) gt PERCENT_DIFFERENCE and PD_test gt 0): $
              ds_0=ds/PERCENT_DIFFERENCE
            else:
        endcase
        
        new_surf=rhs_surface[counter]-ds_0
        if new_surf lt 0d then begin
            new_surf=0d
            ds_0=rhs_surface[counter]-new_surf
            done=1
        endif
        
        rhs_surface=[rhs_surface,new_surf ]
        ds_array=[ds_array, ds_0]
        ds=ds_0
        counter+=1UL
    endwhile
    
    
    lhs_surface=lhs_surface[0]+total((ds_array),/CUMULATIVE)
    
    new_s=[reverse(rhs_surface),lhs_surface]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Section to reinterpolate quantities on the new loop grid.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;If the new and old loop are different lengths then rescale so that 
;they match
    max_s=max(new_s)
    if max_s ne max_loop_s then $
      new_s=max_loop_s*new_s/max_s
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Adjust the volume grid
;I was getting segmentation faults when I tried to put the 
;  reinterpolated quantities directly into the structure tags.
;  This seems to work.  I use a variable called new_q for the 
;  the reinterpolated quantity.  This keeps memory use down.
 
    new_s_alt=msu_get_s_alt(new_s)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    num_new_s=n_elements(new_s)
    num_new_s_alt=n_elements(new_s_alt)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Spline volume quantities to the new grid
;Energy
    new_e=dblarr(num_new_s_alt)
;Used to use spline 
;Now I use linear interpolation. There are less "stray" points.
    new_e=interpol( old_loop.state.e,old_loop.s_alt, $
                    new_s_alt,LSQUADRATIC=LSQUADRATIC,$
                    QUADRATIC=QUADRATIC,SPLINE=SPLINE)
;new_e[1:num_new_s_alt-2l]=interpol( old_loop.state.e,old_loop.s_alt, $
;             new_s_alt[1:num_new_s_alt-2l],LSQUADRATIC=LSQUADRATIC,$
;             QUADRATIC=QUADRATIC,SPLINE=SPLINE)
;new_e[1:num_new_s_alt-2l]=SPLINE( old_loop.s_alt,old_loop.state.e, $
;                                  new_s_alt[1:num_new_s_alt-2l],$
;                                  spline_tension,$
;                                  /DOUBLE)

;Fix the endpoints
    new_e[0]=old_loop.state.e[0]
    new_e[num_new_s_alt-1l]=old_loop.state.e[n_s_alt-1l]

;Density
    new_n_e=dblarr(num_new_s_alt)
;Used to use spline 
;Now I use linear interpolation. There are less "stray" points..
    new_n_e=interpol( old_loop.state.n_e,old_loop.s_alt,$
                      new_s_alt,LSQUADRATIC=LSQUADRATIC,$
                      QUADRATIC=QUADRATIC,SPLINE=SPLINE)
;new_n_e[1:num_new_s_alt-2l]=interpol( old_loop.state.n_e,old_loop.s_alt,$
;               new_s_alt[1:num_new_s_alt-2l],LSQUADRATIC=LSQUADRATIC,$
;             QUADRATIC=QUADRATIC,SPLINE=SPLINE)

;Fix the endpoints
    new_n_e[0]=old_loop.state.n_e[0]
    new_n_e[num_new_s_alt-1l]=old_loop.state.n_e[n_s_alt-1l]
    
;Energy input
    new_e_h=dblarr(num_new_s_alt-2l)
    new_e_h[1:num_new_s_alt-4l]=$
      interpol(old_loop.e_h, $
               old_loop.s_alt[1:N_VOL_OLD],$
               new_s_alt[1:num_new_s_alt-4L],$
               LSQUADRATIC=LSQUADRATIC,$
               QUADRATIC=QUADRATIC,SPLINE=SPLINE)
    new_e_h[0]=old_loop.e_h[0]
    new_e_h[num_new_s_alt-3l]=old_loop.e_h[n_elements(old_loop.s_alt)-3l]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Interpolate surface  quantities to the new grid
;Velocity
    new_v=dblarr(num_new_s)
    new_v[1:num_new_s-2l]=interpol(old_loop.state.v, $
                                   old_loop.s, $
                                   new_s[1:num_new_s-2l],$
                                   LSQUADRATIC=LSQUADRATIC,$
                                   QUADRATIC=QUADRATIC,SPLINE=SPLINE)
;Fix the endpoints
    new_v[0]=old_loop.state.v[0]
    new_v[num_new_s-1l]=old_loop.state.v[n_s-1l]
    
;Area
    new_A=dblarr(num_new_s)
    new_A[1:num_new_s-2l]=interpol(original_loop.a,$
                                   original_loop.s,$
                                   new_s[1:num_new_s-2l],$
                                   LSQUADRATIC=1,$ ;LSQUADRATIC,$
                                   QUADRATIC=QUADRATIC,SPLINE=SPLINE)
;Fix the endpoints
    new_A[0]=original_loop.A[0]
    new_A[num_new_s-1l]=original_loop.A[n_s_orig-1l]

;Radius
    new_rad=sqrt(new_A/!dpi)

;Gravitational acceleration along the loop axis
    new_g=dblarr(num_new_s)
    new_g[1:num_new_s-2l]=interpol(original_loop.g,$
                               original_loop.s,$
                                   new_s[1:num_new_s-2l],$
                                   LSQUADRATIC=1,$ ;LSQUADRATIC,$
                                   QUADRATIC=QUADRATIC,SPLINE=SPLINE)
;Fix the endpoints
    new_g[0]=original_loop.g[0]
    new_g[num_new_s-1l]=original_loop.g[n_s_orig-1l]
    
;Magnetic field strength
    new_b=dblarr(num_new_s)
    new_b[1:num_new_s-2l]=interpol(original_loop.b,$
                               original_loop.s,$
                               new_s[1:num_new_s-2l],$
                               LSQUADRATIC=1,$;LSQUADRATIC,$
                               QUADRATIC=QUADRATIC,SPLINE=SPLINE)
;Fix the endpoints
    new_b[0]=original_loop.b[0]
    new_b[num_new_s-1l]=original_loop.b[n_s_orig-1l]

;Axis coordinates
    new_axis_x=dblarr(num_new_s)
    new_axis_x[1:num_new_s-2l]=interpol(original_loop.axis[0,*],$
                                    original_loop.s,$
                                    new_s[1:num_new_s-2l],$
                                    LSQUADRATIC=1,$;LSQUADRATIC,$
                                    QUADRATIC=QUADRATIC,SPLINE=SPLINE)
    new_axis_x[0]=original_loop.axis[0,0]
    new_axis_x[num_new_s-1l]=original_loop.axis[0,n_s_orig-1l]
    
    new_axis_y=dblarr(num_new_s)
    new_axis_y[1:num_new_s-2l]=interpol(original_loop.axis[1,*],$
                                        original_loop.s,$
                                        new_s[1:num_new_s-2l],$
                                        LSQUADRATIC=1,$ ;LSQUADRATIC,$
                                        QUADRATIC=QUADRATIC,SPLINE=SPLINE)
;Fix the endpoints
    new_axis_y[0]=original_loop.axis[1,0]
    new_axis_y[num_new_s-1l]=original_loop.axis[1,n_s_orig-1l]
    
    new_axis_z=dblarr(num_new_s)
    new_axis_z[1:num_new_s-2l]=interpol(original_loop.axis[2,*],$
                                        original_loop.s,$
                                        new_s[1:num_new_s-2l],$
                                        LSQUADRATIC=1,$ ;LSQUADRATIC,$
                                        QUADRATIC=QUADRATIC,SPLINE=SPLINE)
;Fix the endpoints
    new_axis_z[0]=original_loop.axis[2,0]
    new_axis_z[num_new_s-1l]=original_loop.axis[2,n_s_orig-2l]
    
    new_axis=dblarr(3,num_new_s)
    new_axis[0,*]=new_axis_x
    new_axis[1,*]=new_axis_y
    new_axis[2,*]=new_axis_z
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Make a new state structure.
    new_state={e:new_e, n_e:new_n_e, v:new_v, time:old_loop.state.time}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Make a loop structure.
    n_depth=where(new_s-old_loop.s[old_loop.n_depth] eq $
                  min(new_s-old_loop.s[old_loop.n_depth]))
    
    regridded_loop=mk_loop_struct(STATE=new_state, $
                                  S_array=new_s,$
                                  B=new_b,$
                                  G=new_g,$
                                  AXIS=new_axis, $
                                  AREA=new_A,$
                                  RAD=new_rad, $
                                  E_H=new_e_h,$
                                  T_MAX=old_loop.t_max,$
                                  N_DEPTH=n_depth,$
                                  NOTES=old_loop.notes,$
                                  DEPTH=old_loop.DEPTH,$
                                  start_file=old_loop.start_file)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Section to reinterpolate quantities on the new loop grid.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    new_loop=regridded_loop
    loop=regridded_loop
endfor

return, loop

END



