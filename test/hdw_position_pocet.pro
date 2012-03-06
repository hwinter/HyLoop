
;.r hdw_position_pocet
;Spatial Grids
n_xs=[100, 500, 1d3, 5d3, 1d4, 5d4, 1d5]

;How many particles to use.
n_parts=[1d2,1d3]
n_n_xs=n_elements(n_xs)
n_n_parts=n_elements(n_parts)
time_ratio_1=dblarr(n_n_xs, n_n_parts)
time_ratio_2=time_ratio_1
fidelity=time_ratio_2
for xs_index=0ul, n_n_xs-1ul do begin
    for parts_index=0ul, n_n_parts-1ul do begin
;Define cell center positions
        x_s=dindgen(n_xs[xs_index])

;Define particle positions
        positions=max(x_s)*randomu(seed,n_parts[parts_index])
;Start the timer.
        start=systime(1)
        position_index=dblarr(n_parts[parts_index])
;Find the particles by using a for loop
        for k=0ul, n_parts[parts_index]-1ul do begin    
            position_index[k]=where(abs(positions[k]-x_s) eq $
                                    min(abs(positions[k]-x_s)))
            
                                ; print, positions[k],  x_s[position_index[k]]
        endfor
;Stop the timer.
        end_time=systime(1)
        delta_t1= end_time-start
        
        print,'For loop Time: ',delta_t1

;Start the timer
        start=systime(1)
;Create a position matrix for the particles
        position_matix=rebin(reform(positions,1,$
                                    n_parts[parts_index]),$
                             n_xs[xs_index],n_parts[parts_index])
;Create a matrix of the same dimensions for the grid locations.
        xs_matrix=rebin(x_s, n_xs[xs_index],n_parts[parts_index])
;Use the Min function to find the indices of the particles.
        junk=min(POSITION_MATIX-xs_matrix, position_index2, dim=1,/abs)
;Change the absolute array position to an index that relates to 
; x_s.  "I dare you to make less sense!" -Dean Venture
        position_index2=position_index2 mod n_xs[xs_index]
        end_time=systime(1)

        delta_t2= end_time-start
        print,'Matrix Time:',delta_t2
        print, ' '
        print,'Loop Time/Matrix Time:',delta_t1/delta_t2
        time_ratio_1[xs_index, parts_index]=delta_t1/delta_t2
        Max_diff= max(position_index-(position_index2 ))
;print,'Max difference:',Max_diff
        fidelity[xs_index, parts_index]=Max_diff

;Test inline code vs a function
        start=systime(1)
        
        position_matix=rebin(reform(positions,1,n_parts[parts_index]),$
                             n_xs[xs_index],n_parts[parts_index])
        xs_matrix=rebin(x_s, n_xs[xs_index],n_parts[parts_index])
        junk=min(POSITION_MATIX-xs_matrix, position_index2, dim=1,/abs)
;Change the absolute array position to an index that relates to 
; x_s.  "I dare you to make less sense!" -Dean Venture
        position_index2=position_index2 mod n_xs[xs_index]
        end_time=systime(1)
        
        delta_t2a= end_time-start
        
        
        start=systime(1)
        position_index2a=hdw_get_position_index(positions,x_s )
        end_time=systime(1)
        
        delta_t2b= end_time-start
        time_ratio_2[xs_index, parts_index]=delta_t2a/delta_t2b
;        print, ' '
;        print,'Matrix in line/ Matrix function',delta_t2a/delta_t2b
;        
;        print, ' '
;        print,'For Loop/ Matrix function',delta_t1/delta_t2b
    endfor
endfor

yrange=[min([time_ratio_1]), max([time_ratio_1])]

plot, n_xs, time_ratio_1[*, 0], $
      TITLE='Position Function Time Test',$
      YTITLE='', XTITLE='', $
      FONT=-1,CHARSIZE=1.7, CHARTHICK=1.7,$
      LINES=0, $
      YRANGE=yrange, YSTYLE=1, /NODATA

for i=0ul, n_n_parts-1ul do begin
    oplot,  n_xs, time_ratio_1[*, 0]

endfor




end
