pro mk_hxr_3_6_avg_sig, folders,$
                    EXT=EXT,$
                    SAVE_NAME=SAVE_NAME,$
                    FILE_PREFIX=FILE_PREFIX,$
                    save_DIR=save_DIR,$
                    LOUD=LOUD, BSDEV=BSDEV,$
                    BMEAN=BMEAN

IF  keyword_set(LOUD) then time=systime(1)
if size(folder,/TYPE) ne 7 then folder='./'
IF NOT keyword_set(SAVE_DIR) then SAVE_DIR=''
IF NOT keyword_set(EXT) THEN EXT='.loop'
IF NOT keyword_set(SAVE_NAME) THEN SAVE_NAME='hxr_3_6_avg_emiss.save'
IF NOT keyword_set(FILE_PREFIX) THEN FILE_PREFIX=''

E_RANGE=[3., 6.0]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
n_folders=n_elements(folders)
;Compute the mimimum number of files available.
file_count=1d30

for i=0ul, n_folders-1ul do begin
    files=file_search(folders[i],FILE_PREFIX+'*'+EXT, COUNT=FILE_COUNT_temp)
    file_count<=FILE_COUNT_temp
endfor
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Populate a two-D variable with filenames.
files=strarr(file_count, n_folders)
for j=0ul, n_folders-1ul do begin
    files_temp=file_search(folders[j],$
                           FILE_PREFIX+'*'+EXT)
    files[0:file_count-1,j]=files_temp[0:file_count-1]
endfor
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Error checking.
if FILE_count eq 0 then begin
    MESSAGE, 'No files matching *'+ext+' were found', /CONTINUE
    goto, end_jump
endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
restore, files[0,0]
vol=get_loop_vol(loop)
n_vol=n_elements(vol)
emiss_array=dblarr(n_elements(vol),file_count)
sdev_array=emiss_array
times=dblarr(file_count)
;This outer loop is the timestep
for i=0ul, FILE_COUNT-1ul  do begin
    for j=0ul, n_folders-1ul do begin
        restore, files[i,j]
        times[i]=loop.state.time
        if j eq 0 then begin
            loops=loop     
            nt_brems_array=nt_brems
        endif else begin
            loops=[loops, loop] 
            nt_brems_array=[[nt_brems_array],[nt_brems]]
          
        endelse
 ;       help, nt_brems_array

;Make sure that loops are interpolated on the same grid.
;             loop= interpolate_loop(loop, loops[0])
  
    endfor                      ; j (n_runs) loop
    emiss_array[*,i] =get_avg_xr_emiss(loops, nt_brems_array,$
                            STD_DEV=STD_DEV, $
                            E_RANGE=E_RANGE,/BSDEV)
    sdev_array[*,i]=STD_DEV    
endfor                          ; i (time) loop.

save, emiss_array, sdev_array, times,$
      FILE=SAVE_dir+'/'+SAVE_NAME
IF  keyword_set(LOUD) then $
  print, 'mk_hxr_3_6_avg_sig took '+ $
         string((systime(1)-time)/60.)+' minutes to run.'
end_jump:
end
