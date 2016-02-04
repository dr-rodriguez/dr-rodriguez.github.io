; David Rodriguez
; Oct 8, 2008
; Program to estimate uncertainties for binary fractions
; This is for low numbers and using binomial distribution
; Based on Burgasser et al. (2003) -> Appendix (It's about binary brown dwarfs)

;Binomial probability distribution
FUNCTION binomial_pdf, x, n, p
  RETURN, FACTORIAL(n) / (FACTORIAL(x) * FACTORIAL(n-x)) * p^x * (1-p)^(n-x)
END

PRO DR_BINOMIAL, x, n, p

ON_ERROR, 2

IF N_PARAMS() LT 2 THEN BEGIN
  print, 'Syntax - DR_BINOMIAL, x, n, [p]
  print, "For x in n trials (prob= p)"
  RETURN
ENDIF

IF N_PARAMS() LT 3 THEN p = FLOAT(x)/FLOAT(n)

print, "For ", x, " in ", n, " trials (p=", p,")"
;print, "IDL's Binomial function (cumulative pdf): ", BINOMIAL(x,n,p,/DOUBLE)
;print, "Value for Binomial PDF: ", binomial_pdf(x,n,p)

;Poisson
;q = SQRT( 1/x + 1/n )
;upper = p*(1+q)
;lower = p*(1-q)
;print, 'Standard Poisson uncertainty limits:'
;print, 'Lower: ', lower
;print, 'Upper: ', upper

;Poisson answer:
;print, 'For Poisson, p= ', p, ' + ', upper-p, ' - ', p-lower

;Binomial
max = 1001
pval = findgen(max)*1/(FLOAT(max)-1)
bvals = binomial_pdf(x,n,pval)
sum = total(bvals)
norm_b = bvals / sum
;PLOT, pval, norm_b

sum = fltarr(max)
FOR m=0,max-1 DO BEGIN
  FOR i=0, x DO sum[m] = sum[m] + binomial_pdf(i,n+1,pval[m])
ENDFOR

; For lower value the value of sum should be 0.84
index = where((sum GT 0.83) AND (sum LT 0.86))
;print, pval[index], sum[index]
;Fit a straight line to these points
result = LINFIT(pval[index], sum[index])
;Use the fit to obtain the value for sum=0.84
lower = (0.84 - result[0]) / result[1]
; For upper value the value of sum should be 0.16
index = where((sum GT 0.15) AND (sum LT 0.18))
;print, pval[index], sum[index]
;Fit a straight line to these points
result = LINFIT(pval[index], sum[index])
;Use the fit to obtain the value for sum=0.16
upper = (0.16 - result[0]) / result[1]

print, 'Binomial uncertainty limits:'
print, 'Lower: ', lower
print, 'Upper: ', upper

;Binomial answer:
print, 'p= ', p, ' + ', upper-p, ' - ', p-lower

END