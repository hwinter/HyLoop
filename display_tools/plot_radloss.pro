;;+
;NOT FINIHED!
; NAME:
;	
;
; PURPOSE:
;	produce a PostScript (tm) plot of the radiative losses of a
;         loop model
;	
;	
;
; CATEGORY:
;	Loop display tools
;
; CALLING SEQUENCE:
;       plot_radloss,loop,[ref_loop], fname=fname, screen=screen, verbose=verbose, $
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
pro plot_radloss, loop, loop2, fname=fname, screen=screen, verbose=verbose, $
                  LINESTYLE=LINESTYLE, WINDOW=WINDOW,$
                  XRANGE=XRANGE, YRANGE=YRANGE,$
                  CS=CS, MACH=MACH, FONT=FONT,XSIZE=XSIZE, YSIZE=YSIZE ,$
                  CHARSIZE=CHARSIZE, CHARTHICK=CHARTHICK,$
                  PLOT_LINE=PLOT_LINE, TITLE=TITLE, LOG=LOG,$
                  THICK=THICK, EPS=EPS, PS=PS, no_chromo=no_chromo
  
  
  compile_opt strictarr
  color=1
  n_loops=n_elements(loop)
  t0=1d4
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;figure out grid size
  N = n_elements(loop[0].state.v) 
  if keyword_set(no_chromo) then begin
     ind_strt=loop[0].n_depth
     ind_end=N-1-loop[0].n_depth
  end else begin
     ind_strt=1
     ind_end=N-1
  endelse

  if not keyword_set(FONT) then begin
     if keyword_set(SCREEN) THEN FONT=-1 else FONT=0
  endif
  if not keyword_set(TITLE) THEN TITLE='Density Plot'
  if not keyword_set(XRANGE) then BEGIN
     if not keyword_set(LOG) then $
        XRANGE=[min(loop[0].s_alt[ind_strt:ind_end]), max(loop[0].s_alt[ind_strt:ind_end])] $
     else XRANGE=[min(loop[0].s[ind_strt:ind_end])+1., max(loop[0].s[ind_strt:ind_end])]
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
;Calculate the mean radiative loss
  
  rad= get_loops_avg_rad_loss(loop, STD_DEV=STD_DEV)
  if size(loop2, /TYPE) ne 0 then $    
     rad2= get_loops_avg_rad_loss(loop2, STD_DEV=STD_DEV2)

  YRANGE=[min(rad[ind_strt:ind_end]-STD_DEV[ind_strt:ind_end])*.9,$
          max(rad[ind_strt:ind_end]+STD_DEV[ind_strt:ind_end])*1.1]

  if not keyword_set(screen) then begin
     prev_display = !d.name
     set_plot,'ps'
     if n_elements(fname) eq 0 then fname = 'radloss_plot.ps'
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
  t=get_loop_temp(loop)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Plot the Electron Density	
  plot, loop[0].s_alt[ind_strt:ind_end],rad[ind_strt:ind_end], $
        charsize=CHARTHICK_IN, LINESTYLE=LINESTYLE ,  $
        XRANGE=XRANGE,$; YRANGE=YRANGE, XS=1,  $
        FONT=FONT,$             ; _EXTRA=gang_plot_pos(2,2,1),  $
        ystyle=1,  $
        XGRID=1, YGRID=1, XTICKLEN=1, YTICKLEN=1,$
        /NODATA, THICK=THICK,$; /YLOG,$
        YTITLE='n!De!N [cm!E-3!n]',$
        xtitle='Loop Coord.(s) [cm]'

;Plot the loop center
;oplot, [midpt,midpt],[0,1d30], LINESTYLE=5

  if size(loop2, /TYPE) ne 0 then  begin

  ;   if keyword_set(PLOT_LINE) then $
        oplot,   loop2[0].s_alt[ind_strt:ind_end],rad2[ind_strt:ind_end],COLOR=fsc_color('red'), $ ;color_array[2], $
                 LINESTYLE=LINESTYLE, thick=10 ;$ ;LTHICK $
   ;  else $
        oplot,   loop2[0].s_alt[ind_strt:ind_end],rad2[ind_strt:ind_end], psym=PSYM, $
                 SYMSIZE=SYMSIZE, COLOR=3 ;color_array[2]

         

     endif

;for i=0ul,  n_loops-1ul do begin
 ;    if keyword_set(PLOT_LINE) then $
        oplot,   loop[0].s_alt[ind_strt:ind_end],rad[ind_strt:ind_end],COLOR=1,$ ;color_array[i], $
                 LINESTYLE=LINESTYLE, thick=LTHICK ;$
 ;    else $
        oplot,   loop[0].s_alt[ind_strt:ind_end],rad[ind_strt:ind_end], psym=PSYM, $
                 SYMSIZE=SYMSIZE, COLOR=1 ;color_array[i]

;endfor

     ERRPLOT, loop[0].s_alt[ind_strt:ind_end],rad[ind_strt:ind_end]-STD_DEV[ind_strt:ind_end], $
              rad[ind_strt:ind_end]+STD_DEV[ind_strt:ind_end], COLOR=1 ;color_array[i]


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  xyouts, extra.position[2],extra.position[3]*1.01, tstring,$
          FONT=FONT,/NORMAL,$
          CHARSIZE=CHARSIZ_IN, CHARTHICK=CHARTHICK_IN
  xyouts, extra.position[0]*1.05,extra.position[3]*1.01, $
          title,/NORMAL,FONT=FONT,$
          CHARSIZE=CHARSIZE_IN, CHARTHICK=CHARTHICK_IN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  if not keyword_set(screen) then begin
     device, /CLOSE
     set_plot, prev_display
  endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Reset to the old colors
  tvlct,old_r, old_g, old_b
  if size(old_win, /TYPE) ne 0 then wset, old_win


END                             ;Of stateplot3.pro







