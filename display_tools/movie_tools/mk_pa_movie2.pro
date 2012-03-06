pro mk_pa_movie2, folder,folder2,$
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
                 L_ITEMS=L_ITEMS ,THERMAL_STOP=THERMAL_STOP ,$
                 YRANGE=YRANGE, YSTYLE=YSTYLE

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

frame_count=5ul
    
IF NOT keyword_set(EXT) THEN EXT='.loop'
IF NOT keyword_set(MOVIE_NAME) THEN MOVIE_NAME='pa_movie'
IF NOT keyword_set(FILE_PREFIX) THEN FILE_PREFIX='patc'
if not keyword_set(FREQ_OUT) then FREQ_OUT=1.
if not keyword_set(MPEG) or $
  keyword_set(GIF)or keyword_set(JAVA) then mpeg=1
files=file_search(folder,FILE_PREFIX+'*'+EXT, COUNT=FILE_COUNT1)
files2=file_search(folder2,FILE_PREFIX+'*'+EXT, COUNT=FILE_COUNT2)

FILE_COUNT=min([FILE_COUNT1,FILE_COUNT2])
if keyword_set(MAX_N_FILES) then FILE_COUNT<=MAX_N_FILES
if FILE_count eq 0 then begin
    MESSAGE, 'No files matching *'+ext+' were found', /CONTINUE
    goto, end_jump
endif
;set the old colors
current_device=!d.name
gifs=''
tvlct,old_r, old_g, old_b, /GET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Set the new colors
tvlct, [0,255,0,0], [0,0,255,0], [0,0,0,255]
tvlct,r,g,b,/get
    ps_files=''
    gif_files=''
j=0ul
old_state=!D.NAME
set_plot, 'PS'
 for i=1ul, FILE_COUNT-2ul ,freq_out do begin
         IF  keyword_set(LOUD) then begin
             print, 'working on file '+files[i]
             print,$
                   '########################################################################'
         endif
         
         restore, files[i]
         nt_beam1=nt_beam
         help, loop.state.time
         restore, files2[i-1ul]
         nt_beam2=nt_beam
         help, loop.state.time
         
         if keyword_set(THERMAL_STOP) then begin
             z=where(nt_beam.state eq 'NT')
             if z[0] eq -1 then goto, no_mas
         endif
         
         time=$
                 ['Time= '+$
                  strcompress(string(loop.state.time,format='(d06.1)'))+' sec']
        
         l_items2=['Dynamic','Static']
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
         for zzz=0ul, frame_count-1ul do begin
             index_string= string(j,FORMAT= $  
                                  '(I5.5)')
             POST=gif_dir+'pa_disp'+ $
                  '_'+index_string+'.eps'
             gif_file=gif_dir+'pa_disp'+ $
                      '_'+index_string+'.gif'
  ;      spawn, "convert  -rotate '-90' "+ $
                                ;             gif_file+'  '+gif_file
             
             device, FILE=POST, COLOR=16, /ENC
             pa_plot4, nt_beam1,nt_beam2, $
                       XTITLE=XTITLE,YTITLE=YTITLE, TITLE=TITLE,$
                       YRANGE=YRANGE, YSTYLE=YSTYLE,$
                       CHARSIZE=charsize,CHARTHICK=charthick, $
                       BCOLOR=BCOLOR,/XSTYLE,$
                       BACKGROUND =BACKGROUND , COLOR = COLOR ,$
                       _EXTRA=EXTRA, time=time ,$
                       l_items2=l_items2 ; PS=PS
             
             device, /CLOSE
             spawn, 'convert  '+POST+' '+gif_file
             ps_files=[ps_files, POST]
             gif_files=[ gif_files,gif_file]
             J++
         endfor


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     endfor
no_mas:

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
