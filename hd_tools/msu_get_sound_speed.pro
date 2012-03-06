;msu_get_sound_speed
function msu_get_sound_speed, state, GAMMA=GAMMA, S_GRID=S_GRID,$
  VOL_GRID=VOL_GRID, T=T

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;ratio of specific heats, C_P/C_V
if not keyword_set(GAMMA) then GAMMA = 5d0/3d0 


;Get the temperature 
;(if already calculated it can be passed to save time)
if not keyword_set(T) then $
  T = msu_get_temp(state)

;Calculate the sound speed on the volume grid
cs = sqrt(2d0*gamma*!msul_kB*T/!msul_mp)    ;

; Take an average to estimate the sound speed on the surface grid
if keyword_set(S_GRID) then begin
;index of last gridpoint
  ix = n_elements(state.e)-1ul 
  cs = (cs[0ul:ix-1] + cs[1ul:ix])/2d0
endif
return, cs

END; Of main
