pro mk_part_disp_movie3, loop,beam, $
  GIF_DIR=GIF_DIR,PLOT_DIR=PLOT_DIR,$
  MOVIE_NAME=MOVIE_NAME,EXT=EXT,$
  FILE_PREFIX=FILE_PREFIX,$
  LOUD=LOUD, JS=JS,$
  FREQ_OUT=FREQ_OUT, $
  CS=CS, JAVA=JAVA,$            ; GIF=GIF,$
  MPEG=MPEG,LOOP=LOOP, $
  TITLE=TITLE, font=font, $
  MOVIE_DIR=MOVIE_DIR, $
  VARY=VARY, MAX_N_FILES=MAX_N_FILES,$
  THERMAL_STOP=THERMAL_STOP 

n_beams=n_elements(beam)

IF  keyword_set(LOUD) then time=systime(1)
if file_test(folder,/DIRECTORY) ne 1 then $
    spawn, 'mkdir '+folder
IF NOT keyword_set(GIF_DIR) then GIF_DIR=folder+'gifs/'
if file_test(GIF_DIR,/DIRECTORY) ne 1 then begin
    GIF_DIR= folder+'gifs/'
    spawn, 'mkdir '+GIF_DIR
endif

IF size(PLOT_DIR,/TYPE) ne  7 then PLOT_DIR =folder+'/plots/'
if file_test(PLOT_DIR,/DIRECTORY) ne 1 then begin
    PLOT_DIR =folder+'plots/'
    spawn, 'mkdir '+PLOT_DIR
endif

IF NOT keyword_set(MOVIE_DIR) then MOVIE_DIR=folder+'movie_dir/'
if file_test(MOVIE_DIR,/DIRECTORY) ne 1 then begin
    MOVIE_DIR= folder+'movies/'
    spawn, 'mkdir '+MOVIE_DIR
endif
    
IF NOT keyword_set(EXT) THEN EXT='.loop'
IF NOT keyword_set(MOVIE_NAME) THEN MOVIE_NAME='part_movie'
IF NOT keyword_set(FILE_PREFIX) THEN FILE_PREFIX=''
if not keyword_set(FREQ_OUT) then FREQ_OUT=1.
if not keyword_set(MPEG) or $
  keyword_set(PNG)or keyword_set(JAVA) then mpeg=1

current_device=!d.name
set_plot,'x'
device, Set_Resolution=[600,600]
set_plot,'x'
;window,0,xs=800,ys=800
animate_index=1l
pngs='';set the old colors
tvlct,old_r, old_g, old_b, /GET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Set the new colors
tvlct, [0,255,0,0], [0,0,255,0], [0,0,0,255]

tvlct,r,g,b,/get

    png_files=''
j=0ul
for i=0ul, n_beams-1ul ,freq_out do begin
   nt_beam=beam[i].nt_beam
   
   if keyword_set(THERMAL_STOP) then begin
      z=where(nt_beam.state eq 'NT')
      if z[0] eq -1 then goto, no_mas
   endif
   
        index_string= string(j,FORMAT= $  
                             '(I5.5)')
        png_file=png_dir+'/part_disp'+ $
                 '_'+index_string+'.png'

        particle_display, loop,NT_beam,E_min=E_min,E_max=E_max, $
                          WINDOW=WINDOW, $
                          XSIZE=XSIZE, YSIZE=YSIZE, $
                           PLOT_TITLE=PLOT_TITLE,$
                          RUN_FOLDER=RUN_FOLDER, CHARSIZE=CHARSIZE ,$
                          CHARTHICK=CHARTHICK,TIME=loop.state.time,$
                          DIVISIONS=DIVISIONS,VARY=VARY,$
                          XY=XY, C_BAR_POS=C_BAR_POS, $
                          REVERSE=REVERSE, SP_CELLS=SP_CELLS,$
                          font=font, post=post

        spawn, 'convert  '+POST+' '+gif_file
  ;      spawn, "convert  -rotate '-90' "+ $
  ;             gif_file+'  '+gif_file
        
        
        ps_files=[ps_files, POST]
        gif_files=[ gif_files,gif_file]
        J++
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
