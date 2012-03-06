;Defining array sizes***********************************************
n_elem=1000
law_elem=2
x=dindgen(n_elem)*.001
main_title=strarr(law_elem)
;*****************************************************************

;Defining constants***********************************************
gamma=double(1d/2d) ;Power Law index
beta=(-2.d*(2d+gamma)/7.)+1d
;*****************************************************************

;Defining beta function arguments=********************************
A=dblarr(law_elem)
B=dblarr(law_elem)
A[0]=(11.+2.*gamma)/(4.*(2.+gamma))
B[0]=0.5d
A[1]=(.5+(2.+gamma)/7.)/((1./14.)+(2.+gamma)/7.)
B[1]=0.5d
print,'A='+string(A)
print,'B='+string(B)
;*****************************************************************

;Defining plot paramenters***************************************
file_name='mhd_hw2b.ps'
main_title[0]="Constant Heating"
main_title[1]="Ohmic Heating"
x_title="s/l"
y_title='z'
y2_title="eta"
y3_title="T/Tmax"
;****************************************************************


z=dblarr(law_elem,n_elem)
for law_index=0,law_elem-1 do begin
	for index=0, n_elem-1 do begin
		z[law_index,index]=ibeta(A[law_index],B[law_index],x[index])
		endfor ;index loop
	endfor ;law_index loop


eta=z^((-1.*beta)+1)
t=eta^(7d/2.)
;window,1
;wshow,1
!p.multi=[0,law_elem,3]
for i=0,law_elem-1 do begin
	plot,z[i,*],x,$
		title=main_title[i],$
		xtitle=x_title,$
		ytitle=y_title
	endfor
;window,2
;wshow,2

for i=0,law_elem-1 do begin
	plot,eta[i,*],x,$
		title=main_title[i],$
		xtitle=x_title,$
		ytitle=y2_title
	endfor
;window,3
;wshow,3

for i=0,law_elem-1 do begin
	plot,t[i,*],x,$
		title=main_title[i],$
		xtitle=x_title,$
		ytitle=y3_title
	endfor

set_plot,'ps'
!p.multi=[0,2,1]
device,filename=file_name,/landscape,yoffset=26.5,/color
;for i=0,law_elem-1 do begin
;	plot,z[i,*],x,$
;		title=main_title[i],$
;		xtitle=x_title,$
;		ytitle=y_title
;	endfor
;for i=0,law_elem-1 do begin
;	plot,eta[i,*],x,$
;		title=main_title[i],$
;		xtitle=x_title,$
;		ytitle=y2_title
;	endfor

for i=0,law_elem-1 do begin
	plot,t[i,*],x,$
		title=main_title[i],$
		xtitle=x_title,$
		ytitle=y3_title
	endfor
device,/close
set_plot,'win'
!p.multi=[0,1,0]
;t=

end
