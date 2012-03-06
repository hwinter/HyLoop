;strand_display
data_dir=get_environ('DATA')

sav_file=data_dir+'/AIA/strand_start'

strand_files=file_search(sav_file+'*')
for i=0,n_elements(strand_files)-1l do begin
restore ,strand_files[i]

    phi=x[1:n_elements(x)-2l]
    signal=mk_aia_signals(x,a,lhist[n_elements(lhist)-1])
    phi=signal.A195
    rot=rotation(1,!dpi/4d) 
    new_axis=matrix_multiply(rot,axis)
if i eq 0 then begin
        ;window,15
       ; plot_3dbox,axis[0,*],axis[1,*],axis[2,*]
   
    show_loop_image, new_axis, rad, phi
        ;window,16
        ;plot,axis[1,*],axis[2,*],yrange=[0,1d10],/zstyle
        ;midpt=where(axis[2,*] eq max(axis[2,*]))
        ;plots,axis[1,midpt],axis[2,midpt],psym=4
        ;wset,0
        ;pmm,axis[2,*]
    endif else begin
        print,'test 1'
       ; wset,15
       ; plots, axis[0,*],axis[1,*],axis[2,*]
        phi=axis[2,1:n_elements(axis[2,*])-2l]
        rot=rotation(1,!dpi/4d) 
        new_axis=matrix_multiply(rot,axis)
        show_loop_image, new_axis, rad, phi, /add
        ;wset,16
        ;midpt=where(axis[2,*] eq max(axis[2,*]))
        ;print,'Height= '+string(axis[2,midpt])
        ;plots,axis[1,midpt],axis[2,midpt],psym=4
        ;plots,axis[1,*],axis[2,*],psym=4
        ;wset,0
    endelse

end
END
