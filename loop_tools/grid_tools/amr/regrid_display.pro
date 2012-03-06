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

pro regrid_display, old_loop, new_loop

new_s=new_loop.s
old_ds=get_loop_ds(old_loop)
ds=get_loop_ds(new_loop)
min_cls=get_loop_min_cls(old_loop)
N_min_cls=get_loop_min_cls(new_loop)
num_new_s=n_elements(new_s)
;
mp = 1.67e-24 ;proton mass (g)
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

;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Ensure that energy is conserved
dv=get_loop_vol(new_loop[0],TOTAL=new_volume_total)
n_vol=n_elements(dv)

energy_total_new=total(dv*new_loop.state.e[1:n_vol])
;if energy_total_new ne energy_total_old then begin
;    factor=total(energy_total_old)/energy_total_new
;    new_loop.state.e[1:n_vol]=new_loop.state.e[1:n_vol]*factor    
;    energy_total_new=total(dv*loop.state.e[1:n_vol])
;    endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Ensure that particle number is conserved
;Get the number of particles in each cell excluding the ends
particles_new=dv*new_loop[0].state.n_e[1:n_vol]
;Total number of particles in the loop.  (electrons and protons)
n_part_new=2d0*total(particles_new)
;if  n_part_new ne n_part_old then begin
factor=total(n_part_old)/n_part_old
    ;new_loop.state.n_e[1:n_vol]=new_loop.state.n_e[1:n_vol]*factor
;endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;Change in momentum before and after regrid
old_v_on_vol_grid=interpol(old_loop.state.v, old_loop.s,$
                           old_loop.s_alt[1:n_elements(old_loop.s_alt)-2ul],$
                           LSQUADRATIC=LSQUADRATIC,$
                           QUADRATIC=QUADRATIC,SPLINE=SPLINE)
NEW_v_on_vol_grid=interpol(new_loop.state.v, new_loop.s,$
                           new_loop.s_alt[1:n_vol],$
                           LSQUADRATIC=LSQUADRATIC,$
                           QUADRATIC=QUADRATIC,SPLINE=SPLINE)
old_momentum=total(particles_old*mp*old_v_on_vol_grid)
new_momentum=total(particles_new *mp*NEW_v_on_vol_grid)

MOMENTUM_CHANGE=new_momentum-old_momentum
;Percent Difference in momentum before and after regrid
MOMENTUM_PD=abs(MOMENTUM_CHANGE)/abs(new_momentum)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


legend_titles=['E','N_e','V','B', 'T']
;Color definition taken straight from the IDL
; help TVLCT description
;Define the colors for a new color table:
colorLevel = [[0, 0, 0], $         ; black  
              [255, 0, 0], $       ; red  
              [255, 255, 0], $     ; yellow  
              [0, 255, 0], $       ; green  
              [0, 255, 255], $     ; cyan  
              [0, 0, 255], $       ; blue  
              [255, 0, 255], $     ; magenta  
              [255, 255, 255]]     ; white  
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
  
    
color_index=[40,$                  ; red     
             80, $                 ; yellow  
             120, $                ; green  
             140, $                ; cyan  
             190, $                ; blue  
             215, $                ; magenta  
             255]                  ; white   
;Make the new color table current:    
;TVLCT, newRed, newGreen, newBlue
tvlct, red, green, blue, /GET


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


;For each x find the smallest characteristic length scale
;Can this be done without the loop?
min_cls=e_cls< n_e_cls < v_cls $
        <b_cls < t_cls
n_cls=n_elements(min_cls)


    for i=0l, n_cls-1uL do begin
        colors=dblarr(n_cls)
        case 1 of
            (min_cls[i] eq e_cls[i]):colors[i]=color_index[1]
            (min_cls[i] eq n_e_cls[i]):colors[i]=color_index[2]
            (min_cls[i] eq v_cls[i]):colors[i]=color_index[3]
            (min_cls[i] eq b_cls[i]):colors[i]=color_index[4]
            (min_cls[i] eq t_cls[i]):colors[i]=color_index[0]
            
        endcase
    endfor

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
;Re-calculate the CLSes
    colors2=dblarr(num_new_s)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Spline all values to the surface grid

    s_alt=get_loop_s_alt(new_loop)

    e=new_loop.state.e
    n_e=new_loop.state.N_e
    v=new_loop.state.v
    b=new_loop.b
    a=new_loop.a
    t=get_loop_temp(new_loop)
    

;Energy
    e_cls=get_loop_e_cls(new_loop,/S_GRID,/SMOOTH)
;Density
    n_e_cls=get_loop_n_e_cls(new_loop,/S_GRID,/SMOOTH)

;Temperature
;Yes. I know that temperature is just a function of 
;density and energy but I'm doing it anyway!
    T_cls=get_loop_temp_cls(new_loop,/S_GRID) ;,/SMOOTH)
;Velocity
    v_cls=get_loop_v_cls(new_loop,/S_GRID,/SMOOTH)
;Magnetic field
    b_cls=get_loop_b_cls(new_loop,/S_GRID,/SMOOTH)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
    n_s=n_elements(new_loop.s)
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
;Testing procedures to plot new values over old

    window,!d.window, XS=1400, YSIZE=900, $
            TITLE='Regrid Window'
    old_p_state=!p.multi
    old_chars=!p.charsize
    old_chart=!p.charthick
    !p.charsize=2
    !p.charthick=1.5
    !p.multi=[0,3,2]
    ;old_margin=!p.margin
;
   
    plot,old_loop.s, title='old & new s vs. index',$
         XTITLE='Index #',$
         YTITLE='[cm]',$
         YRANGE=[min([old_loop.s, new_s]),$
                 max([old_loop.s,new_s])*1.1]
    TVLCT, newRed, newGreen, newBlue
    for i=0l, n_elements(new_s)-1l do begin
        plots, i,new_s[i], PSYM=1;, COLOR=colors[i]
    endfor
    
  ;  legend,legend_titles, PSYM=[1,1,1,1,1],$
  ;         /HORIZONTAL,$
  ;         COLORS=[color_index[1],color_index[2],$
  ;                 color_index[3],color_index[4],$
  ;                 color_index[0]],$
  ;         CHARSIZE=.7*!p.charsize
    tvlct, red, green, blue
    oplot, old_loop.s

    plot,old_ds, title='old s & min CLS',$
         XTITLE='Index #',$
         YTITLE='[cm]',$
         YRANGE=[min([old_ds,min_cls ]),$
                 max([old_ds,min_cls])*1.1]
    TVLCT, newRed, newGreen, newBlue
    for i=0l, n_elements(ds)-1l do begin
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
    for i=1l, n_elements(ds)-1l do begin
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
    
    xyouts, 390+70, 330, $
            'Change in particle number:'+string(n_part_old-n_part_new), $
            /DEVICE, CHARSIZE=1.3, CHARTHICK=1.2
    
    xyouts, 390+70, 300, $
            'Change in particle number fractional difference:',$
            /DEVICE, CHARSIZE=1.3, CHARTHICK=1.2
    
    xyouts, 410+70, 285, $
            string(abs(n_part_old-n_part_new)/n_part_new), $
            /DEVICE, CHARSIZE=1.3, CHARTHICK=1.2

    xyouts, 390+70, 255, $
            'Change in energy:'+string(energy_total_old-energy_total_new), $
            /DEVICE, CHARSIZE=1.3, CHARTHICK=1.2

    xyouts, 390+70, 225, $
            'Change in energy fractional difference:', $
            /DEVICE, CHARSIZE=1.3, CHARTHICK=1.2

    xyouts, 410+70, 210, $
            string(abs(energy_total_old-energy_total_new)/energy_total_new), $
            /DEVICE, CHARSIZE=1.3, CHARTHICK=1.2

    xyouts, 390+70, 180, $
            'Change in volume:'+string(old_volume_total-new_volume_total), $
            /DEVICE, CHARSIZE=1.3, CHARTHICK=1.2

    xyouts, 390+70, 150, $
            'Change in volume fractional difference:',$
            /DEVICE, CHARSIZE=1.3, CHARTHICK=1.2

    xyouts, 410+70, 135, $
            string(abs(old_volume_total-new_volume_total)/new_volume_total), $
            /DEVICE, CHARSIZE=1.3, CHARTHICK=1.2

    xyouts, 390+70, 105, $
            'Min/Max ds: '+strcompress(string(min(ds)),/REMOVE_ALL)+'/' $
            +strcompress(string(max(ds)),/REMOVE_ALL)+' [cm]',$
            /DEVICE, CHARSIZE=1.3, CHARTHICK=1.2

    xyouts, 390+70, 75, $
            'Momentum Change PD: ' $
            +strcompress(string(MOMENTUM_PD),/REMOVE_ALL),$
            /DEVICE, CHARSIZE=1.3, CHARTHICK=1.2

      



    !p.multi=old_p_state
    !p.charsize=old_chars
    !p.charthick=old_chart
 

    pmm, (old_ds-ds)
    pmm, (old_loop.s-new_s)
END
