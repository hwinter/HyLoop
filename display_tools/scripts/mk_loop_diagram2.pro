
restore, '/Users/winter/programs/PATC/runs/2006_AUG_17/gcsm_loop.sav'
gif_dir='/Users/winter/programs/PATC/runs/2006_AUG_17/gifs/'
i=0
loadct,3

window,0, xs=800,ys=300
res=.4d ;SXT pixel res. arcsec
pixel=res*700d*1d5
axis=loop[0].axis
;axis=(rot2#rot1#axis)
volumes=get_loop_vol(loop[0].s, loop.a)
axis[0,*]=loop[i].axis[1,*]
axis[1,*]=loop[i].axis[2,*]
axis[2,*]=loop[i].axis[0,*]
signal=(1d)+dblarr(n_elements(volumes))

    rad=loop[i].rad
    show_loop_image,axis,rad,signal,pixel=pixel,win=win_num,$
                dxp0=dxp0, dyp0=dyp0,IMAGE_OUT=diagram;,/NOSCALE;,/sqrt;,/NOSCALE
 ;   tvscl,diagram

window,0, xs=723,ys=217
tvscl, diagram
x2gif, 'diagram2.gif'


end
