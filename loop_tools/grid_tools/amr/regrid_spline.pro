;+
; NAME:
;	
;
; PURPOSE:
;	
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
;    Not fully vectorized	
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

function regrid_spline, loop, $
             infile=infile, outfile=outfile,$
             showme=showme, nosave=nosave, OLD_LOOP=OLD_LOOP


;redistribute grid by picking minimum step 
;
;No effort is made here to conserve mass, momentum or energy!  
;Use at your own risk.  
;UPDATE - 04/01/2003 Removed unknown stops HDWIII
old_except=!except
;!except=2

if keyword_set(infile) then restore,infile
N_loops=n_elements(loop)
new_loop=loop[N_loops-1l]
old_loop=new_loop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dv=get_loop_vol(loop[0],TOTAL=old_volume_total)
n_vol=n_elements(dv)
n_part_old=total(dv*loop[0].state.n_e[1:n_vol-1l])
energy_total_old=total(dv*loop[0].state.e[1:n_vol-1l])
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Find the number of volume elements
n_v=n_elements(loop.state.e) ;
;Find the number of surface elements
n_s=n_elements(loop.s)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Define the length along the loop within the volume elements
 s_alt =get_loop_s_alt(loop,/gt0)
 old_ds=get_loop_ds(loop)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Spline all values to the surface grid
e=spline(s_alt,loop.state.e,loop.s)
n_e=spline(s_alt,loop.state.n_e,loop.s)
v=loop.state.v
b=loop.b
a=loop.a
t=get_loop_temp(loop)
t=spline(s_alt,t,loop.s)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Define Characteristic length scales
;cls=characteristic length scale
cls=[ $ 
;Energy
     [get_loop_e_cls(loop,/vol_GRID)], $  
;Density  
     [get_loop_n_e_cls(loop,/vol_GRID)], $
;Temperature
;Yes. I know that temperature is just a function of 
;density and energy but I'm doing it anyway!
     [get_loop_temp_cls(loop,/vol_GRID)], $ ;
;Velocity
     [get_loop_v_cls(loop,/vol_GRID)], $ 
;Magnetic field
     [get_loop_b_cls(loop,/vol_GRID)]]

min_cls=abs(min(cls,DIM=2))
min_cls=min_cls[1:n_v-2]
min_cls=min_cls[loop.n_depth-1:n_v-loop.n_depth-2]
for j=0, 10 do min_cls=smooth(min_cls,10) 

s_insert=loop.s[loop.n_depth-1]+$
         total((min_cls/total(min_cls))*(LOOP.S[n_v-loop.n_depth-1] $
                                         -LOOP.S[loop.n_depth-1]),/CUMULATIVE)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

new_loop.s[loop.n_depth+1:n_v-loop.n_depth]=s_insert
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Adjust the volume grid
;I was getting segmentation faults when I tried to put the 
;  reinterpolated quantities directly into the structure tags.
;  This seems to work.  I use a variable called new_q for the 
 ;  the reinterpolated quantity.  This keeps memory use down.
 
s_alt2=get_loop_s_alt(new_loop)
new_loop.s_alt=s_alt2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Spline volume quantities to the new grid
;Energy
new_q=spline(loop.s_alt, loop.state.e, new_loop.s_alt)
new_loop.state.e=new_q
;print, 'Did energy'

;Density
new_q=spline(loop.s_alt, loop.state.n_e, new_loop.s_alt)
new_loop.state.n_e=new_q
;print, 'Did n_e'

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Spline surface  quantities to the new grid
;Velocity
new_q=spline(loop.s, loop.state.v, new_loop.s)
new_loop.state.v=new_q

;Area
new_q=spline(loop.s, loop.a, new_loop.s)
new_loop.A=new_q

;Radius
new_q=spline(loop.s, loop.rad, new_loop.s)
new_loop.rad=new_q

;Gravitational acceleration along the loop axis
new_q=spline(loop.s, loop.g, new_loop.s)
new_loop.g=new_q

;Magnetic field strength
new_q=spline(loop.s, loop.b, new_loop.s)
new_loop.b=new_q

;Axis coordinates
new_q=spline(loop.s, loop.axis[0,*], new_loop.s)
new_loop.axis[0,*]=new_q
new_q=spline(loop.s, loop.axis[1,*], new_loop.s)
new_loop.axis[1,*]=new_q
new_q=spline(loop.s, loop.axis[2,*], new_loop.s)
new_loop.axis[2,*]=new_q

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Ensure that energy is conserved
;dv=get_loop_vol(new_loop[0],TOTAL=new_volume_total)
;n_vol=n_elements(dv)

;energy_total_new=total(dv*loop.state.e[1:n_vol-2l])
;if energy_total_new ne energy_total_old then begin
;    factor=total(energy_total_old)/total(energy_total_new)
;    loop.state.e[1:n_vol-2l]=loop.state.e[1:n_vol-2l]*factor
;    ;

;    energy_total_new=total(dv*loop.state.e[1:n_vol-2l])
;    endif

;n_part_new=total(dv*new_loop.state.n_e[1:n_vol-2l])

;while not done do begin
old_loop=loop
!except=old_except
return, new_loop
;stop
END



