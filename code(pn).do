clear all
cd  E:\EODB-20210906
capture log close 
log using energylegislation, append text

global Do     "E:\EODB-20210906\Dofiles"      
global Raw    "E:\EODB-20210906\rawdata"      
global Work   "E:\EODB-20210906\workingata" 
global Out    "E:\EODB-20210906\outfiles"     
global Ref    "E:\EODB-20210906\reference"    

*****************descriptive*********************
use "$Work\energylegislation.dta",clear
egen laworderinewmax=max(laworderinew)
egen laworerinewmin=min(laworderinew) 
gen laworderinewweight=(laworderinew-laworerinewmin)/(laworderinewmax-laworerinewmin)
gen laworderinewweight2=(laworderinew-0)/6
order iso year lnrec lnrep lawtotal legislativelaw /// 
executivelaw lawlongtotal laworderinewweight2 lnco2pc ///
lnpgdp lnp corruptionnew fdinew
outreg2 using "$Out\tabledescripe.doc", word excel replace sum(log) ///
keep(lnrec lnrep lawtotal legislativelaw /// 
executivelaw lawlongtotal laworderinewweight2 lnco2pc ///
lnpgdp lnp corruptionnew fdinew) title(Table1 Decriptive statistics of variables) 

****************emprical results************************
use "$Work\energylegislation.dta.dta",clear
egen laworderinewmax=max(laworderinew)
egen laworerinewmin=min(laworderinew) 
gen laworderinewweight=(laworderinew-laworerinewmin)/(laworderinewmax-laworerinewmin)
gen laworderinewweight2=(laworderinew-0)/6
xtset iso year, year
**************table1
reghdfe lnrec c.lawshorttotal c.lawlongtotal2 lnco2pc lnpgdp lnp corruptionnew fdinew, absorb(i.year i.iso) vce(robust)  
 est store lnrec
reghdfe lnrep c.lawshorttotal c.lawlongtotal2 lnco2pc lnpgdp lnp corruptionnew fdinew, absorb(i.year i.iso) vce(robust) 
est store lnrep
outreg2 [lnrec lnrep] using "$Out\table1.doc", word excel replace tstat bdec(4) tdec(4)  addtext(Country FE, YES,Year FE, YES )e(r2_within) title(Table 1 - energy laws and their effect on energy) 


*************legislation quality
reghdfe lnrec c.lawshorttotal#c.laworderinewweight2 c.lawlongtotal2#c.laworderinewweight2 lnco2pc lnpgdp lnp corruptionnew fdinew, absorb(i.year i.iso) vce(robust) 
outreg2 using table2.doc, replace tstat bdec(4) tdec(4) ctitle(quality,) ///
	addtext(Country FE, YES, Year FE, YES) e(r2_within) ///
	title(Table 5 – Legislative quality results)
	
reghdfe lnrec c.lawshortlegis c.lawlonglegis2 c.lawshortexecu c.lawlongexecu2 lnco2pc lnpgdp lnp corruptionnew fdinew, absorb(i.year i.iso) vce(robust)	
outreg2 using table2.doc, append tstat bdec(4) tdec(4) ctitle(both types,) ///
	addtext(Country FE, YES, Year FE, YES) e(r2_within) 
	
reghdfe lnrec c.lawshortlegis c.lawlonglegis2 lnco2pc lnpgdp lnp corruptionnew fdinew, absorb(i.year i.iso) vce(robust)
outreg2 using table2.doc, append tstat bdec(4) tdec(4) ctitle(leg.only,) ///
	addtext(Country FE, YES, Year FE, YES) e(r2_within) 

reghdfe lnrec c.lawshortexecu c.lawlongexecu2 lnco2pc lnpgdp lnp corruptionnew fdinew, absorb(i.year i.iso) vce(robust)
outreg2 using table 2.doc, append tstat bdec(4) tdec(4) ctitle(exe.only,) ///
	addtext(Country FE, YES, Year FE, YES) e(r2_within) 

************The aggregate effect of energy legislation
use "Work\energylegislation.dta",clear
xtset iso year, year
encode incomelevelname,gen(incomegroup2)
codebook incomegroup2
 reghdfe lnrec c.lawshorttotal c.lawlongtotal2 lnco2pc lnpgdp lnp corruptionnew fdinew, absorb(i.year i.iso) vce(robust)  
		est store R1
		predict x1, xb 
		gen ex1=exp(x1)
	gen b1_sr= _b[c.lawshorttotal]*(lawshorttotal) 
	gen b1_lr= _b[c.lawlongtotal2]*(lawlongtotal2)  
reghdfe lnrep c.lawshorttotal c.lawlongtotal2 lnco2pc lnpgdp lnp corruptionnew fdinew, absorb(i.year i.iso) vce(robust)  
		est store R3
		predict x3, xb
		gen ex3=exp(x3) 
	gen b3_sr= _b[c.lawshorttotal]*(lawshorttotal) 
	gen b3_lr= _b[c.lawlongtotal2]*(lawlongtotal2)  

gen rec1=((recnew+1)*exp(-b1_sr-b1_lr))-1 
gen rep1=((repnew+1)*exp(-b3_sr-b3_lr))-1 
egen LW_rec1 =sum(rec1-recnew) 
egen LW_rep1 =sum(rep1-repnew)  
	egen LM_rec1 =sum(rec1-recnew) if incomegroup2==1
	egen LM_rep1 =sum(rep1-repnew) if incomegroup2==1
sum LW_rec1 LW_rep1 
	LM_rec1 LM_rep1 if year==2019 & iso=="DEU"
	
	bysort year: egen recworldsum=sum(recnew) 
	bysort year: egen recworldsumwithout=sum(rec1)
	bysort year: egen repworldsum=sum(repnew)
	bysort year: egen repworldsumwithout=sum(rep1) 
	bysort year: egen rechighincomesum=sum(recnew) if incomegroup2==1
	bysort year: egen rechighincomesumwithout=sum(rec1) if incomegroup2==1
	bysort year: egen rephighincomesum=sum(repnew) if incomegroup2==1
	bysort year: egen rephighincomesumwithout=sum(rep1) if incomegroup2==1
	keep if countrycode=="DEU"
	
***********robust check 
use "Work\energylegislation.dta",clear
xtset iso year, year
xtset iso year, year
encode incomelevelname,gen(incomegroup2)
codebook incomegroup2
reghdfe lnrec c.lawshorttotal c.lawlongtotal2 lnco2pc lnpgdp lnp corruptionnew fdinew if incomegroup2==1, absorb(i.year i.iso) vce(robust)  
outreg2 using "tabrobust.doc", replace dec(4) ctitle(High-income ,REC) ///
	addtext(Country FE, YES, Year FE, YES) e(r2_within) ///
	title(Table S2 –High-income countries vs Low- and middle-income countries)

reghdfe lnrep c.lawshorttotal c.lawlongtotal2 lnco2pc lnpgdp lnp corruptionnew fdinew if incomegroup2==1, absorb(i.year i.iso) vce(robust)  
outreg2 using "tabrobust.doc", append dec(4) ctitle(,REP) ///
	addtext(Country FE, YES, Year FE, YES) e(r2_within) ///
	
reghdfe lnrec c.lawshorttotal c.lawlongtotal2 lnco2pc lnpgdp lnp corruptionnew fdinew if incomegroup2!=1, absorb(i.year i.iso) vce(robust)  
outreg2 using "tabrobust.doc", append dec(4) ctitle(Low- and middle-income,REC) ///
	addtext(Country FE, YES, Year FE, YES) e(r2_within) ///
	
reghdfe lnrep c.lawshorttotal c.lawlongtotal2 lnco2pc lnpgdp lnp corruptionnew fdinew if incomegroup2!=1, absorb(i.year i.iso) vce(robust)  
outreg2 using "tabrobust.doc", append dec(4) ctitle(,REP) ///
	addtext(Country FE, YES, Year FE, YES) e(r2_within) 
	
