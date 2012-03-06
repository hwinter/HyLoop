
function get_loop_min_cls, loop, S_COORD, $
  GRID_SAFETY=GRID_SAFETY,$
  S_GRID=S_GRID, VOL_GRID=VOL_GRID,$
  SMOOTH=SMOOTH, NO_ENDS=NO_ENDS

;Call the grid safety within the program GRID_SAFETY_p
; since calling it the same name as the keyword could 
; cause trouble in loops.
if not keyword_set(grid_safety) then Begin

    if chktag(loop,'grid_safety') gt 0 then begin
        
      if loop.grid_safety le 0. then grid_safety_p=10d0 $
      else grid_safety_p=loop.grid_safety
  endif else grid_safety_p=1d0
  
endif else GRID_SAFETY_p=GRID_SAFETY

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Define Characteristic length scales
;cls=characteristic length scale
;If you find any zeroes, make them a small number so that you don't
;end up dividing by zero
;Energy
e_cls=get_loop_e_cls(loop,S_GRID=S_GRID,$
                     VOL_GRID=VOL_GRID,$
                     NO_ENDS=NO_ENDS,$
                     SMOOTH=SMOOTH)
;Density
n_e_cls=get_loop_n_e_cls(loop,S_GRID=S_GRID,$
                     VOL_GRID=VOL_GRID,$
                     NO_ENDS=NO_ENDS,$
                     SMOOTH=SMOOTH)
;Temperature
T_cls=get_loop_temp_cls(loop,S_GRID=S_GRID,$
                     VOL_GRID=VOL_GRID,$
                     NO_ENDS=NO_ENDS,$
                     SMOOTH=SMOOTH)
;Yes. I know that temperature is just a function of 
;density and energy but I'm doing it anyway!
;Velocity
v_cls=get_loop_v_cls(loop,S_GRID=S_GRID,$
                     VOL_GRID=VOL_GRID,$
                     NO_ENDS=NO_ENDS,$
                     SMOOTH=SMOOTH)
;Magnetic field
b_cls=get_loop_b_cls(loop,S_GRID=S_GRID,$
                     VOL_GRID=VOL_GRID,$
                     NO_ENDS=NO_ENDS,$
                     SMOOTH=SMOOTH)


if size(S_COORD, /TYPE) ne 0 then begin
    index=where(abs(loop.s_alt-S_COORD) eq min(abs(loop.s_alt-S_COORD)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;For each x find the smallest characteristic length scale
;Can this be done without the loop?

;colors=dblarr(n_s)
    min_cls=min([e_cls[index],$
                 n_e_cls[index],$
                 v_cls[index],$
                 b_cls[index],$
                 t_cls[index]])
    
endif else   min_cls=min([e_cls,$
                 n_e_cls,$
                 v_cls,$
                 b_cls,$
                 t_cls])


    min_cls=temporary(min_cls)/grid_safety_p
       
return , min_cls
 
END
