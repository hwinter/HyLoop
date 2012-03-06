
;+
; NAME:
;	interpolate_loop.pro
;
; PURPOSE:
;	To take many loop structures from many save files 
;          with different grid spacings and re-interpolate
;          them on a standard grid.
;
; CATEGORY:
;	
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
;	
;
; RESTRICTIONS:
;	
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

function interpolate_loop, old_loop, loop_template,S_GRID=S_GRID

if ((size(loop_template,/TYPE) eq 0) and (size(S_GRID,/TYPE) eq 0)) then begin
    Print, 'interpolate_loop.pro requires either an input loop' $
           +' structure or a grid to map upon.' 
    new_loop=-1
    goto, end_jump
endif


if not keyword_set(S_GRID) then S_GRID=loop_template.s
new_s_alt=msu_get_s_alt(S_GRID)    
num_new_s_alt=n_elements(new_s_alt)
num_new_s=n_elements(S_GRID)
N_VOL_OLD=n_elements(old_loop.s_alt)
n_s=n_elements(old_loop.s)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Spline volume quantities to the new grid
;Energy
new_e=dblarr(num_new_s_alt)
;Used to use spline 
;Now I use linear interpolation as the default.
new_e=spline(old_loop.s_alt,old_loop.state.e, $
             new_s_alt,/DOUBLE)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;Now I use linear interpolation as the default. 
new_n_e=spline( old_loop.s_alt,old_loop.state.n_e,$
               new_s_alt,/DOUBLE)

;Energy input
new_e_h=dblarr(num_new_s_alt-2l)
new_e_h[1:num_new_s_alt-4l]=spline(old_loop.s_alt[1:N_VOL_OLD-2],$
                                   old_loop.e_h, $ 
                                   new_s_alt[1:num_new_s_alt-4L],$
                                   /DOUBLE)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Interpolate surface  quantities to the new grid
;Velocity
new_v=dblarr(num_new_s)
new_v[1:num_new_s-2l]=spline(old_loop.s, $
                             old_loop.state.v, $
                             S_GRID[1:num_new_s-2l],$
                             /DOUBLE)
;Fix the endpoints
new_v[0]=old_loop.state.v[0]
new_v[num_new_s-1l]=old_loop.state.v[n_s-1l]

;Area
new_A=dblarr(num_new_s)
new_A[1:num_new_s-2l]=spline(old_loop.s,$
                             old_loop.a,$
                             S_GRID[1:num_new_s-2l],$
                             /DOUBLE)
;Fix the endpoints
new_A[0]=old_loop.A[0]
new_A[num_new_s-1l]=old_loop.A[n_s-1l]

;Radius
new_rad=sqrt(new_A/!dpi)

;Gravitational acceleration along the loop axis
new_g=dblarr(num_new_s)
new_g[1:num_new_s-2l]=spline(old_loop.s,$
                             old_loop.g,$
                             S_GRID[1:num_new_s-2l],$
                             /DOUBLE)
;Fix the endpoints
new_g[0]=old_loop.g[0]
new_g[num_new_s-1l]=old_loop.g[n_s-1l]

;Magnetic field strength
new_b=dblarr(num_new_s)
new_b[1:num_new_s-2l]=spline(old_loop.s,$
                             old_loop.b,$
                             S_GRID[1:num_new_s-2l],$
                             /DOUBLE)
;Fix the endpoints
new_b[0]=old_loop.b[0]
new_b[num_new_s-1l]=old_loop.b[n_s-1l]

;Axis coordinates
new_axis_x=dblarr(num_new_s)
new_axis_x[1:num_new_s-2l]=spline(old_loop.s,$
                                  old_loop.axis[0,*],$
                                  S_GRID[1:num_new_s-2l],$
                                  /DOUBLE)
new_axis_x[0]=old_loop.axis[0,0]
new_axis_x[num_new_s-1l]=old_loop.axis[0,n_s-1l]

new_axis_y=dblarr(num_new_s)
new_axis_y[1:num_new_s-2l]=spline(old_loop.s,$
                                  old_loop.axis[1,*],$
                                  S_GRID[1:num_new_s-2l],$
                                  /DOUBLE)
;Fix the endpoints
new_axis_y[0]=old_loop.axis[1,0]
new_axis_y[num_new_s-1l]=old_loop.axis[1,n_s-1l]

new_axis_z=dblarr(num_new_s)
new_axis_z[1:num_new_s-2l]=spline( old_loop.s,$
                                   old_loop.axis[2,*],$
                                   S_GRID[1:num_new_s-2l],$
                                   /DOUBLE)
;Fix the endpoints
new_axis_z[0]=old_loop.axis[2,0]
new_axis_z[num_new_s-1l]=old_loop.axis[2,n_s-2l]

new_axis=dblarr(3,num_new_s)
new_axis[0,*]=new_axis_x
new_axis[1,*]=new_axis_y
new_axis[2,*]=new_axis_z
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Make a new state structure.
new_state={e:new_e, n_e:new_n_e, v:new_v, time:old_loop.state.time}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Make a loop structure.
n_depth=where(S_GRID-old_loop.s[old_loop.n_depth] eq $
              min(S_GRID-old_loop.s[old_loop.n_depth]))

new_loop=mk_loop_struct(STATE=new_state, $
                              S_array=S_GRID,$
                              B=new_b,$
                              G=new_g,$
                              AXIS=new_axis, $
                              AREA=new_A,$
                              RAD=new_rad, $
                              E_H=new_e_h,$
                              T_MAX=old_loop.t_max,$
                              N_DEPTH=old_loop.n_depth,$
                              NOTES=old_loop.notes,$
                              DEPTH=old_loop.DEPTH,$
                              start_file=old_loop.start_file)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Ensure that energy is conserved
;old_energy=

;dv=get_loop_vol(new_loop[0],TOTAL=new_volume_total)
;n_vol=n_elements(dv)


end_jump:
return, new_loop
END
