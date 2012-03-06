function get_p_t_law_temp_profile,s, alpha, $
  GAMMA=GAMMA, LAMBDA=LAMBDA, TMAX=TMAX, $
  IBETA_LAMBDA=IBETA_LAMBDA

if not keyword_set(GAMMA) then $
  GAMMA=5d-1

if size(s,/TYPE) eq 0 then begin

    message, 'The function get_p_t_law_temp_profile.pro ' $
              +'requires an array of loop coordinates.' 
    stop
endif  
 
if size(alpha,/TYPE) eq 0 then alpha=0d0
;Have to figure out a better way
alpha_in=alpha
alpha_in>=-2.4
length = max(s) 
n_s=n_elements(s)  
nu=alpha_in/3.5d0
mu=-1*(2d0+GAMMA)/3.5d0

lambda=(1d0-2*nu+mu)/(2d0*(nu-mu))

index=where(abs(s-(length/2d0)) eq min(abs(s-(length/2d0))))

u=findgen(N_s)/(N_s-1ul)   ; interval [0,1]

IBETA_LAMBDA=ibeta( lambda+1,5d-1,u,/DOUBLE )
t=(u)^(1d0/(2d0+gamma+alpha_in))

t=[t,reverse(t)]
t>=0d0

if alpha_in le -2.35 then for i=0,5 do t=smooth(t,3)
IBETA_LAMBDA=length*[IBETA_LAMBDA/2d0,1d0-reverse(IBETA_LAMBDA/2d0)]
;Lazy way to do this.  I should really be using inverse beta functions.  
;Show me a reference for that.
t=interpol(t, IBETA_LAMBDA,s)
t>=0d0
if keyword_set(TMAX) then $
  t=TMAX*t
;stop
return , t
END;Of main
