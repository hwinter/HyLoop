;Not finished.

function get_med_xr_emiss, loops, nt_brems,$
  STD_DEV=STD_DEV, VARIANCE=VARIANCE, $
  E_RANGE=E_RANGE, NOT_EARTH=NOT_EARTH, $
  NT_ONLY=NT_ONLY, THERM_ONLY=THERM_ONLY,$
  DT=DT, XRT=XRT, FILTER_INDEX=FILTER_INDEX, $
  BSDEV=BSDEV


if not keyword_set(E_RANGE) then E_RANGE=[6., 12.]
if not keyword_set(dt) then dt=1d0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
info=size(nt_brems, /dim)
n_vol=info[0]
case 1 of
    n_elements(info) eq 1 :begin
        if info[0] eq 0 then begin
            print, 'No NT_Brems array to process!'
            mean_Q=-1
            goto, end_jump
        endif
    end

    n_elements(info) gt 1: begin
        n_brems_arrays=info[1]
        if n_elements(loops) ne n_brems_arrays then $
          loops=replicate(loops[0], n_brems_arrays)
        n_vol=info[0]
;        help, n_brems_arrays
;        help, n_vol
        
    end

        
endcase

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Q for quantity to make copying and pasting easier.
Q=dblarr(n_vol, n_brems_arrays)


for i=0ul, n_brems_arrays-1ul do begin
    temp= get_xr_emiss( loops[i], nt_brems[*,i], $
                                 E_RANGE=E_RANGE, $
                                 NT_ONLY=NT_ONLY, THERM_ONLY=THERM_ONLY,$
                                 DT=DT); NOT_EARTH=NOT_EARTH,, XRT=XRT, FILTER_INDEX=FILTER_INDEX)
    Q[*, i]= reform(total(temp,2))
endfor 

mean_Q=total(q, 2)/n_brems_arrays

med_Q=median(Q, 2, /double)

n_elem=n_elements(mean_Q[*,0])
mQ2=rebin(mean_Q,n_elem,n_brems_arrays  )

VARIANCE=(1d0/(n_brems_arrays-1ul))*$
         total((Q-mQ2)*(Q-mQ2), 2)

STD_DEV=sqrt(VARIANCE)

if keyword_set(BSDEV) then begin
    for j=0ul, n_elem-1ul do begin
        JUNK=bootstrap_mean(q[j,*])
        mean_Q[j]=JUNK[0]
        STD_DEV[i]=junk[1]    
    endfor

endif

end_jump:
return, mean_Q
END                             ; OF MAIN
