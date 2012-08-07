;show_loop_tactical
Data_dir=getenv('DATA')+'/PATC/runs/'
movie_name='tactical_test2.gif'
folder_1=Data_dir+'2007_Jun_11g/'

file_prefix='T=*'
file_ext='.loop'
files1=file_search(folder_1, file_prefix+file_ext, COUNT=FILES1_COUNT)
if FILES1_COUNT eq 0 then stop
    
restore, files1[0]

window, 0,   TITLE='X Axis'
plot, loop.s, loop.axis[0,*], XTITLE='S [cm]',$
      YTITLE='X [cm]', TITLE='X AXIS CHANGE',$
      xr=[min(loop.s),max(loop.s)],$
      yr=[min(loop.axis[0,*]),max(loop.axis[0,*])]


window, 1 , TITLE='Y Axis'
plot, loop.s, loop.axis[1,*], XTITLE='S [cm]',$
       YTITLE='Y [cm]', TITLE='Y AXIS CHANGE',$
      xr=[min(loop.s),max(loop.s)],$
      yr=[min(loop.axis[1,*]),max(loop.axis[1,*])]
        

window, 2 ,TITLE='Z Axis '
plot, loop.s, loop.axis[2,*], XTITLE='S [cm]',$
      YTITLE='Z [cm]', TITLE='Z AXIS CHANGE' ,$
      xr=[min(loop.s),max(loop.s)],$
      yr=[min(loop.axis[2,*]),max(loop.axis[2,*])]


window, 3 ,TITLE='Axis '
plot, loop.axis[1,*], loop.axis[2,*], XTITLE='S [cm]',$
      YTITLE='Z [cm]', TITLE='AXIS CHANGE' ,$
      xr=[min(loop.axis[1,*]),max(loop.axis[1,*])],$
      yr=[min(loop.axis[2,*]),max(loop.axis[2,*])]

window, 4 ,TITLE='Area '
plot, loop.s, loop.a, XTITLE='S [cm]',$
      YTITLE='A [cm!E2!N]', TITLE='area CHANGE' ,$
      xr=[min(loop.s),max(loop.s)]

window, 5 ,TITLE='gravity '
plot, loop.s, loop.g, XTITLE='S [cm]',$
      YTITLE='g ', TITLE='Gravity CHANGE' ,$
      xr=[min(loop.s),max(loop.s)]


window, 6 ,TITLE='B '
plot, loop.s, loop.B, XTITLE='S [cm]',$
      YTITLE='B ', TITLE='B CHANGE' ,$
      xr=[min(loop.s),max(loop.s)]

print, 'min/max s',min( loop.s ), max( loop.s ) 
print,  'min/max y',min( loop.axis[1,*] ), max( loop.axis[1,*] ) 
print,   'min/max z',min( loop.axis[2,*] ), max( loop.axis[2,*] ) 
s_0=loop.s[0]
z_0=    loop.axis[2,0]
s_1=loop.s[1]
print,'s_0, z_0,s_1', s_0, z_0 ,s_1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


for files_index=1UL, FILES1_COUNT-1ul,1 do begin
    print, ';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;'
    print,files1[files_index]
    linestyle=files_index mod 4
    restore, files1[files_index] 
print, 'min/max s',min( loop.s ), max( loop.s ) 
print,  'min/max y',min( loop.axis[1,*] ), max( loop.axis[1,*] ) 
print,   'min/max z',min( loop.axis[2,*] ), max( loop.axis[2,*] ) 
    s_0=loop.s[0]
    z_0=    loop.axis[2,0]
    s_1=loop.s[1]
    print,'s_0, z_0,s_1', s_0, z_0 ,s_1
    wset, 0
    oplot, loop.s, loop.axis[0,*],linestyle=linestyle
    
    wset, 1
    oplot, loop.s, loop.axis[1,*],linestyle=linestyle
    
    wset, 2
    oplot, loop.s, loop.axis[2,*], linestyle=linestyle
    
    wset, 3
    oplot, loop.axis[1,*], loop.axis[2,*]
   
    wset, 4
    oplot, loop.s, loop.a,linestyle=linestyle

    wset, 5 
    oplot, loop.s, loop.g,linestyle=linestyle


    wset, 6 
    oplot, loop.s, loop.B,linestyle=linestyle
;    window, files_index+3, title='File '+string(files_index)
;
;    plot, loop.s, loop.axis[1,*], XTITLE='S [cm]',$
;          YTITLE='Z [cm]', TITLE='y AXIS CHANGE' ,$
;          xr=[min(loop.s),max(loop.s)],$
;          yr=[min(loop.axis[2,*]),max(loop.axis[2,*])]
    
print,'s_0, z_0', s_0, z_0 
end

wset, 0
x2gif, 'axis_test_x.gif'

wset, 1
x2gif, 'axis_test_y.gif'

wset, 2
x2gif, 'axis_test_z.gif'


end
