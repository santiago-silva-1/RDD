*Hansen Replication
*Santiago Silva
*Feb 19, 2021
*the purpose of this file is to replicate the figures we are after, then I will format everything in a different file (a stmd file) to have the final result in Markdown
*this is research has a regression discontinuity design, a sharp RDD



*1)
*first we load the data 
use https://github.com/scunning1975/causal-inference-class/raw/master/hansen_dwi, clear
eststo clear

*link to my repo is https://github.com/santiago-silva-1/RDD

*we want to know what we are dealing with
sum Alcohol1 Alcohol2 low_score male white recidivism acc aged year bac1 bac2
*also look at the variables in the data editor tab
*the outcome variable is "recidivism", which measures whether the person showed back ip in the data within 4 months.

*2)github
*summary of the paper.
*What is the research question?
*what data does Hansen use?
*What is the research design?
*what are his conclusions?

*3)Create a dummy equaling 1 if bac1>= 0.08 and 0 otherwise
gen D = 0
replace D = 1 if bac1>=0.08

*4)The first thing to do in any RDD is look at the raw data and see if there’s any evidence for manipulation (“sorting on the running variable”). If people were capable of manipulatingd their blood alcohol content (bac1), describe the test we would use to check for this.  Now evaluate whether you see this in these data?  Either recreate Figure 1 using the bac1 variable as your measure of blood alcohol content or use your own density test from software.  Do you find evidence for sorting on the running variable? Explain your results.  Compare what you found to what Hansen found.

*manupilation in the running variable is one of the most common viloations for smothness. we can use the McCrady Desnity test, look at slide 317
*Now we run the density test on our running variable, we declare the cutoff at 0.08, and we plot the result 
rddensity bac1, c(0.08) plot
*confidence intervals intersect, no violation of discontiniity 
*hansen didnt find a violation of density either
*this does look like the corresponding part of Hanses's Figure1


*5)Balance test
*The second thing we need to do is check for covariate balance. Recreate Table 2 Panel A but only white male, age and accident (acc) as dependent variables.  Use your equation 1) for this. Are the covariates balanced at the cutoff?  It’s okay if they are not exactly the same as Hansen’s.

*What we do in a covariate balance test is we run our main equation again, our model, but now instead of using the dependent variable we have been usign-the outcome variable, which is "recid"-, now we are going to run the model on "feature predetermine characteristics of drivers which should remain unchanged at the threshold". In this case we are using: white, male, age, and accident at the scene. 

*the model is recidivism= beta_0 + b_1 D + b_2 bac1 + b_3 D*bac_1
*if we use command xi and i. we do not need to create an interaction term, ststa will do it for us and will run the regression on the treatment variable (D) , the running variable, and the interaction term
*the research also re-centers the running variable at the cutoff, but this is not in the replication directions. 
quietly eststo: xi: reg male i.D*bac1
quietly eststo: xi: reg white i.D*bac1
quietly eststo: xi: reg aged i.D*bac1
quietly eststo: xi: reg acc i.D*bac1
esttab, title(Table 2 Panel A) compress
eststo clear

*the covariates are balanced at the cutoffs



*6) Balance Pictures
*Recreate Figure 2 panel A-D. You can use the -cmogram- command in Stata to do this. Fit both linear and quadratic with confidence intervals. Discuss what you find and compare it with Hansen’s paper.

*now that we checked if the covariates are balanced we also want a picture, the covariates should be balanced across the cutoff. Remember that the running variable is bac1 with a cutoff at 0.08 and the predetermined characteristics we used as the dependent variable for the balance test are: white, male, age, and accident.

* do linear coefficients first 
quietly cmogram acc bac1, cut(0.08) title(Panel A. Accident at scene) scatter lfitci legend lineat(.08)
*graph export Figure1.png , replace
*![Linear Fit](Figure1.png).
quietly cmogram male bac1, cut(0.08) title(Panel B. Male) scatter lfitci legend lineat(.08)
quietly cmogram aged bac1, cut(0.08) title(Panel C. Age) scatter lfitci legend lineat(.08)
quietly cmogram white bac1, cut(0.08) title(Panel D. White) scatter lfitci legend lineat(.08)

*now repeat for quadratic 
quietly cmogram acc bac1, cut(0.08) title(Panel A. Accident at scene) scatter qfitci legend lineat(.08)
quietly cmogram male bac1, cut(0.08) title(Panel B. Male) scatter qfitci legend lineat(.08)
quietly cmogram aged bac1, cut(0.08) title(Panel C. Age) scatter qfitci legend lineat(.08)
quietly cmogram white bac1, cut(0.08) title(Panel D. White) scatter qfitci legend lineat(.08)

*the graphs are very similar to Hansen's we do not have jumping where there should not be jumping, so we pass the balance test


*7) Table 3
*Estimate equation (1) with recidivism (recid) as the outcome. This corresponds to Table 3 column 1, but since I am missing some of his variables, your sample size will be the entire dataset of 214,558. Nevertheless, replicate Table 3, column 1, Panels A and B.  Note that these are local linear regressions and Panel A uses as its bandwidth 0.03 to 0.13.  But Panel B has a narrower bandwidth of 0.055 to 0.105.  Your table should have three columns and two A and B panels associated with the different bandwidths.:


*the model is recidivism= beta_0 + b_1 D + b_2 bac1 + b_3 D*bac_1

*column 1 of OUR table will be a simpler version of the model, it will not have the interaction term, and will only control for the bac1 linearly by including a dummy variable for the treatment, D, this will be 0 if bac<0.08 and 0 otherwise
eststo clear
quietly eststo: reg recidivism D bac1 if bac1>0.055 & bac1<0.105, robust
quietly eststo: reg recidivism D bac1 if bac1>0.03 & bac1<0.13, robust

*column 2 is the model Hansen uses
*we run the regression on the interaction term, the tunning variable, and the interaction term
*reacall that to run a regression with an interaction term we use xi command
quietly eststo: xi: reg recidivism i.D*bac1 if bac1>0.055 & bac1<0.105, robust
quietly eststo: xi: reg recidivism i.D*bac1 if bac1>0.03 & bac1<0.13, robust


* column 3 adds a quadratic interaction term to Hansen's model.
*we create the quadratic interaction term, we square the running variable, bac1, not the treatment variable obviously
*the dependent variable, our outcome is still recidivism
*now the independent variables are:
*D , bac1, bac1_sq , interaction term D*bac1 , and second interaction term D*bac1_sq
gen bac1_sq = bac1^2
quietly eststo: xi: reg recidivism D##c.(bac1 bac1_sq) if bac1>0.055 & bac1<0.105, robust 
quietly eststo: xi: reg recidivism D##c.(bac1 bac1_sq) if bac1>0.03 & bac1<0.13, robust 
esttab, title(Table 3 Column 1) compress


*used robust standard errors like part 4 asked

*8) Figure 3, top panel
*"Firue 3 plots means of recidivism rates based on simple regression models for all offedners and highlights the stark changes which occur at the 0.08 threshold"
*Recreate the top panel of Figure 3 according to the following rule:
*Fit linear fit using only observations with less than 0.15 bac on the bac1
*to do this we can create a new variable wich includes only the values for which bac1<0.15
generate D2= 0
replace D2 = 1 if bac1<0.15
quietly cmogram recidivism D2, cut(0.08) title(Table 3. Panel A) scatter lfitci legend lineat(.08)
*graph export Figure1.png , replace
*![Linear Fit](Figure1.png).
*we do see a jump as expected, the causal effect


*Fit quadratic fit using only observations with less than 0.15 bac on the bac1
*so now use quadratic fit option
quietly cmogram recidivism D2, cut(0.08) title(Table 3. Panel A) scatter qfitci legend lineat(.08)
*we do see a jump as expected, the causal effect


*9)Discussion







