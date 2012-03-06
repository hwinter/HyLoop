function get_p_t_law_pressure,length, alpha,$
  TMAX=TMAX, FLUX=FLUX, $
  GAMMA=GAMMA, KAPPA=KAPPA, CHI_0=CHI_0,$
  LAMBDA=LAMBDA,MU=MU, NU=NU,SIGMA=SIGMA, $
  BETA_LAMBDA=BETA_LAMBDA,  BETA_SIGMA=BETA_SIGMA

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if not keyword_set(GAMMA) then $
  GAMMA=5d-1

if size(length,/TYPE) eq 0 then length=1d9
if size(alpha,/TYPE) eq 0 then alpha=0d
if (not keyword_set(TMAX) and not keyword_set(FLUX) )then begin

    message, 'The function get_p_t_law_pressure.pro ' $
             +'requires either the TMAX or FLUX keyword to be set.' 
    stop
endif  
if size(Tmax,/TYPE) eq 0 then Tmax=1d6
;Index for the power law heating function.[Dimensionless]
if not keyword_set(GAMMA) then GAMMA=5d-1;
;Spitzer Conductivity constant [erg cm^-1 K^-1]
if not keyword_set(KAPPA) then KAPPA=1.1d-6
if not keyword_set(CHI_0) then CHI_0 = 10^(12.41d0)
;Have to figure out a better way
alpha_in=alpha
alpha_in>=-2.4

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Define parameters based on Martens, 2008
nu=alpha_in/3.5d0
mu=-1*(2d0+GAMMA)/3.5d0

lambda=(1d0-2*nu+mu)/(2d0*(nu-mu))

if keyword_set(Tmax) then begin
    P_0=(Tmax^((11d0+2d0*GAMMA)/4d0))* $
        ((kappa/chi_0)^5d-1)* $
        ((3d0-2d0*gamma)^5d-1)* $
        beta(lambda+1d0, 5d-1,/DOUBLE)/ $
        ((Length)*(4d0+2d0*gamma+2d0*alpha_in))
endif

if keyword_set(FLUX) then begin
   
    sigma=lambda+ $
          alpha_in/(alpha_in+gamma+2)

;Incomplete Beta functions.
    beta_lambda=beta(lambda+1d0, 5d-1,/DOUBLE)
    beta_sigma=beta(sigma+1d0, 5d-1,/DOUBLE) 
    

    exp1 = (11d0+2d0*gamma)/14d0
    exp2 = (2d0*gamma-3d0)/14d0
    exp3 = (2d0+gamma)/7d0

    P_0=(FLUX)^exp1 * $
        (length)^exp2 * $ 
        1d0/(KAPPA^exp3)* $
        (CHI_0^(-0.5))* $
        (2d0*(2d0+gamma+alpha))^(2d0*exp3) * $
        1d0/((((3d0-2d0*gamma)^(-0.5))*beta_lambda)^(2d0*exp3)) * $
        ((3d0-2d0*gamma)*beta_lambda)^exp1 * $
        1d0/(((7d0+2d0*alpha)*beta_sigma)^exp1)
        
endif

return , P_0
END;Of main
