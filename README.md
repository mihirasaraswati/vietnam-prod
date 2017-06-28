### Introduction

VA’s National Center Veteran Analysis and Statistics (NCVAS) publishes a number of reports on and profiles of Veterans. The profiles mainly focus on the demographic characteristics of a particular Veteran cohort (e.g. period of service, race/ethnic group) and provide a number of statistics on topics like income, education, health, benefits received and utilization of VA services. This repository has the code that creates the Profile of Vietnam War Veterans. Since I used R to make the profile of Vietnam War Era Veterans, I created this repository to manage the R project files and more importantly to ensure transparency and as much as possible, reproducibility. 

This repository has scripts and the R Markdown file needed to create the Profile of Vietnam War Veterans. Since the raw data files and the survey objects are quite large they are not in the repository. One of the two scripts will download the relevant data files. The second script assigns data types to some of the variable and creates survey objects so that the data can be analyzed. The R Markdown file creates slides based on the LaTeX Beamer template. You will also see other files like the customized Beamer template, cover slide, and VA utilization data. 

My intent was to ensure reproducibility but I did end up making quite a few edits to Beamer (pdf) slides using Adobe Pro - it so much more easy to make cosmetic changes using Adobe Pro than it is to customize the Beamer template given my limited knowledge of LaTeX. In spite of these manual edits the main pieces (getting, setting up, and creating statistics) of the profile are reproducible. 

### Required Packages

The following R packages are required:

1. survey
2. dplyr
3. RColorBrewer

### Step 1 - Setup the Rproject and from the GitHub repository

The first step in reproducing this profile is to create a R project from the GitHub repository. You will need to have R, R Studio, and Git installed on your machine. The tutorials from the [RStudio Support Site](https://support.rstudio.com/hc/en-us/articles/200532077-Version-Control-with-Git-and-SVN) and the [Data Surg blog](http://www.datasurg.net/2015/07/13/rstudio-and-github/) will help get setup with these tools. 
                                                                                                                       
### Step 2 - Getting the data
        
The script *[Code_Data_Collect.R](https://github.com/mihiriyer/vietnam-prod/blob/master/Code_Data_Collect.R)*, will download the 2015 American Community Survey (ASC) Public Use Microdata Sample (PUMS) file (csv format) from the Census website. The script will download both the Person and Housing files for the United States and Puerto Rico, consolidate them, and finally save them as Rds files (which are slightly more compact than the csv format). The PUMS csv and Rds files will downloaded to the Raw_Data folder and the all file names have been added to the *.gitignore* file so that they don't get added to repository and as such if they are not ignored pushes to repository will fail because of their large size. 

### Step 3 - Preparing the data and creating the survey design objects 

The next step after downloading is to setup the data which is accomplished with the *[Code_Data_Prepartion.R](https://github.com/mihiriyer/vietnam-prod/blob/master/Code_Data_Preparation.R)* script. This consists of assigning data types to variables (Person and Housing files) being studied and then creating the survey design objects to calculate statistics like totals, means, quartiles, etc. The survey design objects get saved as Rds files and similar to  the raw data files they have been added to the *.gitignore* file so that they don't get pushed to the repository. 

In my approach for creating the survey design objects I keep the Person and Housing records separate and merge/join when needed for a specific calculation. So I create one object out of the Person file that includes only the variables under study along with the weights. After creating this object, *prof_design* (see lines 264 to 273), I subset on the MIL and Period variables to create an object that consist of Veterans who served in the Vietnam war. This object is called *Data_Viet_Design.Rds*. I also subset the *prof_design* to include civilians over the age of 55 years to comparisons with Vietnam Veterans who are at minimum 55 years old. This object is called *Data_Per55_Design.Rds*. Similarly, I create an object with the Housing record including only the variables being studied, this object is called *hou_prof_design*. Then using the SERIALNO from the Vietnam Veterans survey object, *Data_Viet_Design.Rds*, I subset the housing so that it consists of housing records for Vietnam Veterans, this object is saved as *Data_Hou_Viet_Design.Rds*. In the same fashion, I create a survey object that consists of housing records for civilians aged 55 and above, this object is named *Data_Hou55_Design.Rds*. 

#### *Note on Group Quarters*

The Housing Type variable in the Housing file distinguishes whether the record describes a housing unit versus a group quarter. This variable presents a unique situation because even though it is a housing variable it requires using weights from the Person to estimate totals, means, etc. I verified this by starting a conversation on the [ACS Data Community Forum](https://acsdatacommunity.prb.org/acs-data-products--resources/acs-public-use-microdata-samples-pums/f/5/t/266). Given this requirement I created separate survey design objects, *Data_Per_Viet_GQ_Design.Rds* and *Data_Per55_GQ_Design.Rds*. 

### Step 4 - Creating the profile

The profile itself is a a set of LaTeX Beamer slides and is created with the R Markdown document called *Vietnam_Vet_Profile_DRAFT.Rmd*. I left the word draft in the filename so that the pdf that gets generated also bears the same and can be disitnguished from final version which I edited manually with Adobe Pro. The manual edits I made consist of removing text (source) from the footer on certain slides and also modifying the source text on the utilization slide. I also modified the default Beamer template, this template file is named *default-beamer-twocol.tex* and is essential to knitting the R Markdown document. 

#### *Beamer template customization*

1. Custom command to create two columns within which a R chunk can be processed. 
2. Custom command to apply the tiny command on text output from r.
3. Add the words "Table of Contents" to the Table of Contents slide.
4. Remove footer text from the Table of Contents slide. 
5. Color the slide header background blue and font black. 
6. Color hyperlinks blue.
7. Add footer text (source and page number) to slides.
