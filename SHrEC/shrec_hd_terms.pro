;+
; NAME:
;	
;
; PURPOSE:
;	
;
; CATEGORY:
;	
;
; CALLING SEQUENCE:
;	
;
; INPUTS:
;	
;
; OPTIONAL INPUTS:
;	
;	
; KEYWORD PARAMETERS:
;	
;
; OUTPUTS:
;	
;
; OPTIONAL OUTPUTS:
;	
;
; COMMON BLOCKS:
;	
;
; SIDE EFFECTS:
;	
;
; RESTRICTIONS:
;	
;
; PROCEDURE:
;	
;
; EXAMPLE:
;	
;
; MODIFICATION HISTORY:
; 	Written by:	
;-

PRO shrec_hd_terms, state, x, a, g, e_h,dedt, dvdt, dndt,plotit=plotit, plotde=plotde
;calculate the magnitude of terms in the HD equations

;Set so that () is for functions and [] is for array indices, rigidly!
compile_opt strictarr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Define Constants
kb=1.38e-16
mp = 1.67e-24                   
;
nx=n_elements(x)

da = a[1:nx-1] - a[0:nx-2]
dx = x[1:nx-1] - x[0:nx-2]
vav = (state.v[0:nx-2] + state.v[1:nx-1])*0.5
aav = (a[0:nx-2] + a[1:nx-1])*0.5
                                ;t = state.e/(3.*kb*state.n_e)
t=shrec_get_temp(state)
dt1 = t[1:nx] - t[0:nx-1]
dt = (dt1[0:nx-2] + dt1[1:nx-1])*0.5
dne1 = state.n_e[1:nx] - state.n_e[0:nx-1]
dne = (dne1[0:nx-2] + dne1[1:nx-1])*0.5
dv = state.v[1:nx-1] - state.v[0:nx-2]
de1 = state.e[1:nx] - state.e[0:nx-1]
dp = (2./3.)*(de1[0:nx-2] + de1[1:nx-1])*0.5
de = dp*(3./2.)
dxav=0.5*(dx`[1:nx-2] + dx[0:nx-3])

;
k0=shrec_kappa(t)
radloss = shrec_radloss(state.n_e, t, /uri,/fal)
kav=0.5*(k0[1:nx] + k0[0:nx-1])

dedt = {advect:-vav*de/dx - state.e[1:nx-1]*dv/dx - da/(aav*dx) * vav*state.e[1:nx-1], $
        work:  -2./3.*state.e[1:nx-1]*dv/dx - da/(aav*dx) * vav*(2./3.)*state.e[1:nx-1], $
        rad:radloss , $
        cond:kav[1:nx-2]*(dt[1:nx-2] - dt[0:nx-3])/(dxav)^2+(dt/dx)*(k0[1:nx-1] - k0[0:nx-2])/dx $
        + da/(aav*dx)*k0[1:nx-1]*dt/dx } ;, $
;$;alternate conduction: (k0dtdx[1:nx-2] - k0dtdx[0:nx-3])/dxav
;$;k0dtdx=k0[1:nx-1]*(dt/dx)
;$;dxav=0.5*(dx[1:nx-2] + dx[0:nx-3])
;	area: (da/(aav*dx))*((5./3.)*state.e[1:nx-1] *vav + k0[1:nx-1]*dt/dx) }
dvdt = {gradP:-dp/(dx*state.n_e[1:nx-1]*mp),$
        advect:-vav*dv/dx, $
        grav:g}
dndt = {advect: -vav*dne/dx -state.n_e[1:nx-1]*dv/dx -state.n_e[1:nx-1] *vav*da/(dx*aav)}

IF keyword_set(plotit) THEN BEGIN
;wset, 1
    old_p_state=!p.multi
    !p.multi=[0,2,2]
    
    plot, (dndt.advect)/state.n_e, xtit='grid #',tit='% change in d!dt!n n!de!n', yr=[-1,1] ;*max(abs(dndt.advect))
;  oplot, dndt.area, linestyle=2
    legend, ['-d!dx!n v n!de!n - v n!de!n d!dx!nA/A'],lines=[0], box=0
    
    plot, (dvdt.gradP)/(abs(state.v)>.0001), xtit='grid #',tit='% change in d!dt!n v', yr=[-1,1] ;*max(abs([dvdt.gradP,dvdt.advect]))
    oplot,(dvdt.advect)/state.v, linestyle=2
    oplot,(dvdt.grav)/state.v, linestyle=1
    legend, ['-d!dx!nP/n!de!nm!dp!n','g!d||!n','-v d!dx!nv'],lines=[0,1,2],top=0, box=0
    
    plot, (dedt.work)/state.e, xtit='grid #',tit='% change in d!dt!n e', yr=[-1,1] ;*max(abs([dedt.work,dedt.advect]))
    oplot, (dedt.advect)/state.e, linestyle=1
    legend, ['-P/A d!dx!nA v','-1/A d!dx!nA e v'],lines=[0,1],box=0
;,'-n!de!u2!nL','d!dx!nKd!dx!nT','d!dx!nA terms'],lines=[0,1,2,3,4];,psym=[0,0,0,0,-6], top=0

    plot, (dedt.rad)/state.e, linestyle=0,xtit='grid #',tit='% change in d!dt!n e',yr=[-1,1] ;*max(abs([dedt.cond[2:nx-3],dedt.rad[2:nx-3]]))
    oplot, (dedt.cond)/state.e, linestyle=1
    oplot, (e_h)/state.e, linestyle=2
    legend, ['n!de!u2!nL','1/A d!dx!nA Kd!dx!nT','E!dH!n'],lines=[0,1,2], box=0

    !p.multi=old_p_state
    wait, 0.25
ENDIF

IF keyword_set(plotde) THEN BEGIN
    old_p_state=!p.multi
    !p.multi=0
    plot, dedt.rad, linestyle=0,xtit='grid #',tit='d!dt!n e', yr=[-1./2.,1]*0.01
    oplot, dedt.cond, linestyle=1
    oplot, e_h, linestyle=2
    legend, ['n!de!u2!nL','1/A d!dx!nA Kd!dx!nT','E!dH!n'],lines=[0,1,2], box=0
    wait, 0.25
   !p.multi=old_p_state
ENDIF

;IDL> plot, dndt.advect + dndt.area
;IDL> plot, dvdt.gradp + dvdt.advect + dvdt.grav
;IDL> plot, dedt.work + dedt.advect + dedt.rad + dedt.cond + dedt.cond + dedt.area
;stop
print, state.time

return
end







