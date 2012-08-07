;.run max_velocity_script
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
     files=file_search(folders[i],'T_*loop', $
                    /FULLY_QUALIFY_PATH )
     help, files
     if files[0] ne '' then begin
         BREAK_FILE,FILES[0] , DISK_LOG, DIR, FILNAM, EXT
         print, files[0]
         TITLE1=strsplit(FILES[0], '/', /extract, COUNT=WORD_COUNT)
         print, title1
         TITLE1=reform(TITLE1[WORD_COUNT-1])
         print, title1
         words=strsplit(TITLE1,'loop', /extract,COUNT=WORD_COUNT)
         words2=strsplit(words[0],'00001', /extract)
         TITLE=words[0]
         print, title
         max_velocity_display, folders[i], FILE_PREFIX='a*', $
           EXT='.loop', PS=DIR[0]+TITLE1+'_velocity_plot.ps', TITLE=TITLE1, /MACH
         print, DIR[0]+TITLE1+'_velocity_plot.ps'
         spawn_cmd='scp '+DIR[0]+TITLE1+'_velocity_plot.ps'+ $
                   ' mithra.physics.montana.edu:/www/winter/Piet/'
         ;print, spawn_cmd
         spawn,spawn_cmd
     endif
     

 endfor



end_jump:
END
