n=100
m=100
n_map=1000
data=dblarr(n, m)

map={ data: data, $
      xc:0.0, $
      yc:0.0, $
      dx:1.0, $, $
      dy:1.0, $
      time:'0.0', $
      dur:0.0, $
      ID: 'Gaussian Test', $
      units:'arcsecs'$
    }

map =replicate(map, n_map)
for i=0, n-1 do begin
   for j=0, m-1 do begin
      map[*].data[i,j]=randomn(seed, n_map, /DOUBLE)
      
   endfor      
endfor

avg_data=get_array_mean(map.data, 2, STD_DEV=STD_DEV)  

help, avg_data, STD_DEV


end

























