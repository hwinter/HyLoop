pro hdw_plot_b_field, x,y,bx,by

  nx=n_elements(x)
  ny=n_elements(y)
  
  n=min([nx,ny])
  u=dblarr(n,n)
  v=u
;I know there is a matrix way to do this but today, I am lazy.
  for i =0 , n-1ul do begin
     u[i,i]=bx[i]
     v[i,i]=by[i]
  endfor;i loop

  velovect, u,v,x,y
end
