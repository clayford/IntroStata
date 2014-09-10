*************************
* Clay Ford
* Data Prep
* 10 Sept 2014
*************************

* prepare Newspaper data for analysis

version 13.1
cd "C:\Users\jcf2d\Documents\_workshops\IntroToStata"
capture log close 
log using "dataPrep", replace name(dataPrep) 
import delimited "newspapers.csv", varnames(1) clear

* update variable names
rename (city state type sunsat wkdy) (City State Type SunSat Weekday)

* convert circulation numbers to numeric
destring SunSat Weekday, ignore(,) replace 

* keep records with either SunSat not missing or Weekday not missing
keep if SunSat !=. | Weekday != . 

* generate an ID number
generate id = _n

* create variable for difference between SatSun and Weekday
generate diff = SunSat - Weekday

* create four categories for SunSat subscriber base
generate SunSatCat = .
replace SunSatCat = 1 if (SunSat <= 10000)
replace SunSatCat = 2 if (SunSat > 10000) & (SunSat <= 100000)
replace SunSatCat = 3 if (SunSat > 100000) & (SunSat <= 500000)
replace SunSatCat = 4 if (SunSat > 500000) & (SunSat < .)

* standardized values of circulation
egen stdWkdy = std(Weekday)
egen stdSunSat = std(SunSat)

* months and dates
generate reportmonth = substr(reportdate,1,2)
generate reportyear = substr(reportdate,4,4)

* drop the reportdate variable
drop reportdate

* sort data by state
sort State 


label variable State "US states and Canadian provinces and territories"
label data "Newspaper data obtained from Alliance for Audited Media (AAM)"
notes: This data was downloaded from http://www.auditedmedia.com/
notes Type:  BE = Branded Edition, CND = Community Daily Newspaper, ///
			 CNW = Community Weekly Newspaper, DLY = Daily Newspaper, ///
			 WKL = Weekly Newspaper

save "NPData", replace
log close dataPrep
