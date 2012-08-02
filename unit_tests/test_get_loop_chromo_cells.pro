pro test_get_loop_chromo_cells_run, N_CELLS, N_DEPTH, N_ERRORS
  loop=mk_chromo_test_loop(N_DEPTH=N_DEPTH,N_CELLS=N_CELLS)

  test_get_loop_chromo_cells_info_print, n_cells, n_depth, loop

  temp=get_loop_temp(loop)

  actual_chromo_ind=where(temp eq 1d4, actual_chromo_count)

  test_chromo_ind=get_loop_chromo_cells(loop, count=test_chromo_count)

  n_total_cells=n_elements(loop.s_alt)

  actual_chromo_ind=[[actual_chromo_ind[where(actual_chromo_ind le n_total_cells/2 )]],[actual_chromo_ind[where(actual_chromo_ind gt n_total_cells/2 )]]]

  if actual_chromo_count ne test_chromo_count then begin
     error_text='actual_chromo_count= '+strcompress(string(actual_chromo_count, FORMAT='(I10)'), /REMOVE_ALL) $
                +' and get_loop_chromo_cells counted '+strcompress(string(test_chromo_count, FORMAT='(I10)'), /REMOVE_ALL)+'.'
     test_get_loop_chromo_cells_err_message, n_cells, n_depth, error_text
     N_ERRORS++
  endif

for iii=0,1 do begin
  bad_match=where(actual_chromo_ind[*,iii]-test_chromo_ind[*,iii] ne 0, bad_count)

  if bad_match[0] ne -1 then begin
     for jjj=0, bad_count-1ul do begin
        error_text=test_get_loop_chromo_cells_make_error_text(bad_match[jjj], iii, actual_chromo_ind, test_chromo_ind )
        N_ERRORS++
        test_get_loop_chromo_cells_err_message, n_cells, n_depth, error_text
        
     endfor

  endif
endfor
end

function test_get_loop_chromo_cells_make_error_text, Dim1ind, Dim2ind, actual_chromo_ind, test_chromo_ind 
  Dim1ind_str=strcompress(string(Dim1ind, FORMAT='(I10)'), /REMOVE_ALL)
  Dim2ind_str=strcompress(string(Dim2ind, FORMAT='(I10)'), /REMOVE_ALL)
  
  actual_chromo_ind_str=strcompress(string(actual_chromo_ind[Dim1ind,Dim2ind], FORMAT='(I10)'), /REMOVE_ALL)
  test_chromo_ind_str=strcompress(string(test_chromo_ind[Dim1ind,Dim2ind], FORMAT='(I10)'), /REMOVE_ALL)


  error_text='Index mismatch. '+ $
              'actual_chromo_ind['+Dim1ind_str+','+Dim2ind_str+']='+ actual_chromo_ind_str + $
              ', and test_chromo_ind['+Dim1ind_str+','+Dim2ind_str+']='+ test_chromo_ind_str

return, error_text
  
end

pro test_get_loop_chromo_cells_err_message, n_cells, n_depth, error_text

  error_text_out=error_text+' With N_CELLS='+strcompress(string(n_cells, FORMAT='(I10)'), /REMOVE_ALL) $
             +' and N_DEPTH='+strcompress(string(n_depth, FORMAT='(I10)'), /REMOVE_ALL)+'.'
  message,error_text_out, LEVEL=-2, /CONTINUE

end
pro test_get_loop_chromo_cells_info_print, n_cells, n_depth, loop
  Print, ';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;'
  print, 'N_CELLS='+strcompress(string(n_cells, FORMAT='(I10)'), /REMOVE_ALL) 
  print, 'N_DEPTH='+strcompress(string(n_depth, FORMAT='(I10)'), /REMOVE_ALL)
  print, 'Actual loop N_DEPTH='+strcompress(string(loop.n_depth, FORMAT='(I10)'), /REMOVE_ALL)
  Print, ';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;'

end 
function test_get_loop_chromo_cells, N_ERRORS=N_ERRORS
  N_ERRORS=0

  N_DEPTH=[100, 101, 101, 100]
  N_CELLS=[100, 100, 101, 101] 
  
  for iii=0, n_elements(n_depth) -1 do begin
     test_get_loop_chromo_cells_run, N_CELLS[iii], N_DEPTH[iii], N_ERRORS
  endfor
  
  if N_ERRORS gt 0 then return, -1 else return, 1
END




