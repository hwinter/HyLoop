;+
; NAME:
;	mk_run_copies.pro
;
; PURPOSE:
;	To take a run script stub and output a file, appropriate for use 
;         with ssw_batch, with a run number.
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
;	
;
; PROCEDURE:
;	
;
; EXAMPLE:
;	
;
; MODIFICATION HISTORY:
; 	Written by:	Henry (Trae) D. Winter III 2008_Sept_09
;-

pro mk_run_copies, stub_name,out_prefix, N_RUNS=N_RUNS

if not keyword_set(N_RUNS) then N_RUNS_in=99 else N_RUNS_in=N_RUNS



run_nums=findgen(N_RUNS_in)+1
run_nums_s=strcompress(string(run_nums, format='(i05)'),/REMOVE_ALL)


;; how many lines are in the file
lines = file_lines(stub_name)
;; an array to hold the whole file
var_arr_orig=strarr(lines)
openr, lun,stub_name , /GET_LUN
READF,lun , var_arr_orig

free_lun, lun

for i=0ul, N_RUNS_in-1ul do begin
    
    out_names=out_prefix+'_'+run_nums_s[i]+'.pro'
    RUN_FOLDERS='run_'+$
                run_nums_s[i]+'/'
    added_lines=['; .r '+out_names[0],$
                 ' ',$
                 "RUN_FOLDERS='"+RUN_FOLDERS[0]+"'", $
                 '  ']
   
    var_arr=[added_lines, var_arr_orig]
    openw, lun, out_names[0]
    for k=0ul , n_elements(var_arr) -1ul do begin
        printf, lun, var_arr[k]
    endfor

    free_lun, lun
endfor
;stop


end
