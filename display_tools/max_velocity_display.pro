pro max_velocity_display, folders, FILE_PREFIX=FILE_PREFIX, $
  EXT=EXT, POST=POST, TITLE=TITLE, MACH=MACH, EPS=EPS, FONT=FONT, $
  CHARSIZE=CHARSIZE, CHARTHICK=CHARTHICK, THICK=THICK,$
  LINESTYLE=LINESTYLE, TMK=TMK, LENGTH=LENGTH, PSYM=PSYM,$
  YS=YS, XS=XS,$
;Legend keywords
  LABELS=LABELS,BOX=BOX, RIGHT=RIGHT,$
  BOTTOM=BOTTOM, CENTER=CENTER, $
  HORIZONTAL=HORIZONTAL, TOP=TOP, $
;Annotation Keywords:
  ANNOTATION=ANNOTATION,ABOX=ABOX, ARIGHT=ARIGHT,$
  ABOTTOM=ABOTTOM, ACENTER=ACENTER, $
  AHORIZONTAL=AHORIZONTAL, ATOP=ATOP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Check on keywords
if size(folder,/TYPE) eq 0 then folder='./'
if not keyword_set(FILE_PREFIX) then FILE_PREFIX=''
if not keyword_set(TITLE) then TITLE=''
if not keyword_set(EXT) then EXT='.loop'
if not keyword_set(FONT) then FONT=0
if not keyword_set(CHARSIZE) then CHARSIZE=1.7
if not keyword_set(CHARTHICK) then CHARTHICK=1.7
if not keyword_set(THICK) then THICK=2
if not keyword_set(LINESTYLE) then LINESTYLE=0
if size(MACH,/TYPE) eq 0 then MACH=0  
if MACH gt 0 then YTITLE='Mach #' else YTITLE='km s!e-1!n'
If keyword_set(POST) then PS=POST

XTITLE='Time [s]'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Encapsulated PS file
if keyword_set(EPS) then begin
    if size(EPS, /TYPE) ne 7 then EPS='max_velocity.eps' 
    
endif
;Regular PS file
if keyword_set(PS) then begin
    if size(PS, /TYPE) ne 7 then PS='max_velocity.ps'
endif 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Check to see if there are any files to get.  
; If not, then don't waste time.
n_folders=n_elements(folders)
files_count=lonarr(n_folders)
for i=0ul, n_folders -1ul do begin
    print, 'Looking for file pattern ', folders[i]+'/'+FILE_PREFIX+'*'+EXT
    files = file_search(folders[i],FILE_PREFIX+'*'+EXT ,count=count )
    files_count[i]=count
    if files[0] eq '' then begin
        print, 'No files found in folder '+folder+ $
               'matching the pattern '+FILE_PREFIX+'*'+EXT+'.'
        goto, end_jump
        
    endif
        print, 'Sucess with', string(n_elements(files)), ' files.' 

endfor


time_array=dblarr(max(files_count), n_folders)+ !VALUES.F_NAN
max_v_array=dblarr(max(files_count), n_folders)+ !VALUES.F_NAN

for i=0ul, n_folders -1ul do begin
    files = file_search(folders[i],FILE_PREFIX+'*'+EXT )
    for j=0UL, n_elements(files)-1UL do begin
                                ;print, 'restoring file:',files[i]
        restore, files[j]
        
        if MACH gt 0 then begin
            cs=get_loop_sound_speed(loop[0])
            temp_max_v=max(abs(loop[0].state.v/cs))
        endif else temp_max_v=max(abs(loop[0].state.v/(1d5)))
        
          time_array[j,i]=loop[0].state.time
          max_v_array[j,i]=temp_max_v
      endfor

    
endfor



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Needs to be changed for general behaviour.
if keyword_set(TMK) then TMK='T= '+$
  strcompress(string(TMK), /remove) $
  + ' K' else TMK=''
if keyword_set(LENGTH) then LENGTH ='L= '+ $
  strcompress(string(LENGTH), /remove) $
  + ' cm' else LENGTH=''
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if tmk ne '' or LENGTH ne '' then begin
    annotation= [TMK, LENGTH]
    aright=1

endif

 hdw_pretty_plot1,time_array,max_v_array, $
  FONT=FONT, CHARSIZE=CHARSIZE, $
  CHARTHICK=CHARTHICK,TITLE=TITLE, $
  YTITLE=YTITLE,XTITLE=XTITLE,$ 
  POST=POST, EPS=EPS,  PSYM=PSYM,$
  YS=YS, XS=XS,$
  LCHARTHICK=LCHARTHICK, $
  LCHARSIZE=LCHARSIZE,$
;Legend keywords:
  LABELS=LABELS,BOX=BOX, RIGHT=RIGHT,$
  BOTTOM=BOTTOM, CENTER=CENTER, $
  HORIZONTAL=HORIZONTAL, TOP=TOP, $
;Annotation Keywords:
  ANNOTATION=ANNOTATION,ABOX=ABOX, ARIGHT=ARIGHT,$
  ABOTTOM=ABOTTOM, ACENTER=ACENTER, $
  AHORIZONTAL=AHORIZONTAL, ATOP=ATOP







end_jump:
END ;Of main
