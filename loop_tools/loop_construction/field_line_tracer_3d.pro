;field_line_tracer.pro
;bx & by need work

function field_line_tracer_3d,function_name,coord_init,$
                              coord_fin,DELTA_L=DELTA_L
  
  if not keyword_set(DELTA_L) then delta_l=0.1*min([coord_init[0]-coord_fin[0],$
                                                   coord_init[1]-coord_fin[1],$
                                                   coord_init[2]-coord_fin[2]])
  
  
  B=call_function(function_name,coord_init)

done=0
coord=dblarr(1,3)
coord[0,*]=coord_init
n=0


plot_3dbox, [0,0], [0,0], [0,0], xr=[0,1d8], yr=[0,1d8],zr=[0,1d8]
plots, coord_init[0],coord_init[1], coord_init[2]
While not done do begin

  B=call_function(function_name,reform(coord[n,*]))
  ;print, b
  z=where(finite(b) ne 1)
  if z[0] ne -1 then stop
  ;stop
   
  delta_r=((B)/sqrt(total(b*b)))*DELTA_L
  new_coord=coord[n,*]+delta_r
  n++
  c=make_array(n+1,3)
  c[0:n-1,*]=coord
  c[n,*]=new_coord
  coord=c

  if coord[n,0] gt coord_fin[0] then done=1
  if coord[n,1] gt coord_fin[1] then done=1
  if coord[n,2] gt coord_fin[2] then done=1
  
  print, '-----------------------'
  print, new_coord[0,*]
  print, '-----------------------'
  plots, new_coord[0],new_coord[1], new_coord[2], /continue, psym=1, /t3d


endwhile
        
;stop
return, coord

end
