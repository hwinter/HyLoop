pro test_heat, folder, $
               FILE_PREFIX=FILE_PREFIX ,EXT=EXT,$
               TMAX=TMAX

if size(folder,/TYPE) ne 7 then folder='./'
IF NOT keyword_set(EXT) THEN EXT='.loop'
IF NOT keyword_set(MOVIE_NAME) THEN MOVIE_NAME='hd_movie.gif'
IF NOT keyword_set(FILE_PREFIX) THEN FILE_PREFIX=''

IF NOT keyword_set(TMAX) then tmax=1d6

files=file_search(folder,FILE_PREFIX+'*'+EXT, COUNT=FILE_COUNT)

if FILE_count eq 0 then begin
    MESSAGE, 'No files matching *'+ext+' were found', /CONTINUE
    goto, end_jump
endif






 for i=0l, FILE_COUNT-1l do begin

     restore, files[i]
     volumes=get_loop_vol(loop)
     q0=get_serio_heat(loop.l, TMax)  
     total_serio_heat=total(q0*volumes)
     total_pl_heat=total(e_h*volumes) 

     if size(serio_heat_array, /TYPE) eq 0 then $
       serio_heat_array=total_serio_heat else $
       serio_heat_array=[serio_heat_array, total_serio_heat]
     if size(pl_heat_array, /TYPE) eq 0 then $
       pl_heat_array=total_pl_heat else $
       pl_heat_array=[pl_heat_array,total_pl_heat]

     if size(ratio_array, /TYPE) eq 0 then $
       ratio_array=total_pl_heat/total_serio_heat else $
       ratio_array=[ratio_array,total_pl_heat/total_serio_heat]
     
     if size(time_array, /TYPE) eq 0 then $
       time_array=loop.state.time else $
       time_array=[time_array, loop.state.time]
     






 endfor


plot, time_array, ratio_array, $
      XTITLE='Time [s]', YTITLE='Power Law Heat/Serio Heat',$
      TITLE='Heat Test'

oplot , time_array, ratio_array, PSYM=2
 pmm, ratio_array

end_jump:
END
