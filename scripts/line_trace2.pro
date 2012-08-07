; IDL Version 6.2 (linux x86_64 m64)
; Journal File for winter@mithra
; Working directory: /disk/hl2/data/winter/data1/PATC
; Date: Tue May 16 16:18:34 2006

n_levels=20
B0=100d ;Maximum Magnetic field [Gauss]
Area_0=!dpi*(.5d*5d8)^2d ;;Footpoint area [cm^2]
hO=1.5d9
line_index=1 
;bungey_priest_field,B_z,b_y,z,y,f,a=1,B_DRC=0.5,$
;  B0=1d,n_elem=1000l,B_total=B_total
f2=real_part(transpose(f))
b2=transpose(B_total)
window,0
contour,f2,y,z,nlevels=n_levels,/path_data_coords,$
  path_xy=path_xy,path_info=path_info,$
  path_double=1,closed=0,/ISOTROPIC 
VALUE_IND=WHERE(path_info.value LT 0)
VALUE_IND2=WHERE(path_info.value gt 0)
LEVELS=[(path_info[VALUE_IND].value), $
        (0D),$
        (path_info[VALUE_IND2].value)]
LEVELS=levels[sort(levels)]
levels=levels[uniq(levels)]
contour,f2,y,z,nlevels=n_levels,$
  TITLE="Field Lines for Green's current sheet solution",$
  levels=levels,/ISOTROPIC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;overplot the current sheet
oplot,[0.,0.],[1,-1],thick=2

y_ind=where(abs(y-0d) eq min(abs(y-0d)))
z_ind=where(abs(z-(-1.01d)) eq min(abs(z-(-1.01d))))
help,z_ind                              
;IDL> help,y_ind[0]                                 
;<Expression>    LONG      =          250
value=f2[y_ind[0],z_ind[0]]
value=0d
contour,f2,y,z,nlevels=n_levels,$
  /path_data_coords,path_xy=path_xy2,$
  path_info=path_info2,path_double=1,$
  closed=0,levels=value,/ISOTROPIC             ; path_info[1].value

n_lines=n_elements(path_info2)
n_points=path_info2[line_index].n
line_end=path_info2[line_index].offset+n_points-1l
;if line_index+1l ge n_lines-1l then $
;  line_end= n_elements(path_xy2[0,*])-1l $
;  else line_end=path_info2[line_index+1l].offset-1l

loadct,3,/SILENT
;for i =0, n_elements(path_xy2[0,*])-1l do begin
wait,0.01 
 plots, path_xy2[*,$
                 path_info2[line_index].offset: $
                line_end], psym=2,color=135
x2gif,'field_lines.gif'
; wait,.001
; endfor
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Find the number of points corresponding to the line you are
;interested in
n_points=path_info2[line_index].n
;help,path_xy2[*,path_info2[line_index].offset:n_elements(path_xy2[0,*])-1l]

axis=dblarr(3,n_points)

axis[0,*]=0d
axis[1,*]=path_xy2[0,path_info2[line_index].offset: $
                   line_end]
axis[2,*]=path_xy2[1,path_info2[line_index].offset: $
                   line_end]
axis=axis+2d
axis=axis*50d*1d8


window,1
plot,axis[1,*],axis[2,*], Title='Loop' 

by=dblarr(n_points)
bz=by
bTOT=bz
B_T=bz
window,2
y_index=lonarr(n_points)
z_index=lonarr(n_points)
plot,y,z,/NODATA,TITLE='Field Line'
for i=0l,n_points-1l do begin
    ypos=reform(path_xy2[0,path_info2[line_index].offset+i])
    zpos=reform(path_xy2[1,path_info2[line_index].offset+i])
    y_index=where(abs(ypos[0]-y) eq min(abs(ypos[0]-y)))
    z_index=where(abs(zpos[0]-z) eq min(abs(zpos[0]-z)))
    if (y_index[0]eq -1) or (z_index[0] eq -1 ) then stop
    by[i]=b_y[y_index,z_index]
    bz[i]=b_z[y_index,z_index]
    B_T[i]=b2[y_index,z_index]
    bTOT[i]=sqrt((by[i]^2d)+(bz[i]^2d))
    plots,y[y_index],z[z_index],psym=4

endfor

 ;b_total= b_total/max(b_total)

window,4
plot,b_t/max(b_t),$
  TITLE='B Along the loop [Normalized]'
x2gif,'loop_B.gif'
window,5
plot,bTOT,TITLE='FROM script.'  ;*100

window,6
loadct,1,/SILENT

;shade_surf,b2,y,z,az=0.,ax=90,yTITLE='B Map',/ISOTROPIC
contour,b2,y,z,/CELL_FILL,NLEVELS=60,/ISOTROPIC
loadct,3,/SILENT
 plots, path_xy2[*,$
                 path_info2[line_index].offset: $
                line_end]
contour,b2,y,z,nlevels=10,path_info=path_info3,/ISOTROPIC 
LEVELS=[0D,path_info3.value]
LEVELS=levels[sort(levels)]
levels=levels[uniq(levels)]
 contour,b2,y,z,nlevels=10,$
   c_labels=string(path_info3.value),/OVERPLOT ,$
   LEVELS=LEVELS,/ISOTROPIC 
x2gif,'B_map.gif' 

area=1d/b_t
r=sqrt(area/!dpi)



end
