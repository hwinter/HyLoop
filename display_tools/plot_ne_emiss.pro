;;+
;NOT FINIHED!
; NAME:
;	
;
; PURPOSE:
;	produce a PostScript (tm) plot of a loop model
;	state vector. Same as stateplot but no log-log scaling
;	
;
; CATEGORY:
;	Loop display tools
;
; CALLING SEQUENCE:
;       stateplot3,loop, fname=fname, screen=screen, verbose=verbose, $
;	            LINESTYLE=LINESTYLE, VRANGE=VRANGE
;
; INPUTS:
;	x: Array of steps on the surface grid
;       state: loop state structure
;
; OPTIONAL INPUTS:
;	
;	
; KEYWORD PARAMETERS:
;	FNAME: Name of PostScript (tm) file
;       SCREEN: Output display to screen instead of PS file
;       LINESTYLE; Line style of loop
;       VRANGE;  Range of velocity values
 ;
; OUTPUTS:
;	NONE
;
; OPTIONAL OUTPUTS:
;	NONE
;
; COMMON BLOCKS:
;	NONE
;
; SIDE EFFECTS:
;	None found
;
; RESTRICTIONS:
;	
;
; PROCEDURE:
;	
;
; EXAMPLE:
;	stateplot4_ne, loop.s, loop.state, fname=fname, 
;                   /SCREEN, /VERBOSE, $
;                   LINESTYLE=0
;	
;
;Modified by Henry (Trae) Winter III 4/15/2003
;	2003-APR-09 HDWIII added LINESTYLE keyword
;       2006-***-*** HDWIII replaced statements to calculate values 
;                    with new functions to do the same job     
;-
pro plot_ne_emiss, loop,loop2, nt_brems_array,$
                   fname=fname, screen=screen, verbose=verbose, $
                   LINESTYLE=LINESTYLE, VRANGE=VRANGE, WINDOW=WINDOW,$
                   XRANGE=XRANGE,TRANGE=TRANGE, DRANGE=DRANGE,PRANGE=PRANGE ,$
                   CS=CS, MACH=MACH, FONT=FONT,XSIZE=XSIZE, YSIZE=YSIZE ,$
                   CHARSIZE=CHARSIZE, CHARTHICK=CHARTHICK,$
                   PLOT_LINE=PLOT_LINE, TITLE=TITLE, LOG=LOG,$
                   THICK=THICK
                
e_range=[3,6] 
compile_opt strictarr
color=1 
n_loops=n_elements(loop)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;figure out grid size
N = n_elements(loop[0].state.v) 
if not keyword_set(FONT) then begin
    if keyword_set(SCREEN) THEN FONT=-1 else FONT=0
endif
if not keyword_set(TITLE) THEN TITLE='Density Plot'
if not keyword_set(XRANGE) then BEGIN
    if not keyword_set(LOG) then $
      XRANGE=[min(loop[0].s_alt), max(loop[0].s_alt)] $
             else XRANGE=[min(loop[0].s)+1., max(loop[0].s)]
endif
;if keyword_set(CS) or  keyword_set(MACH) then BEGIN
;    CS=get_loop_sound_speed(loop[0], /S_GRID)
;    if n_loops gt 1 then $
;      for i=1ul, n_loops-1ul do cs=[[cs], [get_loop_sound_speed(loop[i], /S_GRID)]]
;    VYTITLE='Mach #' 
;endif ELSE BEGIN 
;        CS=1d0+dblarr(N, n_loops)
;        VYTITLE='Velocity (cm s!E-1!N)'
;    ENDELSE
if not keyword_set(CHARSIZE) then CHARSIZE_IN =1.3 else $
  CHARSIZE_IN=CHARSIZE

if not keyword_set(CHARTHICK) then CHARTHICK_IN =1.3 else $
  CHARTHICK_IN=CHARTHICK
if not keyword_set(THICK) then THICK=1.7
if not keyword_set(PSYMTHICK) then SYMSIZE=1.5 else $
  SYMSIZE=PSYMTHICK
if not keyword_set(LINE_THICK) then LTHICK=1.5 else $
  LTHICK=LINE_THICK

;PYTITLE='P (dyn cm!E-2!N)'
;TYTITLE='T (K)'
DYTITLE='n!Be!N (cm!E-3!N)'

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;set the old colors
tvlct,old_r, old_g, old_b, /GET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Set the new colors: 0 results in black, 1 in red, 2 in green, 
; and 3 in blue
tvlct, [0,255,0,0], [0,0,255,0], [0,0,0,255]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
colors=[1,2,3]
if keyword_set(Eps) or  keyword_set(PS) then $
  colors=[colors, 4] else  colors=[colors, 255]
;Linestyles
lines=[0,2,3,4,5]
n_colors=n_elements(colors)
n_lines=n_elements(lines)

color_array=colors[0]
lines_array=lines[0]
if keyword_set(PSYM) then psym_array=psym[0]

for i=1, n_loops-1 do begin
    color_array=[color_array,colors[i mod n_colors]]
    lines_array=[lines_array, lines[fix(i/n_colors)]]
    if keyword_set(PSYM) then $
      psym_array=[psym_array, PSYM[fix(i/n_colors)]]
endfor
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;find midpoint along loop[0]
midpt = max(loop[0].s_alt)/2.0 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Calculate the mean pressure
;p=get_loops_avg_p(loop,STD_DEV=std_p)
;Calculate the mean number_density
n_e=get_loops_avg_n_e(loop,STD_DEV=std_n_e)
if size(loop2, /TYPE) ne 0 then $
  ;n_e2=get_loops_avg_n_e(loop2,STD_DEV=std_n_e2)
  n_e2=loop2.state.n_e
;v=get_loops_avg_v(loop,STD_DEV=std_V, MACH=MACH)
;Calculate the mean temperature 
;T=get_loops_avg_temp(loop,STD_DEV=std_t)
;
;if not keyword_set(TRANGE) then $
;  TRANGE=[min(T-std_t)*.9, max(T+std_t)*1.1]
;if not keyword_set(PRANGE) then $
;  PRANGE=[min(P-std_P)*.9, max(P+std_P)*1.1]

;if not keyword_set(DRANGE) then $
  DRANGE=[min(n_e-std_n_e)*.9,$
          max(n_e+std_n_e)*1.1]
;if not keyword_set(VRANGE) then $
;  VRANGE=[min(V-std_V)*.9,$
;          max(V+std_V)*1.1]

if not keyword_set(screen) then begin
	prev_display = !d.name
	set_plot,'ps'
	if n_elements(fname) eq 0 then fname = 'stateplot.ps'
         FONT=0
         device, /COLOR, FILE=fname, /LANDSCAPE
         SYMSIZE=.1
         ;The PS device won't plot psm=1!  What a jip!
         PSYM=2
         LTHICK=LTHICK*4
         SYMSIZE=SYMSIZE*4
         charsize_in=charsize_in
         CHARTHICK_IN=CHARTHICK_IN

         
    endif ELSE BEGIN
        PSYM=3
        symsize=7
        FONT=-1
        if !d.name eq 'X' then begin 
            device, WINDOW_STATE=WS
            if max(ws) ne 0 then old_win=!d.window
        endif
        
        case 1 of 
            (not keyword_set(WINDOW)) and (!d.name eq 'X'):
            (!d.name eq 'X' and  keyword_set(WINDOW)):begin
                if ws[window] eq 1 then wset, window $
                else window, WINDOW,TITLE=!computer+' State Plot' 
            end
            (!d.name eq 'X' and not  keyword_set(WINDOW)): $
              window,TITLE=!computer+' State Plot'
            else:
        endcase
                             
    endelse


tstring = 'Elapsed time = '+string(loop[0].state.time,format='(f9.2)')+' s'
erase
;print,keyword_set(screen)
if keyword_set(LINESTYLE) ne -1 then LINESTYLE=0
extra=gang_plot_pos(2,2,0)


i=0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Plot the Pressure    
;plot, loop[0].s_alt,p, $
;      ytitle=PYTITLE, $
;      charsize=CHARSIZE_IN, CHARTHICK=CHARTHICK_IN,$
;      LINESTYLE=LINESTYLE,  $
;      XRANGE=XRANGE, YRANGE=PRANGE,$
;      XS=1, FONT=FONT,  $
;      /YLOG, _EXTRA=extra,  $
;      XGRID=1, YGRID=1, XTICKLEN=1, YTICKLEN=1,$
;      /NODATA, XLOG=LOG

;Plot the loop center
;oplot, [midpt,midpt], $
;       [0,max(P)*15]
;for i=0ul, n_loops-1ul  do begin
;if keyword_set(PLOT_LINE) then $
;  oplot,  loop[0].s_alt,p,COLOR=color_array[i],$
;          LINESTYLE=LINESTYLE, thick=LTHICK $
;  else $
;  oplot,  loop[0].s_alt,p, $
;          psym=PSYM, SYMSIZE=SYMSIZE, $
;          COLOR=color_array[i]

;ERRPLOT, loop[0].s_alt,P-std_p, P+std_p, COLOR=color_array[i]
;endfor

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Plot the Electron Density	
plot, loop[0].s_alt,n_e, $
      charsize=CHARTHICK_IN, LINESTYLE=LINESTYLE ,  $
      XRANGE=XRANGE, YRANGE=[1d8, 1d10], XS=1,  $
      FONT=FONT,$; _EXTRA=gang_plot_pos(2,2,1),  $
      ystyle=1,  $
      XGRID=1, YGRID=1, XTICKLEN=1, YTICKLEN=1,$
      /NODATA, THICK=THICK, /YLOG,$
      YTITLE='n!De!N [cm!E-3!n]',$
      xtitle='Loop Coord.(s) [cm]'

;Plot the loop center
;oplot, [midpt,midpt],[0,1d30], LINESTYLE=5

if size(loop2, /TYPE) ne 0 then  begin

    if keyword_set(PLOT_LINE) then $
      oplot,   loop2[0].s_alt,n_e2,COLOR=3, $;color_array[2], $
               LINESTYLE=LINESTYLE, thick=10 $ ;LTHICK $
      else $
      oplot,   loop2[0].s_alt,n_e2, psym=PSYM, $
               SYMSIZE=SYMSIZE, COLOR=3;color_array[2]


;for i=0ul,  n_loops-1ul do begin
if keyword_set(PLOT_LINE) then $
  oplot,   loop[0].s_alt,n_e,COLOR=1,$;color_array[i], $
           LINESTYLE=LINESTYLE, thick=LTHICK $
  else $
  oplot,   loop[0].s_alt,n_e, psym=PSYM, $
           SYMSIZE=SYMSIZE, COLOR=1;color_array[i]

;endfor

ERRPLOT, loop[0].s_alt,n_e-std_n_e, n_e+std_n_e, COLOR=1;color_array[i]

signal=get_loops_avg_signal(loops, nt_brems_array, STD_DEV=STD_DEV)



    
;endfor

;    ERRPLOT, loop2[0].s_alt,n_e2-std_n_e2, n_e2+std_n_e2, $
;             COLOR=4;color_array[i]


endif



;axis, /yaxis,  yrange=drange,ytitle=DYTITLE, $
;      FONT=FONT, YGRID=1, XTICKLEN=1, YTICKLEN=1 ,$
;      CHARSIZE=CHARSIZE_IN, CHARTHICK=CHARTHICK_IN

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Plot the Velocity
;plot, loop[0].s,v, $
;      yrange=VRANGE,YSTYLE=8, $
;      ytitle=VYTITLE, xtitle='s (cm)', $ 
;      LINESTYLE=LINESTYLE,$
;      XRANGE=XRANGE, XS=1, FONT=FONT,  $
;      _EXTRA=gang_plot_pos(2,2,2),  $
;      XGRID=1, YGRID=1, XTICKLEN=1, YTICKLEN=1,$
;      XTICKLAYOUT=2,YTICKS=4, $
;      /NODATA, XLOG=LOG,$
;      CHARSIZE=CHARSIZE_IN, CHARTHICK=CHARTHICK_IN ;, YLOG=LOG   

;Plot the loop center
;oplot, [midpt,midpt],[-1d32,1d32], LINESTYLE=5

;for i=0ul,n_loops-1ul do begin
;    if keyword_set(PLOT_LINE) then $
;      oplot, loop[0].s , v,COLOR=color_array[i] , $
;             LINESTYLE=LINESTYLE, THICK=LTHICK $
;      else $
;      oplot, loop[0].s, v, psym=psym,$
;             SYMSIZE=SYMSIZE, COLOR=color_array[i]  
;endfor
;ERRPLOT, loop[0].s,v-std_v, v+std_v, COLOR=color_array[i]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
;Plot the Temperature
;plot, loop[0].s_alt,T, $
;      xtitle='s (cm)', $
;      LINESTYLE=LINESTYLE,  $
;      XRANGE=XRANGE, YRANGE=TRANGE, $
;      XS=1, FONT=FONT, _EXTRA=gang_plot_pos(2,2,3),  $
;      ystyle=21,  $
;      XGRID=1, YGRID=1, XTICKLEN=1, YTICKLEN=1,$
;      XTICKLAYOUT=2,$
;      /NODATA    , XLOG=LOG , YLOG=LOG    ,$
;      CHARSIZE=CHARSIZE_IN, CHARTHICK=CHARTHICK_IN ;
;Plot the loop center
;oplot, [midpt,midpt],[0,1d15], LINESTYLE=5
;for i=0ul,n_loops-1ul do begin
;    if keyword_set(PLOT_LINE) then $
;      oplot, loop[0].s_alt,T,COLOR=color_array[i], $
;             LINESTYLE=LINESTYLE, thick=LTHICK $
;      else $
;      oplot, loop[0].s_alt,T, psym=psym, $
;             SYMSIZE=SYMSIZE, COLOR=color_array[i]
;    
;    ERRPLOT, loop[0].s_alt,T-std_T, T+std_T, COLOR=color_array[i];
;
;    axis, /yaxis,  yrange=TYRANGE,ytitle=TYTITLE, $
;          FONT=FONT, YGRID=1, XTICKLEN=1, YTICKLEN=1,$
;          CHARSIZE=CHARSIZE_IN, CHARTHICK=CHARTHICK_IN
;endfor

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
xyouts, extra.position[2],extra.position[3]*1.01, tstring,$
        FONT=FONT,/NORMAL,$
        CHARSIZE=CHARSIZ_IN, CHARTHICK=CHARTHICK_IN
xyouts, extra.position[0]*1.05,extra.position[3]*1.01, $
        title,/NORMAL,FONT=FONT,$
        CHARSIZE=CHARSIZE_IN, CHARTHICK=CHARTHICK_IN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;if keyword_set(verbose) then begin
;	print,'Temperature range (K):         ',minmax(T)
;	print,'Pressure range (dyne cm^-2):   ',minmax(P)
;	print,'Electron density range (cm^-3):',minmax(n_e)
;	print,'Velocity range (cm s^-1):      ',minmax(v)
;endif
if not keyword_set(screen) then begin
	device, /CLOSE
	set_plot, prev_display
endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Reset to the old colors
tvlct,old_r, old_g, old_b
if size(old_win, /TYPE) ne 0 then wset, old_win

END;Of stateplot3.pro







