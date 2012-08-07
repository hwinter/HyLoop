pro mk_hd_movie3, folder,$
                  GIF_DIR=GIF_DIR,EXT=EXT,$
                  MOVIE_NAME=MOVIE_NAME,$
                  FILE_PREFIX=FILE_PREFIX,$
                  LOUD=LOUD, JS=JS,$
                  FREQ_OUT=FREQ_OUT, $
                  CS=CS, JAVA=JAVA,$; GIF=GIF,$
                  MPEG=MPEG,LOOP=LOOP, $
                  TITLE=TITLE, MOVIE_DIR=MOVIE_DIR, $
                  VRANGE=VRANGE, MAX_FILES=MAX_FILES


IF  keyword_set(LOUD) then time=systime(1)
if size(folder,/TYPE) ne 7 then folder='./'
IF NOT keyword_set(GIF_DIR) then GIF_DIR='./gifs/'
if file_test(GIF_DIR,/DIRECTORY) ne 1 then GIF_DIR= './'
IF NOT keyword_set(MOVIE_DIR) then MOVIE_DIR='./movies/'
if file_test(MOVIE_DIR,/DIRECTORY) ne 1 then MOVIE_DIR= './'

IF NOT keyword_set(EXT) THEN EXT='.loop'
IF NOT keyword_set(MOVIE_NAME) THEN MOVIE_NAME='hd_movie'
IF NOT keyword_set(FILE_PREFIX) THEN FILE_PREFIX=''
if not keyword_set(FREQ_OUT) then FREQ_OUT=1.
if not keyword_set(MPEG) or $
  keyword_set(GIF)or keyword_set(JAVA) then mpeg=1
;if not keyword_set(w
files=file_search(folder,FILE_PREFIX+'*'+EXT, COUNT=FILE_COUNT)

if FILE_count eq 0 then begin
    MESSAGE, 'No files matching *'+ext+' were found', /CONTINUE
    goto, end_jump
 endif

if KEYWORD_SET(MAX_FILES) then FILE_COUNT<=MAX_FILES

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

    ps_files=''
    gif_files=''
j=0ul
 for i=0ul, FILE_COUNT-1ul ,freq_out do begin
         IF  keyword_set(LOUD) then begin
             print, 'working on file '+files[i]
             print,'########################################################################'
         endif
         
         restore, files[i]
         
        index_string= string(j,FORMAT= $  
                    '(I5.5)')
        POST=gif_dir+'hd_plot'+ $
             '_'+index_string+'.ps'
        gif_file=gif_dir+'hd_plot'+ $
                 '_'+index_string+'.gif'
        stateplot3, loop, fname=POST,  verbose=verbose, $
                    LINESTYLE=LINESTYLE, VRANGE=VRANGE,$
                   ; XRANGE=XRANGE,TRANGE=TRANGE, DRANGE=DRANGE,PRANGE=PRANGE ,$
                    FONT=FONT,XSIZE=XSIZE, YSIZE=YSIZE ,$
                    CHARSIZE=CHARSIZE, CHARTHICK=CHARTHICK,$
                    PLOT_LINE=PLOT_LINE, TITLE=TITLE, LOG=LOG, $
                    CS=CS
        spawn, 'convert  '+POST+' '+gif_file
        spawn, "convert  -rotate '-90' "+ $
               gif_file+'  '+gif_file
        
        
        ps_files=[ps_files, POST]
        gif_files=[ gif_files,gif_file]
        J++
    endfor


;image2movie,plot_array,r,g,b, $
;  movie_name=strcompress(gif_dir+'/'+MOVIE_NAME,/REMOVE_ALL), $
;  scratchdir=gif_dir,gif_animate=1,loop=1


    n_files=n_elements(ps_files)
    ps_files=ps_files[1:n_files-1ul]
    gif_files=gif_files[1:n_files-1ul]
    image2movie,gif_files, $
                movie_name=movie_dir+movie_name,$
                /mpeg,$         ;/java,$
                scratchdir=gif_dir; ,$;nothumbnail=1,$
  ;              /nodelete
  ;  image2movie,gif_files, $
  ;              movie_name=movie_dir+movie_name,$
  ;              /java,$
  ;              scratchdir=gif_dir ,$ ;nothumbnail=1,$
  ;              /nodelete
    ;Remove these unwanted thumbnails.
    spawn,'rm -f  '+gif_dir+'*micon* *mthumb*'
        
    
set_plot,current_device

;Reset to the old colors
tvlct,old_r, old_g, old_b
IF  keyword_set(LOUD) then $
  print, 'Mk_hd_movie took '+string((systime(1)-time)/60.)+' minutes to run.'
end_jump:
end
