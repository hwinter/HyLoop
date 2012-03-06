
restore, dialog_pickfile()
gif_dir=dialog_pickfile()
i=0
loadct,3

window, xs=800,ys=150
res=.4d ;SXT pixel res. arcsec
pixel=res*700d*1d5
axis=loop[0].axis
;axis=(rot2#rot1#axis)
volumes=get_loop_vol(loop[0])
signal=1+dblarr(n_elements(volumes))
axis[0,*]=loop[0].axis[1,*]
axis[1,*]=0;loop[0].axis[2,*]
axis[2,*]=0;loop[0].axis[0,*]
    diagram=1

    rad=loop[i].rad
    show_loop_image,axis,rad,signal,pixel=pixel,win=win_num,$
                dxp0=dxp0, dyp0=dyp0,IMAGE_OUT=diagram;,/NOSCALE;,/sqrt;,/NOSCALE
 ;   tvscl,diagram

x2gif, 'diagram.gif'


end
