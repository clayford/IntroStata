*************************
*Introduction to Stata
*September 10, 2014
*StatLab@UVa Library
*Clay Ford
*************************

* use Ctrl+D to submit commands or click the Execute button;
* green text preceded with asterisks are comments.

*************************
* STARTING THE DO FILE

* Stata periodically releases new versions, which means do-files written for 
* older versions might stop working.
* To prevent that from happening, specify the version of Stata that you are 
* using at the top of do-files:
version 13.1

* set working directory; sometimes easier to do first in command field
* where you can use tab completion. Or do File...Change Working Directory. 
* The following only works for me:
cd "C:\Users\jcf2d\Box Sync\IntroToStata\"

* closes a log file if one is open; capture supresses error generated if no log is open 
capture log close 

* starts a log; two kinds to use: text and smcl (Stata Markup and Control Language)
* start a smcl log named "workshop log"
log using "09-10_log", replace name("workshop log") 
* log using "07-16_log.log", replace  /*text log*/

* Or add to previous log and give log a name
log using "09-10_log", append name("workshop log")

*************************
* READING AND SAVING DATA

* data on newspaper subscriptions: http://guides.lib.virginia.edu/datastats/a-z
* Alliance for Audited Media (AAM)

* Stata can only have one data set loaded; specifying clear removes any
* existing data set from memory

* read in CSV file 
* read from working directory
import delimited "newspapers.csv", clear
* read from internet
import delimited "http://people.virginia.edu/~jcf2d/workshops/Stata/newspapers.csv", clear

* take a look at data:
browse /*or click Data Editor (Browse) button*/

* need to specify that variables are in first row:
* varnames(1) means "variable names in first row"
import delimited "newspapers.csv", varnames(1) clear
import delimited "http://people.virginia.edu/~jcf2d/workshops/Stata/newspapers.csv", ///
	varnames(1) clear

* read in tab delimited file with delimiter(tab) option
* submit command "help import" for an overview of importing data into Stata

* NOTE: prior versions of Stata used insheet; it continues to work but 
* as of Stata 13 is no longer an official part of Stata.

* save imported data as Stata data file with .dta extension
save "newspapers", replace
* use "replace" option to overwrite existing file

* how to clear data
clear

* read in Stata data with the use command
use newspapers, clear

* can also enter/edit data in by hand using data editor (not recommended)

*************************
* DATA MANAGEMENT

* see information about your data set and specific variables
describe
describe sunsat

* see data in results window
list
* use Enter to advance one line at a time; 
* use spacebar to advance one page at a time;
* use q to quit

* see first 10 records
list in 1/10
* see from record 2000 to the end
list in 2000/l //that's a lower case L, not the number one//
* see publications in Virginia
list publicationname if State=="VA"

* rename variables: rename old new
rename city City

* rename groups of variables: rename (old vars) (new vars)
rename (state type sunsat wkdy) (State Type SunSat Weekday)

* use "order" to reorder variables in columns; see "help order"

* look at subscriber numbers; stored as string
describe SunSat Weekday
list SunSat Weekday in 1/10

* convert numbers to numeric using destring (remove commas and convert to numeric)
* ignore (,) means delete the comma; replace means replace the character value 
* with a numeric value; must specify generate or replace
destring SunSat Weekday, ignore(,) replace 
list SunSat Weekday in 1/10
describe SunSat Weekday

* missing values
* Note: dot(.) means missing; can be thought of as a really large number

* see records missing both SunSat and Weekday
list if SunSat ==. & Weekday == . 
* keep records with either SunSat or Weekday present
keep if SunSat !=. | Weekday != . 

* misstable command nice for investigating missingness
misstable summarize (SunSat Weekday)
misstable patterns (SunSat Weekday)

* generating and replacing variables
* generate an ID number
generate id = _n

* create variable for difference between SatSun and Weekday
generate diff = SunSat - Weekday

* create four categories for SunSat subscriber base (aka recoding)
* <= 10,000; 10,001 - 100,000; 100,001 - 500,000; > 500,000
* create a variable called SunSatCat with all missing values
generate SunSatCat = .
* now conditionally replace SunSatCat values 
replace SunSatCat = 1 if (SunSat <= 10000)
replace SunSatCat = 2 if (SunSat > 10000) & (SunSat <= 100000)
replace SunSatCat = 3 if (SunSat > 100000) & (SunSat <= 500000)
replace SunSatCat = 4 if (SunSat > 500000) & (SunSat < .)

* use egen for more sophisticated transformations
* egen = "Extensions to GENerate"; see "help egen"
* standardized values of circulation
egen stdWkdy = std(Weekday)
egen stdSunSat = std(SunSat)


* note the reportdate: it has AR appended to it (AR = Audited Report)
* let's create two new variables: report month, report year
* have to use replace or generate; substr(var, start position, length)
generate reportmonth=substr(reportdate,1,2)
generate reportyear=substr(reportdate,4,4)

* let's drop the reportdate variable
drop reportdate

* sort data by state
sort State 
* sort data by state then by type
sort State Type
* sort Weekday circulation descending and see the first 5
* use gsort to sort descending; add - to variable to indicate descending
gsort -Weekday
list publicationname Weekday in 1/5


* can label variables and data set
label variable State "US states and Canadian provinces and territories"
label data "Newspaper data obtained from Alliance for Audited Media (AAM)"

* can add notes to data 
note: This data was downloaded from http://www.auditedmedia.com/

* can add notes to variables; use /// to continue command across line breaks
notes Type:  BE = Branded Edition, CND = Community Daily Newspaper, ///
			 CNW = Community Weekly Newspaper, DLY = Daily Newspaper, ///
			 WKL = Weekly Newspaper
describe
notes
			 
*************************
* DESCRIPTIVE STATISTICS

* two main commands: tabulate and summarize

* categorical variables (levels)
tabulate reportyear
tabulate Type
* two-way tables
tabulate State Type
tabulate State Type, row
tab reportmonth reportyear, column
tab reportmonth reportyear if Weekday > 100000, column

* numeric variables 
summarize SunSat
summ SunSat, detail
summarize SunSat Weekday 
summarize SunSat if State=="VA"
summarize SunSat if State=="CA" & Type=="DLY"

* summarize stores certain values in memory which can be used in calculations
* see stored values
summarize SunSat
return list 
display r(mean)
* create variable of centered values for SunSat
gen centerSunSat = SunSat - r(mean)

* one- and two-way tables of summary statistics
tabulate Type, summarize(Weekday)
tabulate State Type if State=="VA" | State=="MD" | State=="DE", summarize(Weekday)


*************************
* BASIC GRAPHS

* Stata has powerful graphical facilities. As a consequence the code for
* creating nice graphs can get complicated. 

* Here are two good graphics tutorials:
* http://data.princeton.edu/stata/graphics.html
* http://www.ssc.wisc.edu/sscc/pubs/4-24.htm

* Don't forget: Google is your friend

* histograms
hist SunSat 
hist Weekday /*notice the first graph has been replaced*/

* how to keep multiple graphs open: name them
hist SunSat, name(hist1)
hist Weekday, name(hist2)

* to have multiple graphs in tabs: set autotabgraphs on
set autotabgraphs on
hist SunSat, name(hist1, replace)
hist Weekday, name(hist2, replace)

* if you close graphs, they're not gone! They're in memory:
graph dir
graph display hist1

* to drop graphs from memory
graph drop hist1
graph drop _all /*drop everything*/

* bar graph of means
graph bar SunSat, over(Type) 
graph bar SunSat Weekday, over(Type)

* bar graph of counts (trickier than it should be)
graph bar (count) id, over(Type)

* box plots
graph box SunSat, over(Type)
graph box SunSat if State=="VA", over(Type)
* omit the empty category
graph box SunSat if State=="VA", over(Type) nofill

* scatter plot
graph twoway scatter Weekday SunSat

* let's spiff it up...
* add linear regression line using lfit
graph twoway (scatter Weekday SunSat) (lfit Weekday SunSat) 
* add y = x reference line (trick: plot Weekday against itself)
* use || to submit two graphing commands
graph twoway (scatter Weekday SunSat) (lfit Weekday SunSat) ///
	|| line Weekday Weekday
* fix legend to identify two different lines; add x-axis title
* order(2 3) says keep 2nd and 3rd legend items
* label(3 ...) says label the 3rd item
graph twoway (scatter Weekday SunSat) (lfit Weekday SunSat) ///
	|| line Weekday Weekday, legend(order(2 3) label(3 "Reference Line")) ///
	xtitle(SunSat)

* the y-axis labels are stepping over each other
* quickest fix: rescale the numbers to 1000s of subscribers
gen SunSatK = SunSat/1000
gen WeekdayK = Weekday/1000

* redo graph, add a title
graph twoway (scatter WeekdayK SunSatK) (lfit WeekdayK SunSatK) ///
	|| line WeekdayK WeekdayK, legend(order(2 3) label(3 "Reference Line")) ///
	xtitle(Sunday/Saturday) ytitle(Weekday) ///
	title("Weekday versus Weekend subscriptions") ///
	subtitle("Thousands of subscribers")

* save graph as high-res image file; see "help graph export"
graph export figure1.tif


*************************
* BASIC STATISTICS

* In this section we'll use data sets available from Stata
* if included with Stata installation, use 'sysuse'
* if on the Stata website, use 'webuse'

* T TEST
help ttest

* load data from Stata web site and examine
* "webuse" allows you to load sample data from Stata web site
webuse fuel3, clear 
describe
list

* mean of mpg for each level of treated
tabulate treated, summarize(mpg)
* or use the mean command
mean mpg, over(treated)
* visualize
graph box mpg, over(treated)

* do a two-sample t test; does mean mpg differ by group?
ttest mpg, by(treated) // assuming equal variances
ttest mpg, by(treated) unequal // assuming unequal variances


* ANOVA (Analysis of Variance)
search anova
help anova
help oneway

* load data from Stata web site and examine
webuse systolic
describe
list

* mean of systolic increase for each level of drug
mean systolic, over(drug)
graph box systolic, over(drug)

* oneway ANOVA; does mean systolic increase differ by drug (4 levels)?
oneway systolic drug

* multiple-comparison test
oneway systolic drug, bonferroni

		
* REGRESSION
help regress
webuse auto
describe
list

* examine distribution of mpg
hist mpg, norm

* examine mpg vs. weight by foreign
* separate graphs
graph twoway scatter mpg weight, by(foreign)
* combined
graph twoway (scatter mpg weight if foreign==0) (scatter mpg weight if foreign==1), ///
	legend(label(1 domestic) label(2 foreign)) 

* polynomial regression with weight
generate weightSq = weight^2
regress mpg weight weightSq

* predict values and draw the fitted curve on scatter plot
predict yhat
twoway (scatter mpg weight) (line yhat weight, sort)

* plot residuals versus predicted values; rvf = residuals vs. fitted
rvfplot

* end do file with 
log close
