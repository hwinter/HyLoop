pro mk_e_dist_movie, folder,run_folders, $
                     GIF_DIR=GIF_DIR,EXT=EXT,$
                     MOVIE_NAME=MOVIE_NAME,$
                     FILE_PREFIX=FILE_PREFIX,$
                     LOUD=LOUD, JS=JS,$
                     FREQ_OUT=FREQ_OUT, $
                     CS=CS, JAVA=JAVA,$ ; GIF=GIF,$
                     MPEG=MPEG,LOOP=LOOP, $
                     TITLE=TITLE, font=font, $
                     MOVIE_DIR=MOVIE_DIR, $
                     VARY=VARY, MAX_N_FILES=MAX_N_FILES,$
                     L_ITEMS=L_ITEMS    , $
                     INDEX_IN=INDEX_IN ,  $
                     CHARSIZE=charsize,CHARTHICK=charthick,$
                     XRANGE=XRANGE, YRANGE=YRANGE, xlog=xlog, ylog=ylog


frames_per_plot=5
IF  keyword_set(LOUD) then time=systime(1)
if size(folder,/TYPE) ne 7 then folder='./'
if file_test(folder,/DIRECTORY) ne 1 then $
    spawn, 'mkdir '+folder
IF NOT keyword_set(GIF_DIR) then GIF_DIR=folder+'gifs/'
if file_test(GIF_DIR,/DIRECTORY) ne 1 then begin
    GIF_DIR= folder+'gifs/'
    spawn, 'mkdir '+GIF_DIR
endif
IF NOT keyword_set(MOVIE_DIR) then MOVIE_DIR=folder+'movies/'
if file_test(MOVIE_DIR,/DIRECTORY) ne 1 then begin
    MOVIE_DIR= folder+'movies/'
    spawn, 'mkdir '+MOVIE_DIR
endif
    
IF NOT keyword_set(EXT) THEN EXT='.loop'
IF NOT keyword_set(MOVIE_NAME) THEN MOVIE_NAME='e_dist_movie'
IF NOT keyword_set(FILE_PREFIX) THEN FILE_PREFIX=''
if not keyword_set(FREQ_OUT) then FREQ_OUT=1.
if not keyword_set(MPEG) or $
  keyword_set(GIF)or keyword_set(JAVA) then mpeg=1

files=file_search(folder+'/'+run_folders[0]$
                  +'/',FILE_PREFIX+'*'+EXT,$
                  COUNT=FILE_COUNT)


if keyword_set(MAX_N_FILES) then FILE_COUNT<=MAX_N_FILES
if FILE_count eq 0 then begin
    MESSAGE, 'No files matching *'+ext+' were found', /CONTINUE
    goto, end_jump
endif

n_runs=n_elements(run_folders)

files=strarr(n_runs, file_count)
for j=0ul, n_runs-1ul do begin
   temp_files=file_search(folder+'/'+run_folders[j]$
                  +'/',FILE_PREFIX+'*'+EXT)

   files[j,*]=temp_files[0:FILE_COUNT-1ul]
endfor

current_device=!d.name
set_plot,'z'
device, Set_Resolution=[600,600]
;set_plot,'x'
;window,0,xs=800,ys=800
gifs='';set the old colors
tvlct,old_r, old_g, old_b, /GET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Set the new colors
tvlct, [0,255,0,0], [0,0,255,0], [0,0,0,255]

tvlct,r,g,b,/get

    ps_files=''
    gif_files=''

animate_index=0ul
old_state=!D.NAME

set_plot, 'PS'
 for i=0ul, FILE_COUNT-1ul ,freq_out do begin
         IF  keyword_set(LOUD) then begin
             print, 'working on file '+files[i]
             print,'########################################################################'
         endif
         
         
         restore, files[0,i]
         for j=1ul, n_runs-1ul do begin
             print, 'working on file '+files[j,i]
            restore, files[j,i]
            print, loop.state.time
            NT_beam=[nt_beam, nt_beam]
         endfor
         NT_beam.scale_factor=NT_beam.scale_factor/n_runs


         L_ITEMS=$
                 ['Time= '+$
                  strcompress(string(loop.state.time,format='(d07.2)'))+' s']
  
         for zz=0ul, frames_per_plot do begin
            index_string= string(animate_index,FORMAT= $  
                                 '(I5.5)')
            POST=gif_dir+'e_dist_temp'+ $
                 '_'+index_string+'.ps'
            print, post
            gif_file=gif_dir+'e_dist_temp'+ $
                     '_'+index_string+'.gif'
  ;      spawn, "convert  -rotate '-90' "+ $
                                ;             gif_file+'  '+gif_file
        
            CHARTHICK=1.7
            CHARSIZE=1.7
            plot_e_dist, nt_beam, GIF_NAME=GIF_NAME,$
                         XTITLE=XTITLE,YTITLE=YTITLE, TITLE=TITLE, $
                         CHARSIZE=charsize,CHARTHICK=charthick, $
                         BCOLOR=BCOLOR,XSTYLE=XSTYLE ,$
                         BACKGROUND = BACKGROUND , COLOR = COLOR ,$
                         PS=Post, _extra=extra, $
                         SPEC_INDEX=SPEC_INDEX, $
                         energy_array=energy_array, n_array=n_array, $
                         /OP,$  ; INDEX_IN=INDEX_IN,
                         L_ITEMS=L_ITEMS  , font=-1   , xlog=xlog, ylog=ylog  
            
            spawn, 'convert  '+POST+' '+gif_file
            spawn, "convert  -rotate '-90' "+ $
                   gif_file+'  '+gif_file
            
            ps_files=[ps_files, POST]
            gif_files=[ gif_files,gif_file]
           animate_index++
         endfor ;zz
    endfor


;image2movie,plot_array,r,g,b, $
;  movie_name=strcompress(gif_dir+'/'+MOVIE_NAME,/REMOVE_ALL), $
;  scratchdir=gif_dir,gif_animate=1,loop=1


    n_files=n_elements(ps_files)
    ps_files=ps_files[1:n_files-1ul]
    gif_files=gif_files[1:n_files-1ul]
    image2movie,gif_files, $
                movie_name=movie_Dir+movie_name,$
                /mpeg,$         ;/java,$
                scratchdir=gif_dir; ,$;nothumbnail=1,$
;                /nodelete
;    image2movie,gif_files, $
;                movie_name=gif_dir+movie_name,$
;                /java,$
;                scratchdir=gif_dir ,$ ;nothumbnail=1,$
;                /nodelete
    ;Remove these unwanted thumbnails.
    spawn,'rm -f  '+gif_dir+'*micon* *mthumb*'
        
    
set_plot,current_device

;Reset to the old colors
tvlct,old_r, old_g, old_b
IF  keyword_set(LOUD) then $
  print, 'Mk_hd_movie took '+string((systime(1)-time)/60.)+' minutes to run.'
end_jump:
end
