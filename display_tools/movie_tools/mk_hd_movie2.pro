pro mk_hd_movie2, folder,$
                  GIF_DIR=GIF_DIR,EXT=EXT,$
                  MOVIE_NAME=MOVIE_NAME,$
                  FILE_PREFIX=FILE_PREFIX,$
                  LOUD=LOUD, JS=JS,$
                  FREQ_OUT=FREQ_OUT, $
                  CS=CS

IF  keyword_set(LOUD) then time=systime(1)
if size(folder,/TYPE) ne 7 then folder='./'
IF NOT keyword_set(GIF_DIR) then GIF_DIR='./gifs/'
if file_test(GIF_DIR,/DIRECTORY) ne 1 then GIF_DIR= './'
IF NOT keyword_set(EXT) THEN EXT='.loop'
IF NOT keyword_set(MOVIE_NAME) THEN MOVIE_NAME='hd_movie'
IF NOT keyword_set(FILE_PREFIX) THEN FILE_PREFIX=''
if not keyword_set(FREQ_OUT) then FREQ_OUT=1.

files=file_search(folder,FILE_PREFIX+'*'+EXT, COUNT=FILE_COUNT)

if FILE_count eq 0 then begin
    MESSAGE, 'No files matching *'+ext+' were found', /CONTINUE
    goto, end_jump
endif
current_device=!d.name
set_plot,'z'
device, Set_Resolution=[600,600]
;set_plot,'x'
;window,0,xs=800,ys=800
animate_index=1l
gifs='';set the old colors
tvlct,old_r, old_g, old_b, /GET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Set the new colors
tvlct, [0,255,0,0], [0,0,255,0], [0,0,0,255]

tvlct,r,g,b,/get

FILE_COUNT<=600
 for i=0ul, FILE_COUNT-1ul ,freq_out do begin
         IF  keyword_set(LOUD) then begin
             print, 'working on file '+files[i]
             print,'########################################################################'
         endif
         
         restore, files[i]
         stateplot2, loop[0].s,loop[0].state, /screen, cs=cs
         if size(plot_array,/TYPE) eq 0 then $
           plot_array=tvrd() else $
           plot_array=[[[temporary(plot_array)]],[[tvrd()]]]
 endfor

;image2movie,plot_array,r,g,b, $
;  movie_name=strcompress(gif_dir+'/'+MOVIE_NAME,/REMOVE_ALL), $
;  scratchdir=gif_dir,gif_animate=1,loop=1


image2movie,plot_array,r,g,b, $
  movie_name=MOVIE_NAME, $
  mpeg=1,scratchdir=gif_dir;gif_animate=1,loop=1

junk=delete_file(gifs)
set_plot,current_device

;Reset to the old colors
tvlct,old_r, old_g, old_b
IF  keyword_set(LOUD) then print, 'Mk_hd_movie took '+string((systime(1)-time)/60.)+' minutes to run.'
end_jump:
end
