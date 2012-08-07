folder_pattern='2007_MAY*'

data_dir=getenv('DATA')
data_dir=data_dir+'/PATC/runs/'
;print, folder_pattern

folders=file_search(data_dir, folder_pattern , $
                    /TEST_DIRECTORY , /MARK_DIRECTORY, $
                    /FULLY_QUALIFY_PATH )

if folders[0] eq '' then begin
    print, 'No folders found!'
    goto, end_jump
endif

 for i=0UL, n_elements(folders)-1 do begin
     print, 'On Folder: '+folders[i]
     help, files
     cd , folders[i]
     files=file_search('a*.loop' )
     prefix=file_search('T_*' )
     if files[0] ne '' and prefix[0] ne '' then begin
         for j=0UL, n_elements(files)-1ul do begin
             restore, files[j]
             save,/var, file=prefix[0]+files[j]
                 
             endfor

             print, ' renamed ' +string(n_elements(files))+' files.'
         endif




 endfor



end_jump:
END
