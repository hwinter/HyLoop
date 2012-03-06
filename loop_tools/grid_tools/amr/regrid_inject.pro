;+
; NAME:
;	REGRID_STEP
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
;          Replaced all of the spline commands with interpol.  Spline,
;           as I should have remembered, can often give wild answers where
;           the gradients are steep.  A linear interpolation is good enough
;           and "should" always yields reasonable answers.
;-

PRO regrid_inject, loop, $
                 infile=infile, outfile=outfile,showme=showme,$
                 nosave=nosave,GRID_SAFETY=GRID_SAFETY, $
                 PERCENT_DIIFERENCE=PERCENT_DIIFERENCE, $
                 NEW_LOOP=NEW_LOOP, MAX_STEP=MAX_STEP, $
                 QUADRATIC=QUADRATIC, LSQUADRATIC=LSQUADRATIC, $
                 SPLINE=SPLINE,$
                 ENERGY_PD=ENERGY_PD, PARTICLE_PD=PARTICLE_PD, $
                 MOMENTUM_PD=MOMENTUM_PD, VOLUME_PD=VOLUME_PD, $
                 ENERGY_CHANGE=ENERGY_CHANGE, $
                 MOMENTUM_CHANGE=MOMENTUM_CHANGE, $
                 VOLUME_CHANGE=VOLUME_CHANGE

;redistribute grid by picking minimum step 
;
;Set so that () is for functions and [] is for array indices  
compile_opt strictarr
old_except=!except

!except=2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Set keywords
if NOT  keyword_set(GRID_SAFETY) THEN GRID_SAFETY=5d0
if NOT keyword_set(PERCENT_DIIFERENCE) then PERCENT_DIIFERENCE=1./3.
if keyword_set(infile) then restore,infile

if keyword_set(showme) then begin
;Color definition taken straight from the IDL
; help TVLCT description
;Define the colors for a new color table:
    colorLevel = [[0, 0, 0], $     ; black  
                  [255, 0, 0], $   ; red  
                  [255, 255, 0], $ ; yellow  
                  [0, 255, 0], $   ; green  
                  [0, 255, 255], $ ; cyan  
                  [0, 0, 255], $   ; blue  
                  [255, 0, 255], $ ; magenta  
                  [255, 255, 255]] ; white  
;Create a new color table that contains eight levels,
; including the highest end boundary by first deriving 
; levels for each color in the new color table:
    
    numberOfLevels = CEIL(!D.TABLE_SIZE/8.)  
    level = INDGEN(!D.TABLE_SIZE)/numberOfLevels  
    
;Place each color level into its appropriate range.
    newRed = colorLevel[0, level]  
    newGreen = colorLevel[1, level]  
    newBlue = colorLevel[2, level]  
    
;Include the last color in the last level:
    newRed[!D.TABLE_SIZE - 1] = 255  
    newGreen[!D.TABLE_SIZE - 1] = 255  
    newBlue[!D.TABLE_SIZE - 1] = 255    
    
    color_index=[40,$              ; red     
                 80, $             ; yellow  
                 120, $            ; green  
                 140, $            ; cyan  
                 190, $            ; blue  
                 215, $            ; magenta  
                 255]              ; white   
;Make the new color table current:    
;TVLCT, newRed, newGreen, newBlue
    tvlct, red, green, blue, /GET
endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Define Constants
spline_tension=0.1
min_step=1d+3
mp = 1.67e-24 ;proton mass (g)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
N_loops=n_elements(loop)
old_loop=loop[N_loops-1l]

counter=0
restart_point:
counter+=1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dv_old=get_loop_vol(old_loop[0],TOTAL=old_volume_total)
n_vol_old=n_elements(dv_old)
;Get the number of particles in each cell excluding the ends
particles_old=dv_old*old_loop[0].state.n_e[1:n_vol_old]
;Total number of particles in the loop.  (electrons and protons)
n_part_old=2d0*total(particles_old)
;Total thermal energy in the loop
energy_total_old=total(dv_old*old_loop[0].state.e[1:n_vol_old])
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Find the number of surface elements
n_s=n_elements(old_loop.s)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Define the length along the loop within the volume elements
s_alt =get_loop_s_alt(old_loop,/gt0)
n_s_alt=n_elements(s_alt)

old_ds=deriv(old_loop.s)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Interpolate all values to the surface grid
;No longer necessary
;e=interpol(old_loop.state.e,s_alt,$
;           old_loop.s,LSQUADRATIC=LSQUADRATIC,$
;           QUADRATIC=QUADRATIC,SPLINE=SPLINE)
;n_e=interpol(old_loop.state.n_e,s_alt,$
;             old_loop.s,LSQUADRATIC=LSQUADRATIC,$
;             QUADRATIC=QUADRATIC,SPLINE=SPLINE)
;v=old_loop.state.v
;b=old_loop.b
;a=old_loop.a
;t=get_loop_temp(old_loop)
;t=interpol(t,s_alt,old_loop.s,LSQUADRATIC=LSQUADRATIC,$
;             QUADRATIC=QUADRATIC,SPLINE=SPLINE)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Define Characteristic length scales
;cls=characteristic length scale
;If you find any zeroes, make them a small number so that you don't
;end up dividing by zero
;Define on the Volume grid and ignore the endcaps.

;Energy
e_cls=get_loop_e_cls(old_loop,/VOL_GRID,$
                     /SMOOTH,/NO_ENDS)
;Density
n_e_cls=get_loop_n_e_cls(old_loop,/VOL_GRID,$
                     /SMOOTH,/NO_ENDS)
;Temperature
T_cls=get_loop_temp_cls(old_loop,/VOL_GRID, $
                     /SMOOTH,/NO_ENDS)
;Yes. I know that temperature is just a function of 
;density and energy but I'm doing it anyway!
;Velocity
v_cls=get_loop_v_cls(old_loop,/VOL_GRID,$
                     /SMOOTH,/NO_ENDS)
;Magnetic field
b_cls=get_loop_b_cls(old_loop,/VOL_GRID,$
                     /SMOOTH,/NO_ENDS)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;For each x find the smallest characteristic length scale
;Can this be done without the loop?
min_cls=e_cls< n_e_cls < v_cls $
        <b_cls < t_cls
n_cls=n_elements(min_cls)

if keyword_set(showme) then begin
    for i=0l, n_cls-1L do begin
        colors=dblarr(n_cls)
        case 1 of
            (min_cls[i] eq e_cls[i]):colors[i]=color_index[1]
            (min_cls[i] eq n_e_cls[i]):colors[i]=color_index[2]
            (min_cls[i] eq v_cls[i]):colors[i]=color_index[3]
            (min_cls[i] eq b_cls[i]):colors[i]=color_index[4]
            (min_cls[i] eq t_cls[i]):colors[i]=color_index[0]
            
        endcase
    endfor
    
endif
        
if keyword_set(MAX_STEP) then min_cls<=MAX_STEP
 min_cls>=min_step
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Smooth the minimum clses to avoid perturbations at the TR that 
; can make the step size so small that the stepper never climbs out.
;A boxcar width of 3 simulates Gaussian smoothing.
;for i=0, 10 do min_cls=smooth(min_cls,3)

max_loop_s=max(old_loop.s)
min_loop_s=min(old_loop.s)
d_cls=deriv(min_cls) 

for j=0, 10 do min_cls=smooth(min_cls,3)  
;Go ahead and divide by the safety.  Saves multiple calculations later on.
min_cls=temporary(min_cls)/GRID_SAFETY
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Adjust the grid
;First s position is always 0
;Take the first step
step=old_loop.s[1:n_s-1]-old_loop.s[0:n_s-2] 
new_s=-1
change_index1=where(STEP gt MIN_CLS[0:n_s-2])
if change_index1[0] ne -1 then begin
;Will eventually make this a matrix operation   
    ii=n_elements(change_index1)-1ul
    for i =0ul, ii-1 do begin
        delta=old_loop.s[change_index1[i]+1] $
              -old_loop.s[change_index1[i]]
        steps=dblarr(fix(delta/MIN_CLS[change_index1[i]]))$
              +MIN_CLS[change_index1[i]+1]
        new_s=[new_s, old_loop.s[change_index1[i]]+ $
                total(steps,/CUMULATIVE)]
       ; stop
    endfor

endif  

change_index2=where(STEP lt MIN_CLS[0:n_s-2])
if change_index1[0] ne -1 then begin
;Will eventually make this a matrix operation   
    ii=n_elements(change_index1)-1
    for i =0ul, ii-1 do begin
        delta=old_loop.s[change_index1[i]+1] $
              -old_loop.s[change_index1[i]]
        steps=dblarr(fix(delta/MIN_CLS[change_index1[i]]))$
              +MIN_CLS[change_index1[i]+1]
        new_s=[new_s, old_loop.s[change_index1[i]]+ $
                total(steps,/CUMULATIVE)]
        ;stop
    endfor

endif  
same_index=where(STEP eq MIN_CLS[0:n_s-2])
;stop 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
;new_e[0]=old_loop.state.e[0]
;new_e[num_new_s_alt-1l]=old_loop.state.e[n_s_alt-1l]

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

;new_n_e[0]=old_loop.state.n_e[0]
;new_n_e[num_new_s_alt-1l]=old_loop.state.n_e[n_s_alt-1l]

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
;Interpolate surfac e  quantities to the new grid
;Velocity
new_v=dblarr(num_new_s)
new_v[1:num_new_s-2l]=interpol(old_loop.state.v, $
                               old_loop.s, $
                               new_s[1:num_new_s-2l],$
                               LSQUADRATIC=LSQUADRATIC,$
                               QUADRATIC=QUADRATIC,SPLINE=SPLINE)
new_v[0]=old_loop.state.v[0]
new_v[num_new_s-1l]=old_loop.state.v[n_s-1l]

;Area
new_A=dblarr(num_new_s)
new_A[1:num_new_s-2l]=interpol(old_loop.a,$
                               old_loop.s,$
                               new_s[1:num_new_s-2l],$
                               LSQUADRATIC=LSQUADRATIC,$
                               QUADRATIC=QUADRATIC,SPLINE=SPLINE)
new_A[0]=old_loop.A[0]
new_A[num_new_s-1l]=old_loop.A[n_s-1l]

;Radius
new_rad=dblarr(num_new_s)
new_rad[1:num_new_s-2l]=interpol(old_loop.rad,$
                              old_loop.s,$
                              new_s[1:num_new_s-2l],$
                                 LSQUADRATIC=LSQUADRATIC,$
                                 QUADRATIC=QUADRATIC,SPLINE=SPLINE)
new_rad[0]=old_loop.rad[0]
new_rad[num_new_s-1l]=old_loop.rad[n_s-1l]

;Gravitational acceleration along the loop axis
new_g=dblarr(num_new_s)
new_g[1:num_new_s-2l]=interpol(old_loop.g,$
                               old_loop.s,$
                               new_s[1:num_new_s-2l],$
                               LSQUADRATIC=LSQUADRATIC,$
                               QUADRATIC=QUADRATIC,SPLINE=SPLINE)
new_g[0]=old_loop.g[0]
new_g[num_new_s-1l]=old_loop.g[n_s-1l]

;Magnetic field strength
new_b=dblarr(num_new_s)
new_b[1:num_new_s-2l]=interpol(old_loop.b,$
                               old_loop.s,$
                               new_s[1:num_new_s-2l],$
                               LSQUADRATIC=LSQUADRATIC,$
                               QUADRATIC=QUADRATIC,SPLINE=SPLINE)
new_b[0]=old_loop.b[0]
new_b[num_new_s-1l]=old_loop.b[n_s-1l]

;Axis coordinates
new_axis_x=dblarr(num_new_s)
new_axis_x[1:num_new_s-2l]=interpol(old_loop.axis[0,*],$
                                    old_loop.s,$
                                    new_s[1:num_new_s-2l],$
                                    LSQUADRATIC=LSQUADRATIC,$
                                    QUADRATIC=QUADRATIC,SPLINE=SPLINE)
new_axis_x[0]=old_loop.axis[0,0]
new_axis_x[num_new_s-1l]=old_loop.axis[0,n_s-1l]

new_axis_y=dblarr(num_new_s)
new_axis_y[1:num_new_s-2l]=interpol(old_loop.axis[1,*],$
                                    old_loop.s,$
                                    new_s[1:num_new_s-2l],$
                                    LSQUADRATIC=LSQUADRATIC,$
                                    QUADRATIC=QUADRATIC,SPLINE=SPLINE)
new_axis_y[0]=old_loop.axis[1,0]
new_axis_y[num_new_s-1l]=old_loop.axis[1,n_s-1l]

new_axis_z=dblarr(num_new_s)
new_axis_z[1:num_new_s-2l]=interpol(old_loop.axis[2,*],$
                                    old_loop.s,$
                                    new_s[1:num_new_s-2l],$
                                    LSQUADRATIC=LSQUADRATIC,$
                                    QUADRATIC=QUADRATIC,SPLINE=SPLINE)
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
n_depth=where(new_s-old_loop.s[old_loop.n_depth] eq $
              min(new_s-old_loop.s[old_loop.n_depth]))

regridded_loop=mk_loop_struct(new_state,new_s,new_b,$
                        new_g,new_axis, new_A,new_rad, $
                        new_e_h,old_loop.t_max,$
                        n_depth,$
                        old_loop.notes,$
                        DEPTH=old_loop.DEPTH,$
                        start_file=old_loop.start_file)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Ensure that energy is conserved
dv=get_loop_vol(regridded_loop[0],TOTAL=new_volume_total)
n_vol=n_elements(dv)

energy_total_new=total(dv*regridded_loop.state.e[1:n_vol])
;if energy_total_new ne energy_total_old then begin
;    factor=total(energy_total_old)/energy_total_new
;    regridded_loop.state.e[1:n_vol]=regridded_loop.state.e[1:n_vol]*factor    
;    energy_total_new=total(dv*loop.state.e[1:n_vol])
;    endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Ensure that particle number is conserved
;Get the number of particles in each cell excluding the ends
particles_new=dv*regridded_loop[0].state.n_e[1:n_vol]
;Total number of particles in the loop.  (electrons and protons)
n_part_new=2d0*total(particles_new)
;if  n_part_new ne n_part_old then begin
factor=total(n_part_old)/n_part_old
    ;regridded_loop.state.n_e[1:n_vol]=regridded_loop.state.n_e[1:n_vol]*factor
;endif

    ds=deriv(regridded_loop.s)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
;Re-calculate the CLSes
    colors2=dblarr(num_new_s)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Spline all values to the surface grid
    s_alt=get_loop_s_alt(regridded_loop)

    e=spline(s_alt,regridded_loop.state.e,regridded_loop.s,spline_tension,  $
             /DOUBLE)
    n_e=spline(s_alt,regridded_loop.state.n_e,regridded_loop.s,spline_tension,$
               /DOUBLE)
    v=regridded_loop.state.v
    b=regridded_loop.b
    a=regridded_loop.a
    t=get_loop_temp(regridded_loop)
    t=spline(s_alt,t,regridded_loop.s,spline_tension,$
        /DOUBLE)

;Energy
    e_cls=get_loop_e_cls(regridded_loop,/S_GRID,/SMOOTH)
;Density
    n_e_cls=get_loop_n_e_cls(regridded_loop,/S_GRID,/SMOOTH)

;Temperature
;Yes. I know that temperature is just a function of 
;density and energy but I'm doing it anyway!
    T_cls=get_loop_temp_cls(regridded_loop,/S_GRID) ;,/SMOOTH)
;Velocity
    v_cls=get_loop_v_cls(regridded_loop,/S_GRID,/SMOOTH)
;Magnetic field
    b_cls=get_loop_b_cls(regridded_loop,/S_GRID,/SMOOTH)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
    n_s=n_elements(regridded_loop.s)
    n_min_cls=dblarr(n_s)
    for i=0l, n_s-1L do begin
        n_min_cls[i]=min([e_cls[i],$
                          n_e_cls[i],$
                          v_cls[i],$
                          b_cls[i],$
                          t_cls[i]])
        
        if keyword_set(showme) then begin      
            if (n_min_cls[i] lt ds[i]) then $
              colors2[i]=color_index[0]  else $
              colors2[i]=color_index[2]
        
            if (n_min_cls[i] gt 4d0*ds[i]) then colors2[i]=color_index[3]
        endif

    
    endfor
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Conserved quantities (ideally, i.e. in real physics)
;Change in particle number before and after regrid
PARTICLE_CHANGE=n_part_old-n_part_new
;Particle number Percent Difference
PARTICLE_PD=abs(PARTICLE_CHANGE)/n_part_new
;Chnage in energy before and after regrid
ENERGY_CHANGE=energy_total_old-energy_total_new
;Percent Difference in energy before and after regrid
ENERGY_PD=abs(ENERGY_CHANGE)/energy_total_new

;Change in momentum before and after regrid
old_v_on_vol_grid=interpol(old_loop.state.v, old_loop.s,$
                           old_loop.s_alt[1:n_elements(old_loop.s_alt)-2ul],$
                           LSQUADRATIC=LSQUADRATIC,$
                           QUADRATIC=QUADRATIC,SPLINE=SPLINE)
NEW_v_on_vol_grid=interpol(regridded_loop.state.v, regridded_loop.s,$
                           regridded_loop.s_alt[1:n_vol],$
                           LSQUADRATIC=LSQUADRATIC,$
                           QUADRATIC=QUADRATIC,SPLINE=SPLINE)
old_momentum=total(particles_old*mp*old_v_on_vol_grid)
new_momentum=total(particles_new *mp*NEW_v_on_vol_grid)

MOMENTUM_CHANGE=new_momentum-old_momentum
;Percent Difference in momentum before and after regrid
MOMENTUM_PD=abs(MOMENTUM_CHANGE)/abs(new_momentum)

;Change in volume before and after regrid
VOLUME_CHANGE=old_volume_total-new_volume_total
;Percent Difference in momentum before and after regrid
VOLUME_PD=abs(VOLUME_CHANGE)/new_volume_total

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Testing procedures to plot new values over old
if keyword_set(showme) then begin
    legend_titles=['E','N_e','V','B', 'T']
    window,!d.window, XS=14000, YSIZE=900, $
           TITLE='Regrid Window'
    old_p_state=!p.multi
    old_chars=!p.charsize
    old_chart=!p.charthick
    !p.charsize=2
    !p.charthick=1.5
    !p.multi=[0,3,2]
                                ;old_margin=!p.margin
;
    
    plot,old_loop.s,deriv(old_loop.s),$
         title='old & new step vs s ',$
         XTITLE='Index #',$
         YTITLE='[cm]',$
         YRANGE=[min([old_loop.s, new_s]),$
                 max([old_loop.s,new_s])*1.1]
    
    TVLCT, newRed, newGreen, newBlue
    
    for i=0l, n_elements(new_s)-1l do begin
        plots,new_s[i],ds[i], PSYM=1, COLOR=colors2[i]
    endfor
    
    legend,legend_titles, PSYM=[1,1,1,1,1],$
           /HORIZONTAL,$
           COLORS=[color_index[1],color_index[2],$
                   color_index[3],color_index[4],$
                   color_index[0]],$
           CHARSIZE=.7*!p.charsize
    tvlct, red, green, blue
    oplot, old_loop.s
    
    plot,old_ds, title='old s & min CLS',$
         XTITLE='Index #',$
         YTITLE='[cm]',$
         YRANGE=[min([old_ds,min_cls ]),$
                 max([old_ds,min_cls])*1.1]
    TVLCT, newRed, newGreen, newBlue
    for i=0l, n_elements(n_s)-1l do begin
        plots,i, min_cls[i] , psym=1, color=colors[i]
    endfor
    legend,legend_titles,  PSYM=[1,1,1,1,1],$
           /HORIZONTAL,$
           COLORS=[color_index[1],color_index[2],$
                   color_index[3],color_index[4],$
                   color_index[0]],$
           CHARSIZE=.7*!p.charsize
    tvlct, red, green, blue
    oplot,old_ds
    
    plot, old_ds,TITLE="Old & new ds" ,$
          XTITLE='Index #',$
          YTITLE='[cm]'
    oplot, ds,COLOR=128,LINESTYLE=2, thick=2
    y_range=[min([min(n_min_cls),min(ds)]),$
             1.1*max([max(n_min_cls),max(ds)])]
    TVLCT, newRed, newGreen, newBlue
    plot, ds,TITLE="ds & min cls" ,$
          XTITLE='Index #',$
          YTITLE='[cm]',yrange=y_range
    
    plots,0, ds[0] , psym=3, color=colors[0]
    for i=1l, n_elements(new_s)-1l do begin
        plots,i, ds[i] , $
              color=colors2[i],/CONTINUE
        plots,i, ds[i] , $
              color=colors2[i],PSYM=1
        
    endfor
    
    for i=0l, n_elements(new_s)-1l do begin
        plots,i, n_min_cls[i] , psym=5, color=colors2[i]
    endfor
    oplot, ds,color=255
    oplot, n_min_cls,linestyle=2,color=255
    legend,['CLS < ds','CLS > ds','CLS > 4*ds'],  PSYM=[2,2,2],$
           /HORIZONTAL,$
           COLORS=[color_index[0],color_index[2],$
                   color_index[3]],$
           CHARSIZE=.7*!p.charsize
    
    
    tvlct, red, green, blue
    
    xyouts, 390+70, 340, $
            'Change in particle number:'+string(PARTICLE_CHANGE), $
            /DEVICE, CHARSIZE=1.3, CHARTHICK=1.2
    
    xyouts, 390+70, 310, $
            'Change in particle number fractional difference:',$
            /DEVICE, CHARSIZE=1.3, CHARTHICK=1.2
    
    xyouts, 410+70, 295, $
            string(PARTICLE_PD), $
            /DEVICE, CHARSIZE=1.3, CHARTHICK=1.2
    
    xyouts, 390+70, 265, $
            'Change in energy:'+string(ENERGY_CHANGE), $
            /DEVICE, CHARSIZE=1.3, CHARTHICK=1.2
    
    xyouts, 390+70, 235, $
            'Change in energy fractional difference:', $
            /DEVICE, CHARSIZE=1.3, CHARTHICK=1.2
    
    xyouts, 410+70, 220, $
            string(ENERGY_PD), $
            /DEVICE, CHARSIZE=1.3, CHARTHICK=1.2
    
    xyouts, 390+70, 190, $
            'Change in volume:'+string(VOLUME_CHANGE), $
            /DEVICE, CHARSIZE=1.3, CHARTHICK=1.2
    
    xyouts, 390+70, 160, $
            'Change in volume fractional difference:',$
            /DEVICE, CHARSIZE=1.3, CHARTHICK=1.2

    xyouts, 410+70, 145, $
            string(VOLUME_PD), $
            /DEVICE, CHARSIZE=1.3, CHARTHICK=1.2
    
    xyouts, 390+70, 115, $
            'Momentum Change: '+strcompress(string(MOMENTUM_CHANGE),/REMOVE_ALL) $
            +' [g cm s!E-1!N]',$
            /DEVICE, CHARSIZE=1.3, CHARTHICK=1.2
    
    xyouts, 390+70, 95, $
            'Change in momentum fractional difference:',$
            /DEVICE, CHARSIZE=1.3, CHARTHICK=1.2
    
    xyouts, 410+70, 80, $
            strcompress(string(MOMENTUM_PD),/REMOVE_ALL), $
            /DEVICE, CHARSIZE=1.3, CHARTHICK=1.2
    
    xyouts, 390+70, 50, $
            'Min/Max ds: '+strcompress(string(min(ds)),/REMOVE_ALL)+'/' $
            +strcompress(string(max(ds)),/REMOVE_ALL)+' [cm]',$
            /DEVICE, CHARSIZE=1.3, CHARTHICK=1.2
    
    
    
    pmm, (old_ds-ds)
    pmm, (old_loop.s-new_s)
    !p.multi=old_p_state
    !p.charsize=old_chars
    !p.charthick=old_chart
endif
;while not done do begin
;loop[N_loops-1l]=regridded_loop
!except=old_except
bad_points = where(n_min_cls le ds)

;if ((bad_points[0] ne -1 ) and (counter lt 100)) $
;  then goto , restart_point


if not keyword_set(NEW_LOOP) then begin
    loop=regridded_loop
    endif
;stop
END



