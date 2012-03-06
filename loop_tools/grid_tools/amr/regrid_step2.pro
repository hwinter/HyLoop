;+
; NAME:
;	REGRID_STEP2
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
;    Use at your own risk.  However, it performs well in tests
	
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


PRO regrid_step2, loop, $
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
                 WINDOW=WINDOW

;redistribute grid by picking minimum step 
;
;Set so that () is for functions and [] is for array indices  
compile_opt strictarr
old_except=!except
!except=2
original_loop=!MSULoop_loop
n_s_orig=n_elements(original_loop.s)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Set keywords
if NOT  keyword_set(GRID_SAFETY) THEN GRID_SAFETY=2d1
if NOT keyword_set(PERCENT_DIFFERENCE) then PERCENT_DIFFERENCE=1./3.
if keyword_set(infile) then restore,infile

if keyword_set(showme) then begin

    if (!d.name eq 'X' and not keyword_set(WINDOW)) then begin
        window=!d.window
        print , 'Regrid Window=',window
    endif 
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
dv_old=get_loop_vol(original_loop[0],TOTAL=old_volume_total)
n_vol_old=n_elements(dv_old)
;Get the number of particles in each cell excluding the ends
particles_old=dv_old*original_loop[0].state.n_e[1:n_vol_old]
;Total number of particles in the loop.  (electrons and protons)
n_part_old=2d0*total(particles_old)
;Total thermal energy in the loop
energy_total_old=total(dv_old*original_loop[0].state.e[1:n_vol_old])

dv_old=get_loop_vol(old_loop[0],TOTAL=old_volume_total)
n_vol_old=n_elements(dv_old)
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
e=interpol(old_loop.state.e,s_alt,$
           old_loop.s,LSQUADRATIC=LSQUADRATIC,$
           QUADRATIC=QUADRATIC,SPLINE=SPLINE)
n_e=interpol(old_loop.state.n_e,s_alt,$
             old_loop.s,LSQUADRATIC=LSQUADRATIC,$
             QUADRATIC=QUADRATIC,SPLINE=SPLINE)
v=old_loop.state.v


b=old_loop.b
a=old_loop.a

t=get_loop_temp(old_loop)
t=interpol(t,s_alt,old_loop.s,LSQUADRATIC=LSQUADRATIC,$
             QUADRATIC=QUADRATIC,SPLINE=SPLINE)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Define Characteristic length scales
;cls=characteristic length scale
;If you find any zeroes, make them a small number so that you don't
;end up dividing by zero
;Energy
e_cls=get_loop_e_cls(old_loop,/S_GRID,/SMOOTH)
;Density
n_e_cls=get_loop_n_e_cls(old_loop,/S_GRID,/SMOOTH)
;Temperature
T_cls=get_loop_temp_cls(old_loop,/S_GRID);,/SMOOTH)
;Yes. I know that temperature is just a function of 
;density and energy but I'm doing it anyway!
;Velocity
v_cls=get_loop_v_cls(old_loop,/S_GRID,/SMOOTH,/SOUND)
;Magnetic field
b_cls=get_loop_b_cls(old_loop,/S_GRID,/SMOOTH)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;For each x find the smallest characteristic length scale
;Can this be done without the loop?
min_cls=dblarr(n_s)

colors=dblarr(n_s)
for i=0l, n_s-1L do begin
    min_cls[i]=min([e_cls[i],$
                    n_e_cls[i],$
                    v_cls[i],$
                    b_cls[i],$
                    t_cls[i]])
if keyword_set(showme) then begin
    case 1 of
        (min_cls[i] eq e_cls[i]):colors[i]=color_index[1]
        (min_cls[i] eq n_e_cls[i]):colors[i]=color_index[2]
        (min_cls[i] eq v_cls[i]):colors[i]=color_index[3]
        (min_cls[i] eq b_cls[i]):colors[i]=color_index[4]
        (min_cls[i] eq t_cls[i]):colors[i]=color_index[0]
    endcase
endif
        
    endfor
 min_cls>=min_step
min_cls=temporary(min_cls)/grid_safety
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Smooth the minimum clses to avoid perturbations at the TR that 
; can make the step size so small that the stepper never climbs out.
;A boxcar width of 3 simulates Gaussian smoothing.
for i=0, 10 do min_cls=smooth(min_cls,3)


legend_titles=['E','N_e','V','B', 'T']
max_loop_s=max(original_loop.s)
min_loop_s=min(original_loop.s)
d_cls=deriv(min_cls) 

for j=0, 10 do min_cls=smooth(min_cls,3)  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Adjust the grid
;First s position is always 0
;Take the first step
new_s=[0d0,min_cls[1]]
done=0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;So step through until we hit the end of the loop
;index=0
minimum_step=min(min_cls)

step_arr=0d
while done ne 1 do begin
;Number of elements in the new_s array
    n_new_s=n_elements(new_s)
;Calculate the size of the last step
    d_step=abs(new_s[n_new_s-1UL]-new_s[n_new_s-2UL])

 ;   s_index=where(abs(old_loop.s-new_s[n_new_s-1UL]) eq $
 ;                 min(abs(old_loop.s-new_s[n_new_s-1UL])))

    step=interpol(min_cls,old_loop.s,$
                   new_s[n_new_s-1UL],LSQUADRATIC=LSQUADRATIC,$
             QUADRATIC=QUADRATIC,SPLINE=SPLINE);/GRID_SAFETY
    ;step=min_cls[s_index]
;What is the difference between this step and the last step.    
    delta=step-d_step
;What is the percent difference between this step and the last step
    pd=abs((delta)/d_step)

    if pd gt PERCENT_DIFFERENCE then begin
        case 1 of 
;If the new step is bigger than allowed then make the step size the 
; largest allowed.
            delta gt 0 :step=(1d0+PERCENT_DIFFERENCE)*d_step
;If the new step is smaller than allowed then make the step size the 
; minimum allowed.
            delta le 0 :step=(PERCENT_DIFFERENCE)*d_step
            else: step=step
        endcase
    endif
    step=abs(step)
    step >= minimum_step 
    step >=  min_step 

    if keyword_set(MAX_STEP) then step <=MAX_STEP
    temp_s=new_s[n_new_s-1UL]+step
    if temp_s ge max_loop_s then begin
        temp_s=max_loop_s
        done=1
    end

    new_s=[new_s,temp_s]
    ;help, new_s
    ;pmm,new_s
    ;print, "Step "+string(step)
    step_arr=[step_arr,step]
    ;index+=1
    if step le 0 then stop
    if d_step le 0 then stop

    
endwhile
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Now repeat but backwards!
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
goto, skip_point
new_s2=[old_loop.s[n_s-1], old_loop.s[n_s-1]-min_cls[n_s-2]]
done=0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;So step through until we hit the beginning of the loop
;index=0
step_arr2=0d
while done ne 1 do begin
;Number of elements in the new_s array
    n_new_s=n_elements(new_s2)
;Calculate the size of the last step
    d_step2=abs(new_s2[n_new_s-1UL]-new_s2[n_new_s-2UL])

;Where are we?
;    s_index=where(abs(old_loop.s-new_s[n_new_s-1UL]) eq $
;                  min(abs(old_loop.s-new_s[n_new_s-1UL])))

    step=interpol(min_cls,old_loop.s,$
                  old_loop.s[n_s-1]- new_s2[n_new_s-1UL],$
                  LSQUADRATIC=LSQUADRATIC,$
                  QUADRATIC=QUADRATIC,SPLINE=SPLINE)$
         /GRID_SAFETY
    ;step=min_cls[s_index]

;What is the difference between this step and the last step.    
    delta=step-d_step
;What is the percent difference between this step and the last step
    pd=abs((delta)/d_step)

 ;   if pd gt PERCENT_DIFFERENCE then begin
 ;       case 1 of 
;If the new step is bigger than allowed then make the step size the 
; largest allowed.
;            delta gt 0 :step=(1d0+PERCENT_DIFFERENCE)*d_step
;If the new step is smaller than allowed then make the step size the 
; minimum allowed.
;            delta le 0 :step=(PERCENT_DIIFERENCE)*d_step
;            else: step=step
;        endcase
;    endif
    step=abs(step)
    step >= minimum_step 
    step >=  min_step 
    
    temp_s=new_s2[n_new_s-1UL]-step

    if temp_s le min_loop_s then begin
        temp_s=min_loop_s
        done=1
    end

    new_s2=[new_s2,temp_s]
    ;help, new_s
    ;pmm,new_s
    ;print, "Step "+string(step)
    step_arr2=[step_arr2,step]
    ;index+=1
    if step le 0 then stop
    if d_step le 0 then stop

    
endwhile
step_arr2=reverse(step_arr2)
new_s2=reverse(new_s2)
skip_point:
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
;Now I use linear interpolation as the default.
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
;Now I use linear interpolation as the default.
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
                               LSQUADRATIC=1,$;LSQUADRATIC,$
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
                               LSQUADRATIC=1,$;LSQUADRATIC,$
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
                                    LSQUADRATIC=1,$;LSQUADRATIC,$
                                    QUADRATIC=QUADRATIC,SPLINE=SPLINE)
;Fix the endpoints
new_axis_y[0]=original_loop.axis[1,0]
new_axis_y[num_new_s-1l]=original_loop.axis[1,n_s_orig-1l]

new_axis_z=dblarr(num_new_s)
new_axis_z[1:num_new_s-2l]=interpol(original_loop.axis[2,*],$
                                    original_loop.s,$
                                    new_s[1:num_new_s-2l],$
                                    LSQUADRATIC=1,$;LSQUADRATIC,$
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
if new_momentum eq 0. and old_momentum eq 0. then $
  MOMENTUM_PD=0 else $
  MOMENTUM_PD=abs(MOMENTUM_CHANGE)/abs(new_momentum)

;Change in volume before and after regrid
VOLUME_CHANGE=old_volume_total-new_volume_total
;Percent Difference in momentum before and after regrid
VOLUME_PD=abs(VOLUME_CHANGE)/new_volume_total

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Testing procedures to plot new values over old
if keyword_set(showme) then begin
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;find midpoint along loop
    midpt =old_loop.l/2.0 
    if !d.name eq 'X' then window,window, XS=14000, YSIZE=900, $
           TITLE='Regrid Window'
    old_p_state=!p.multi
    old_chars=!p.charsize
    old_chart=!p.charthick
    !p.charsize=2
    !p.charthick=1.5
    !p.multi=[0,3,2]
                                ;old_margin=!p.margin
;
    ;multiplot, [3,2]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Plot 1
    plot,old_loop.s,deriv(old_loop.s),$
         title='old & new step vs s ',$
         XTITLE='s [cm]',$
         YTITLE='[cm]',$
         YRANGE=[min([old_loop.s, new_s]),$
                 max([old_loop.s,new_s])*1.1]
    oplot,[midpt, midpt],[-1d32, 1d34]
    
    TVLCT, newRed, newGreen, newBlue
    
    for i=0l, n_s-1l do begin
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
    ;multiplot
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;plot 2
    plot,old_loop.s,old_ds, title='old s & min CLS',$
         XTITLE='s [cm]',$
         YTITLE='[cm]',$
         YRANGE=[min([old_ds,min_cls ]),$
                 max([old_ds,min_cls])*1.1]
    oplot,[midpt, midpt],[-1d32, 1d34]
    TVLCT, newRed, newGreen, newBlue
    for i=0l, n_elements(old_loop.s)-1l do begin
        plots,old_loop.s[i], min_cls[i] , psym=1, color=colors[i]
    endfor
    legend,legend_titles,  PSYM=[1,1,1,1,1],$
           /HORIZONTAL,$
           COLORS=[color_index[1],color_index[2],$
                   color_index[3],color_index[4],$
                   color_index[0]],$
           CHARSIZE=.7*!p.charsize
    tvlct, red, green, blue
    oplot,old_ds
    ;multiplot
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;plot 3
    plot,old_loop.s, old_ds,TITLE="Old & new ds" ,$
          XTITLE='s [cm]',$
         YTITLE='[cm]',$
         YRANGE=[min([min(old_ds),min(ds)]),$
                  max([max(old_ds),max(ds)])]
    oplot,[midpt, midpt],[-1d32, 1d34]
    oplot,new_s, ds,COLOR=128,LINESTYLE=2, thick=2
    TVLCT, newRed, newGreen, newBlue
    ;multiplot
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Plot 4
    plot,new_s, ds,TITLE="ds & min cls" ,$
          XTITLE='s [cm]',$
         YTITLE='[cm]',$
         YRANGE=[min([min(n_min_cls),min(ds)]),$
                 max([max(n_min_cls),max(ds)])]
    oplot,[midpt, midpt],[-1d32, 1d34]
    plots,0, ds[0] , psym=3, color=colors[0]
    for i=1l, n_s-1l do begin
        plots,new_s[i], ds[i] , $
              color=colors2[i],/CONTINUE
        plots,new_s[i], ds[i] , $
              color=colors2[i],PSYM=1
        
    endfor
    
    for i=0l, n_elements(new_s)-1l do begin
        plots,new_s[i], n_min_cls[i] , psym=5, color=colors2[i]
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
    
    
    
    ;pmm, (old_ds-ds)
    ;pmm, (old_loop.s-new_s)
    !p.multi=old_p_state
    !p.charsize=old_chars
    !p.charthick=old_chart
    ;multiplot, /RESET
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
print, check_math()
END




