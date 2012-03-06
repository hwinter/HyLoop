
n_s=n_elements(loop.s)
step=loop.s[1:n_s-1]-loop.s[0:n_s-2] 

change_index=where(STEP gt MIN_CLS[0:n_s-2]/grid_safety)
if change_index[0] ne -1 then begin
    new_step=MIN_CLS[change_index]/grid_safety
    
    for i= 0l, n_elements(new_step)-1 do begin
        n_new_cells=round_off($
                              step[change_index[i]]/new_step[i],$
                              1)
        
        s_inject=total(dblarr(n_new_cells)+new_step[i], $
                       /CUMULATIVE)



    endfor

endif

end
