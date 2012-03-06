;Thermal conduction section
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function MSU_conduction, state, s,a, $
  SO=SO, $                     ;Pass the SO for C codes if desired
  IS=is, $
  DT=dt, $
  DS1=ds1, $
  DS2=ds2, $
  TEMP=TEMP,$
  S_GRID_TEMP=S_GRID_TEMP,$
  SPIT=SPIT,$
  NO_SAT=NO_SAT,$
  A1=A1,$
  FACTOR=FACTOR,coulomb_log=coulomb_log, $
  L_T=L_T, MFP=MFP, K2=K2

;Set so that () is for functions and [] is for array indices, rigidly!
compile_opt strictarr
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Determine what is passed and what we need to calculate

if not keyword_set(is) then $
  is = n_elements(state.e)-1    ;index of last volume gridpoint  

if not keyword_set(DS1) then begin
    if size(S, /type) eq 0 then begin
        print, 'Must specify S or IS' 
        stop
        endif
;calculate grid spacing
;valid indices run from 0 to is-2 (volume grid, missing ends)
    ds1 = s[1:is-1]-s[0:is-2]
endif

if not keyword_set(DS2) then $ 
;ds1 interpolated onto the v grid, ends extrapolated.
  ds2 = [ds1[0],(ds1[0ul:is-3ul] + ds1[1ul:is-2ul])/2d0, ds1[is-2ul]]


if not keyword_set(DT) then dt =1d0 
if not keyword_set(TEMP) THEN  $
  TEMP = msu_get_temp(state)  
if not keyword_set(S_GRID_TEMP) then $   
;temperature interpolated to the surface grid
   S_GRID_TEMP = (TEMP[0UL:is-1UL] + TEMP[1UL:is])/2D0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Thermal conduction (implicit differencing)
;Given an inhomogeneous matrix equation
;	M T' = 3 ne kB T
;where T is the initial temperature, T' is final temperature,
;ne is electron density, kB is Boltzmann's constant, and M 
;is a tridiagonal matrix, invert for T'.	
;calculate thermal conductivity
K2 = msu_kappa(S_GRID_TEMP,SO=SO) 
if not keyword_set(NO_SAT) then begin
    k_old=K2
    iii=where(S_GRID_TEMP gt 10^5.5)
    if iii[0] eq -1 then goto, not_hot_enough
;Institute a correction to the heat flux given by
; Rosner, Low, and Holzer 1986 based upon the work of
; Matte & Virmont, 1982   
    s_alt=msu_get_s_alt(s)
    L_T=msu_get_temp_cls(state,s_alt, floor=1d-5,$
                       /S_GRID)       ;, /smooth)    
    ;pmm, l_t
   ; L_T>=1d-12

    mfp=msu_get_mfp( state,s,T=TEMP,/S_GRID,$
                     coulomb_log=coulomb_log);,$
    ;               /SMOOTH)
    ;mfp>=L_T
    k_temp=abs(k2[iii]*(11d-2) $
       *((mfp[iii]/L_T[iii])^(-0.36)))

    k2[iii]<=k_temp
not_hot_enough:
;    k2f=k2
;    for count=0ul,10ul do k2f=smooth(k2f, 3)
;    k2r=reverse(k2)
;    for count=0ul,10ul do k2r=smooth(k2r, 3)
;    k2=(k2f+reverse(k2r))/2d0

   
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Section to calculate a cutoff limit
;Calculate the conductive flux   
;    F_c=abs(K2[iii]*t_power*grad_T)
;Calculate the cutoff due to free-streaming
;Density on the s_grid
;    n_e_s_grid=(state.n_e[0UL:is-1UL] + state.n_e[1UL:is])/2D0
;Define the saturated flux as a fraction of the heat flux carrying electrons
; stream down the temperature gradient at the local rms thermal speed.
;    F_sat=(1./4.)*n_e_s_grid[iii]*0.5*!msul_me $
;          *((3.*!msul_kB*S_GRID_TEMP[iii]/!msul_me)^1.5d0)
;    ratio=F_c/F_sat
;    ratio>=1d0
;    F_c/=ratio
;stop
;    K2[iii]=F_c/abs(t_power*grad_T)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   
endif
;stop
;Added area terms 2008-APR-01 HDWIII
as=0.5*((A[0:is-2]) +(A[1:is-1]))
temp1 =( A[0:is-2] * K2[0:is-2] * dt $
        /(ds2[0:is-2]*ds1*as))
temp2 =(A[1:is-1] * K2[1:is-1] * dt $
       /(ds2[1:is-1]*ds1*as ))

;sub-diagonal elements of M
sub = [0.0, -temp1, 0.0]

;main diagonal elements of M	
main = 3.0*(state.n_e)*(!msul_kB) + [0.0, temp1 + temp2, 0.0]
	
;super-diagonal elements of M
super = [0.0, -temp2, 0.0]

;right-hand side of the inhomogeneous equation
rhs = 3 *( state.n_e) * (!msul_kB)* (TEMP)

;alower=sub[0:n_elements(sub)-2]
;aupper=super[1:*]
;adiag=main	
;dlower=alower
;dupper=aupper
;ddiag=adiag
Tprime = trisol((sub),(main),(super),(rhs), /double)
;LA_TRIDC,dlower ,ddiag ,dupper , u2, index
;Tprime0= LA_TRISOL(dlower,ddiag ,dupper, u2, index, rhs)
;tprime = LA_TRIMPROVE(alower, adiag, aupper, $  
;                    dlower,ddiag , dupper, u2, index, rhs,Tprime0 )
;used to use state.e instead of T,
;but  modifications to time stepping cause T and state.e to
;be out of sync!

;Converts to energy [ergs]
conduction = 3.*(state.n_e)*(!msul_kB)*(Tprime - TEMP) 
;stop
return , conduction
end; of main
