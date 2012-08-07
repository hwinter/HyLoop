
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
data_dir=getenv('DATA')+'/PATC/runs/'

CORONA_ONLY=1
prefix='T='
suffix='.loop'
PS='grid_comparison.ps'
TEXT_FILE='grid_comparison.txt'
NAME_ARRAY=[ 'N_Depth=25 N_Corona=500/',$
             'N_Depth=25 N_Corona=1000/',$
             'N_Depth=50 N_Corona=500/',$
             'N_Depth=50 N_Corona1000/']

subdirs=[ 'n_depth=25_n_cells=500/',$
          'n_depth=25_n_cells=1000/',$
          'n_depth=50_n_cells=500/',$
          'n_depth=50_n_cells=1000/']


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Make the run play nice
spawn,'renice 4 -u winter'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
n_subdirs=n_elements(subdirs)
cd, data_dir
dirs=file_search('./', 'alpha=*', /TEST_DIRECTORY, $
                 /FULLY_QUALIFY_PATH,COUNT=N_DIRS)


if n_subdirs gt 11 then begin
    print, 'Compare loops can only handle 11 loops at a time.'
    goto, end_jump
endif
for i=0ul, n_elements(dirs)-1ul do begin
    delvarx,l0,l1,l2,l3,l4,l5,l6,l7,l8,l9, /FREE_MEM
    delvarx,l10, /FREE_MEM
    cd ,dirs[i]
    n_files_max=1d35
    
    for j=0ul,n_subdirs-1ul do begin
        cd , dirs[i]+'/'+subdirs[j]
        files =file_search('./', prefix+'*'+suffix,  $
                           /FULLY_QUALIFY_PATH,COUNT=N_FILES)
        n_files_max<=N_FILES
    endfor
    
    for j=0ul,n_subdirs-1ul do begin
        
        cd ,dirs[i]+'/'+subdirs[j]
        files =file_search('./', prefix+'*'+suffix,  $
                           /FULLY_QUALIFY_PATH,COUNT=N_FILES)
        restore, files[ulong(n_files_max-1ul)]
        case 1 of 
            (j eq 00ul):  l0=loop
            (j eq 01ul):  l1=loop
            (j eq 02ul):  l2=loop
            (j eq 03ul):  l3=loop
            (j eq 04ul):  l4=loop
            (j eq 05ul):  l5=loop
            (j eq 06ul):  l6=loop
            (j eq 07ul):  l7=loop
            (j eq 08ul):  l8=loop
            (j eq 09ul):  l9=loop
            (j eq 10ul):  l10=loop
        endcase
    endfor

    if keyword_set(PS) then $
      PS_NAME=dirs[I]+'/'+PS

    if keyword_set(EPS) then $
      EPS_NAME=dirs[I]+'/'+EPS

    if keyword_set(TEXT_FILE) then $
      TEXT_FILE_NAME=dirs[I]+'/'+TEXT_FILE
    
    compare_loops, l0,l1,l2,l3,l4,l5,l6,l7,l8,l9,l10,$
          LOOP_TEMPLATE=LOOP_TEMPLATE, $
          t_percent_diff=t_percent_diff, $
          PS=PS_NAME, MACH=MACH, $
          EPS=EPS_NAME, FONT=FONT, $
          CHARSIZE=CHARSIZE, $
          CHARTHICK=CHARTHICK, THICK=THICK,$
          LINESTYLE=LINESTYLE,$
          NAME_ARRAY=NAME_ARRAY,$
          CORONA_ONLY=CORONA_ONLY,$
          TEXT_FILE=TEXT_FILE_NAME
endfor
end_jump:
end
