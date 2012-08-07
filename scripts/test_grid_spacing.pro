;Test the old, incorrect scaling, to new scaling
;.r compare_temps_and_velocities
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;pro test_grid_spacing
set_plot, 'z'
data_dir=getenv('DATA')+'/PATC/runs/'
top_dir=data_dir+'piet_scaling_laws/'
top_dirs=top_dir+['Const_flux/']
                 


;'alpha=-2.5_beta=2.0/', $
;subdir=['n_depth=25_n_cells=500/']  
   
    
P_L_dirs=['alpha=-2.5_beta=0.0/', $
          'alpha=-2.4_beta=0.0/', $
          'alpha=-2.0_beta=0.0/', $
          'alpha=-1.5_beta=0.0/', $
          'alpha=-1.0_beta=0.0/', $
          'alpha=-0.5_beta=0.0/', $
          'alpha=0.5_beta=0.0/', $
          'alpha=1.0_beta=0.0/', $
          'alpha=1.5_beta=0.0/', $
          'alpha=2.0_beta=0.0/', $
          'alpha=2.5_beta=0.0/']


subdirs=['n_depth=25_n_cells=500/', $
         'n_depth=25_n_cells=1000/', $
         'n_depth=50_n_cells=500/',  $
         'n_depth=50_n_cells=1000/']

LABELS=['ND=25 NC=500/', $
        'ND=25 NC=1000/', $
        'ND=50 NC=500/',  $
        'ND=50 NC=1000/']
n_dirs=n_elements(P_L_dirs)
n_subdirs=n_elements(subdirs)

CORONA_ONLY=1
prefix='T='
suffix='.loop'
POST=top_dirs+'plots/'+'grid_spacing_test'
font=1      
TEXT_FILE='grid_test.txt'
Title='Grid Test'
;NAME_ARRAY=[ 'Serio Scaled','Avg. P!D0!N', 'Const P!D0!N']
LANDSCAPE=1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Make the run play nice
spawn,'renice 4 -u winter'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

colors=[1,2,3]
if keyword_set(Eps) or  keyword_set(PS) then $
  colors=[colors, 4] else  colors=[colors, 255]
;Linestyles
lines=[0,2,3,4,5]
n_colors=n_elements(colors)
n_lines=n_elements(lines)

color_array=colors[0]
lines_array=lines[0]
for i=1, n_subdirs-1 do begin
    color_array=[color_array,colors[i mod n_colors]]
    lines_array=[lines_array, lines[fix(i/n_colors)]]
    if keyword_set(PSYM) then $
      psym_array=[psym_array, PSYM[fix(i/n_colors)]]
endfor

for i=0ul, n_dirs-1ul do begin
    
    delvarx, temp_loop_files,loops_files,array_0t,$
             ps_array
    min_files=1d+36
        
    for j=0ul, n_subdirs-1ul do begin
        cd , top_dirs[0]+P_L_dirs[i]+subdirs[j]
        temp_loop_files=file_search(top_dirs[0]+$
                                    P_L_dirs[i]+subdirs[j],$
                                    prefix+'*'+suffix, $
                                    COUNT=N_loops, $
                                    /FULLY_QUALIFY_PATH)
       if N_loops gt 0 then  min_files<=N_loops
        
    endfor

    loops_files=strarr(min_files,n_subdirs)
    for j=0ul, n_subdirs-1ul do begin
        cd , top_dirs[0]+P_L_dirs[i]+subdirs[j]
        temp_loop_files=file_search(top_dirs[0]+$
                                    P_L_dirs[i]+subdirs[j],$
                                    prefix+'*'+suffix, $
                                    COUNT=N_loops, $
                                    /FULLY_QUALIFY_PATH)
            
        loops_files[0,j]=temp_loop_files[0:min_files-1ul]
        
    endfor
    




    for h=0ul, min_files-1ul do begin
        for j=0ul, n_subdirs-1ul do begin
            cd , top_dirs[0]+P_L_dirs[i]+subdirs[j]
            restore, 'startup_vars.sav'
            title=['!9a!3='+ALPHA_STRING+' !9b!3='+Beta_STRING]
            set_plot, 'ps'
            ps=strcompress($
                           top_dirs[0]+P_L_dirs[i]+$
                           POST+'_'+string(h, format='(i05)'),$
                                           /remove_all)+'.ps'
            gif_file=strcompress($
                           top_dirs[0]+P_L_dirs[i]+$
                           POST+'_'+string(h, format='(i05)'),$
                                           /remove_all)+'.gif'
            if size(ps_array, /type) eq 0 then $
              ps_array=ps else ps_array=[ps_array, ps]
            if size(gif_array, /type) eq 0 then $
              gif_array=ps else gif_array=[gif_array, ps]

            device, /COLOR, BITS=8, /LANDSCAPE, FILE=PS
            print, ' saving file: ' +PS
            restore, loops_files(h,j)

            if j eq 0 then begin
                plot, loop.s_alt, get_loop_temp(loop), $
                      YTITLE=YTITLE,XTITLE=XTITLE,TITLE=TITLE,$
                      FONT=FONT, CHARSIZE=CHARSIZE, CHARTHICK=CHARTHICK,$
                      /NODATA,XRANGE=xrange,YRANGE=yrange,$
                      XSTYLE=XS, YSTYLE=YS,$
                      _EXTRA=gang_plot_pos(1,2,0),$
                      color=color_array[0], linestyle=lines_array[0]
                
                Legend, LABELS ,$
                        LINESTYLE=lines_array,$
                        COLOR=color_array,$
                        BOX=BOX, /RIGHT,$
                        BOTTOM=BOTTOM, CENTER=CENTER, $
                        HORIZONTAL=HORIZONTAL, /TOP, $
                        CHARTHICK=LCHARTHICK, $
                        CHARSIZE=LCHARSIZE,$
                        FONT=FONT
                Legend, string(loop.state.time,$
                               format='(i05)'),$
                        BOX=BOX, /RIGHT,$
                        BOTTOM=BOTTOM,  $
                        HORIZONTAL=HORIZONTAL, /TOP, $, $
                        CHARTHICK=CHARSIZE, $
                        CHARSIZE=CHARTHICK, $
                        FONT=FONT
            endif else $
              oplot, loop.s_alt, get_loop_temp(loop),$
                      color=color_array[j], linestyle=lines_array[j]
            if j eq 0 then begin
                plot, loop.s_alt, loop.state.v, $
                      YTITLE=YTITLE,XTITLE=XTITLE,TITLE=TITLE,$
                      FONT=FONT, CHARSIZE=CHARSIZE, CHARTHICK=CHARTHICK,$
                      /NODATA,XRANGE=xrange,YRANGE=yrange,$
                      XSTYLE=XS, YSTYLE=YS,$
                      _EXTRA=gang_plot_pos(1,2,1),$
                      color=color_array[0], linestyle=lines_array[0]
                
                
                Legend, LABELS ,$
                        LINESTYLE=lines_array,$
                        COLOR=color_array,$
                        BOX=BOX, /RIGHT,$
                        BOTTOM=BOTTOM, CENTER=CENTER, $
                        HORIZONTAL=HORIZONTAL, /TOP, $
                        CHARTHICK=LCHARTHICK, $
                        CHARSIZE=LCHARSIZE,$
                        FONT=FONT
                Legend, string(loop.state.time,$
                               format='(i05)'),$
                        BOX=BOX, /RIGHT,$
                        BOTTOM=BOTTOM,  $
                        HORIZONTAL=HORIZONTAL, /TOP, $, $
                        CHARTHICK=CHARSIZE, $
                        CHARSIZE=CHARTHICK, $
                        FONT=FONT

            endif else $
              oplot, loop.s_alt, get_loop_temp(loop),$
                     color=color_array[j], linestyle=lines_array[j]
                
                
              device, /CLOSE
              
        spawn, 'convert  '+Ps+' '+gif_file
        spawn, "convert  -rotate '-90' "+ $
               gif_file+'  '+gif_file
    endfor

          
        
    image2movie,gif_files, $
                movie_name=movie_dir[i]+movie_name,$
                /mpeg,$         ;/java,$
                scratchdir=scratchdir[i] ;,$;nothumbnail=1,$
                ;/nodelete
    
        
    endfor

endfor


end_jump:
end
