;field_line_tracer.pro
;bx & by need work

function lf_field_line_tracer, p,q,lambda,h, $
                               delta_l, A_0=A_0, $
                               BX=BX, BY=BY, BT=BT,$
                               GENXFILE=GENXFILE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Keyword check
if not keyword_set(A_0) then A_0=1d0

if size(delta_l, /TYPE) eq 0 then  delta_l=1d7 ;cm 100

if keyword_set(GENXFILE) then begin
   test=file_test(GENXFILE)
   if test ne 1 then begin
      message, 'No file named '+GENXFILE+' .', /CONTINUE
      stop
   endif
   
   restgen,struct=struct, file=GENXFILE
   lambda=struct.SAVEGEN0.LAMBDA_CRITICAL;*struct.SAVEGEN0.LAMBDA0_VALUE
   A_0=struct.SAVEGEN0.A0_VALUE
   h=struct.SAVEGEN0.H_VALUE;*struct.SAVEGEN0.LAMBDA0_VALUE
   p=struct.SAVEGEN0.P_VALUE;*struct.SAVEGEN0.LAMBDA0_VALUE 
   q=struct.SAVEGEN0.Q_VALUE; *struct.SAVEGEN0.LAMBDA0_VALUE
   
endif
                               
;lambda_scale=lambda
;lambda=1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Start on the left side, bottom.
x_array=0.01
y_array=p*0.9999
x=x_array
y=y_array
x=-lambda+(2*lambda*dindgen(1000)/999)
y=p*(0.0001+dindgen(1000)/999)
b_x_array=dblarr(1000, 1000)
b_y_array=b_x_array
for i=0, 999 do begin
   for j=0, 999 do begin
      b=lin_forbes_field(x[i],y[j],p,q,lambda,h, $
                         A_0=A_0,$
                         B_TOTAL=B_TOTAL, B_x=B_x, b_y=b_y)
      b_x_array[i,j]=B_x
      b_y_array[i,j]=B_y
   endfor
endfor


stop

bx=b[0]
by=b[1]
bt=B_total
i=1ul
stop
while max(y_array) gt 0. do begin 
   print, i
   delta_x=(b[0]/B_TOTAL)*delta_l
   delta_y=(b[1]/B_TOTAL)*delta_l
   
   x=x+delta_x
   y=y+delta_y
   x_array=[x_array, x]
   y_array=[y_array, y]
   
   b=lin_forbes_field(x,y,p,q,lambda,h, $
                      A_0=A_0,$
                      B_TOTAL=B_TOTAL)
   
   bx=[bx, b[0]]
   by=[by, b[1]]
   bt=[bt, B_total]
   i++
   if i gt 10000 then begin
     
 

      
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

      plot, x_array, y_array, back=fsc_color('white'),$
            color=fsc_color('black')
      oplot,x_array[0:500], y_array[0:500], psym=1,$
            color=fsc_color('red')
      oplot,x_array[500:*], y_array[500:*], psym=1,$
            color=fsc_color('blue')
      stop
   endif
end


    return, [[x_array],[y_array]]
 end; of bp_field_line_tracer
