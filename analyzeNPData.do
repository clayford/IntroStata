*************************
* Clay Ford
* Data Analysis
* 10 Sept 2014
*************************

* newspaper data analysis
version 13.1
cd "C:\Users\jcf2d\Documents\_workshops\IntroToStata"
capture log close 
log using "analyzeNPData", replace name(analyzeNPData) 

* load data
use NPData, clear

* categorical variables (levels)
tabulate reportyear
tabulate Type
* two-way tables
tabulate State Type

tab reportmonth reportyear, column

bysort Type: tabulate reportyear

* numeric variables 
summarize SunSat
summ SunSat, detail

* summarize over subsets
bysort Type: summarize SunSat

* graph
gen SunSatK = SunSat/1000
gen WeekdayK = Weekday/1000

graph twoway (scatter WeekdayK SunSatK) (lfit WeekdayK SunSatK) ///
	|| line WeekdayK WeekdayK, legend(order(2 3) label(3 "Reference Line")) ///
	xtitle(Sunday/Saturday) ytitle(Weekday) ///
	title("Weekday versus Weekend subscriptions") ///
	subtitle("Thousands of subscribers")

* save graph as high-res image file; see "help graph export"
graph export figure1.tif

log close analyzeNPData
