pro fit_function_edp,x,a,f,pder

    dist=(X)^(-1.*(a[1]))
    dist=dist/total(dist)
f=A[0]*dist
;print, 'Idiot!'
pder=A[0]*A[1]*(x^(-1.0*A[1]-1.))

;return, f
end

function get_nt_beam_spec_index ,nt_beam

in_beam=nt_beam
index=where(nt_beam.state eq 'NT')
case 1 of
    index[0] eq -1:begin
        spec_index=0
        goto, end_jump
    end
    
    n_elements(index) le 3 :begin
        spec_index=0
        goto, end_jump
    end
    else:begin
        in_beam=in_beam[index]
        end
endcase

min_energy=min(in_beam.ke_total)
max_energy=max(in_beam.ke_total)
delta=max_energy-min_energy
step=.5
n_elem=long(.5+delta/step)
energy_array=min_energy+delta*dindgen(n_elem)/(n_elem-1ul)
n_array=dindgen(n_elem)
if index[0] eq -1 then begin
    n_array=energy_array*0d

goto, all_dead
endif
for i=0ul, n_elem-1ul do begin
    z=where(in_beam.ke_total le energy_array[i]+(step/2.) $
            and $
            in_beam.ke_total ge energy_array[i] -(step/2.), count)
    if z[0] ne -1 then $
      n_array[i]=total(in_beam[z].scale_factor) $
      else n_array[i]=0.
    ;stop
endfor

all_dead:
n_part=total(in_beam.scale_factor)


ind=where(n_array eq MAX(n_array))
e_arr=energy_array[ind[0]:*]
n_arr=n_array[ind[0]:*]
if n_elements(e_arr) le 3 then begin
        spec_index=0
        goto, end_jump
    endif


a=[n_part,1]

weights=dblarr(n_elements(e_arr))
t1=where(n_arr gt 100)
max_e_count=max(energy_array[t1])/2d0
test=where(energy_array le max_e_count[0])
if test[0] ne -1 then weights[test]=1 else weights[*]=1
 weights[*]=1.

;Could have used comfit.  Comfit may be quicker.
yfit=curvefit(e_arr,n_arr,$ ;weights, $
              1.^(min(e_arr)-e_arr), $
              a, /double,$
              FUNCTION_NAME='fit_function_edp',$
             /noder,itmax=1d3, tol=1d-20,$
             Status=Status)

if  Status gt 0 then begin
        spec_index=0
        goto, end_jump
    endif
result=a

SPEC_INDEX=result[1]

end_jump:
return, spec_index

end

