data_dir=getenv('DATA')

;folders=['2007_MAY_10a',$
;        '2007_MAY_10b',$
;        '2007_MAY_10c',$
;        '2007_MAY_10d',$
;        '2007_MAY_10e',$
;        '2007_MAY_10f',$       
;        '2007_MAY_09a',$       
;        '2007_MAY_09b',$        
;        '2007_MAY_07a',$         
;        '2007_MAY_07b',$         
;        '2007_MAY_07c',$         
;        '2007_MAY_07d' ]
;'',$

folders=['2007_MAY_14a',$
         '2007_MAY_14b',$
         '2007_MAY_14c',$
         '2007_MAY_14d',$
         '2007_MAY_14e',$
         '2007_MAY_14f',$
         '2007_MAY_15a',$
         '2007_MAY_15b',$
         '2007_MAY_15c',$
         '2007_MAY_15d',$
         '2007_MAY_15e',$
         '2007_MAY_15f',$
         '2007_MAY_16a',$
         '2007_MAY_16b',$
         '2007_MAY_16c',$
         '2007_MAY_16d',$
         '2007_MAY_16e',$
         '2007_MAY_16f',$
         '2007_MAY_18a',$
         '2007_MAY_18b',$
         '2007_MAY_20a',$
         '2007_MAY_20b',$
         '2007_MAY_20c',$
         '2007_MAY_20d',$
         '2007_MAY_20e',$
         '2007_MAY_20f',$
         '2007_MAY_20g',$
         '2007_MAY_23g']



folders_w_path=data_dir+'/PATC/runs/'+ folders+'/'
cd ,data_dir+'/PATC/runs/'
for i=0, n_elements(folders_w_path)-1UL do begin
    print, 'Now working on folder: ' +folders_w_path[i]
    
    spawn_command='tar -czvvf '+folders[i]+'.tar.gz '+ folders_w_path[i]
    print, spawn_command
    spawn, spawn_command,results
    delete_command='rm -Rf '+ folders_w_path[i]
    print, delete_command
    spawn, delete_command,results

endfor


END
        
