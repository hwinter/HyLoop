 function erfinv, y

a=(8./(3*!dpi))*((!dpi-3.)/(4.-!dpi))

f_1=alog(1.-(y^2.))/2.
x=sqrt( -2./(!dpi*a) $
    -f_1 $
    +sqrt((((2./(!dpi*a))+f_1)^2.) $
          -((1./a)*alog(1.-(y^2.)))  )$
    )



return,x
end 
