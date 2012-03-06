pro mk_pa_v_time_plot, folders1,folders1, $
                  GIF_DIR=GIF_DIR,EXT=EXT,$
                  FILE_PREFIX=FILE_PREFIX,$
                  TITLE=TITLE,$
                  XRANGE=XRANGE




IF  keyword_set(LOUD) then time=systime(1)
if size(folder,/TYPE) ne 7 then folder='./'
IF NOT keyword_set(GIF_DIR) then GIF_DIR='./gifs/'
if file_test(GIF_DIR,/DIRECTORY) ne 1 then GIF_DIR= './'
IF NOT keyword_set(MOVIE_DIR) then MOVIE_DIR='./'
if file_test(MOVIE_DIR,/DIRECTORY) ne 1 then MOVIE_DIR ='./'
IF NOT keyword_set(EXT) THEN EXT='.loop'
IF NOT keyword_set(MOVIE_NAME) THEN MOVIE_NAME='hd_movie_avg'
IF NOT keyword_set(FILE_PREFIX) THEN FILE_PREFIX=''
if not keyword_set(FREQ_OUT) then FREQ_OUT=1.
if not keyword_set(MPEG) or $
  keyword_set(GIF)or keyword_set(JAVA) then mpeg=1
;if not keyword_set(w
n_folders=n_elements(folders)

file_count=1d30

for i=0ul, n_folders-1ul do begin
    files=file_search(folders[i],FILE_PREFIX+'*'+EXT, COUNT=FILE_COUNT_temp)
    file_count=[file_count, FILE_COUNT_temp]
endfor

file_count=min(file_count)
if keyword_set(N_FRAMES) then file_count<=N_FRAMES
files=strarr(file_count, n_folders)

for i=0ul, n_folders-1ul do begin
    files_temp=file_search(folders[i],$
                           FILE_PREFIX+'*'+EXT)
    files[*,i]=files_temp[0:file_count-1]
endfor

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

    ps_files=''
    gif_files=''
j=0ul
 for i=0ul, FILE_COUNT-1ul ,freq_out do begin
     for j=0ul, n_folders-1ul do begin
         restore, files[i,j]
         if j eq 0 then loops=loop else begin
             loop= interpolate_loop( loop, loops[0])
             loops=[loops, loop]

             endelse
         
         endfor
     
         
     
     IF  keyword_set(LOUD) then begin
         print, 'working on file '+files[i]
         print,'########################################################################'
     endif
     
        index_string= string(i,FORMAT= $  
                             '(I5.5)')
        POST=gif_dir+'n_e_plot'+ $
             '_'+index_string+'.ps'
        gif_file=gif_dir+'n_e_plot'+ $
                 '_'+index_string+'.gif'
        stateplot4_ne, loops,loops2, fname=POST,  verbose=verbose, $
                    LINESTYLE=LINESTYLE, VRANGE=VRANGE,$
                    XRANGE=XRANGE,TRANGE=TRANGE, $
                    DRANGE=[1d8,1d10],PRANGE=PRANGE ,$
                    FONT=FONT,XSIZE=XSIZE, YSIZE=YSIZE ,$
                    CHARSIZE=CHARSIZE, CHARTHICK=CHARTHICK,$
                    PLOT_LINE=PLOT_LINE, TITLE=TITLE, LOG=LOG
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
                scratchdir=gif_dir ,$;nothumbnail=1,$
                /nodelete
 ;   image2movie,gif_files, $
 ;               movie_name=movie_dir+movie_name,$
 ;               /java,$
 ;               scratchdir=gif_dir ,$ ;nothumbnail=1,$
 ;               /nodelete
    ;Remove these unwanted thumbnails.
    spawn,'rm -f  '+movie_dir+'*micon* *mthumb*'
        
    
set_plot,current_device

;Reset to the old colors
tvlct,old_r, old_g, old_b
IF  keyword_set(LOUD) then $
  print, 'Mk_hd_movie4 took '+string((systime(1)-time)/60.)+' minutes to run.'
end_jump:
end
