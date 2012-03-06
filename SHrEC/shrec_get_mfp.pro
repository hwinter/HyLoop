;
;Calculate the mean free path of thermal Electrons via
;  Rosner, Low, & Holzer, 1986
;Output is in cm

function shrec_get_mfp, state,s, T=T,S_GRID=S_GRID,$
  VOL_GRID=VOL_GRID,$
  NO_ENDS=NO_ENDS, coulomb_log=coulomb_log, $
  SMOOTH=SMOOTH

if not keyword_set(Z) then z=!shrec_charge_z

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if not keyword_set(T) then T_in= shrec_get_temp(state) $
else T_in=T
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if not keyword_set(coulomb_log) then begin
;Need to change the definition of the coulomb log
 ;coulomb log (dimensionless)
;From Choudhuri p. 265
;coulomb_log=alog((1.5d0)*(1d0/!shrec_charge_z)*(1d0/(!shrec_qe^2d0))* $
;            ((!shrec_kB^3d0)*(T^3d0)*(1d0/!dpi)*$
;             (1d0/state.n_e))^5d-1)
    index1=where(T_in le 4.2d5)
    index2=where(T_in gt 4.2d5)
    coulomb_log_in=dblarr(n_elements(T_in))
    if index1[0] ne -1 then $
      coulomb_log_in[index1]=1.24d4 $
        *(T_in[index1]^1.5d0)*(state.n_e[index1]^(-0.5d0))
    
    if index2[0] ne -1 then $
      coulomb_log_in[index2]=8.0d6*(T_in[index2])*(state.n_e[index2]^(-0.5d0))
    
    coulomb_log_in=alog(coulomb_log_in)
endif else coulomb_log_in=coulomb_log




mfp=(1.1d8) $
    *(1d8/state.n_e) $
    *((T_in/1d6)^2d0) $
    *(20./coulomb_log_in)

;If the keyword is set then spline it to the s grid
if keyword_set(S_GRID) then begin
   ; s_alt=shrec_get_s_alt(s)
   ; mfp =spline(s_alt,mfp,s)    
    n_elem=size(mfp,/dim)
    
    mfp =(mfp[0:n_elem[0]-2,*]+mfp[1:n_elem[0]-1,*])/2d0
endif else if  keyword_set(NO_ENDS) then begin
    n_elem=size(mfp,/dim)
    mfp=mfp[1:n_elem[0]-2,*]
endif


;Smooth if desired.
if keyword_set(SMOOTH) then begin    
    if not keyword_set(ITER_SMOOTH) then ITER_SMOOTH=5
    if SMOOTH eq 1 then SMOOTH=3
    mfpF=mfp 
    for j=0,ITER_SMOOTH do mfpF=smooth(mfpF, SMOOTH)
    mfpR=reverse(mfp)
    for j=0,ITER_SMOOTH do mfpR=smooth(mfpR, SMOOTH)
    mfp=(mfpF+reverse(mfpR))/2d0

endif

return,abs(mfp)

END
