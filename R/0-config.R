
#-------------------------------
# 0-config.R
# configure data directories
# source base functions
# load libraries
#-------------------------------


#----------------------------
# worker packages
#----------------------------
library(here)
library(tidyverse)
library(lubridate)
library(haven)
library(renv)
library(skimr)
library(osfr)

# ---------------------
# analysis packages
# ---------------------
library(lme4)
library(sandwich)
library(lmtest)
library(emmeans)

#----------------------------
# display packages
#----------------------------
library(rmarkdown)
library(yaml)
library(table1)
library(kableExtra)
library(ggplot2)
library(patchwork)
library(RColorBrewer)

#----------------------------
# parallel computing packages
#----------------------------
library(foreach)
library(doParallel)
registerDoParallel(detectCores() - 1)

#----------------------------
# pathogen list
#----------------------------
pathogen_labels <- c("Norovirus GI/GII","LT-ETEC (LTB)","Campylobacter (p18,p39)","Shigella/EIEC (IpaB)","S. enterica typhi (HylE)","S. enterica (LPS B,D)","Cholera (OSP-Inaba/Ogawa)","Cryptosporidium (Cp17,Cp23)","Giardia (VSP-5)","E. histolytica (LecA)","T. solium (T24,Es33)","S. stercoralis (NIE)")


#----------------------------
# custom color palettes
#----------------------------
library(viridis)
library(RColorBrewer)

# safe color blind palette
# http://jfly.iam.u-tokyo.ac.jp/color/
# http://www.cookbook-r.com/Graphs/Colors_(ggplot2)/
# Reference: Bang Wong, Nature Methods 2011: https://www.nature.com/articles/nmeth.1618
cbpal <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

# NY Times rainbow palettes from the Upshot
# https://www.nytimes.com/interactive/2020/03/21/upshot/coronavirus-deaths-by-country.html
nytpal <- c("#510000", "#AC112D", "#EC6D47", "#F2A058", "#F7D269", "#839772", "#325D8A")

# https://www.nytimes.com/2020/04/23/us/coronavirus-early-outbreaks-cities.html
nytpal2 <- c("#7486AD", "#77658E","#A1493B","#C17B3F", "#E6CA83")


# four color palette, cb friendly. #4 is perceptual midpoint between 2,3
# created using help from GPT5o
# teal = cool, orange = warm, 
# olive (neutralized earth tone), reads as both present
# "The combined-intervention color was defined as the perceptual midpoint 
# of the single-intervention colors in LAB color space."
# control, WASH, Nutrition, WASH+Nutrition

# blue-orange version (not used)
# cbpal_int <- c("#2B2B2B", "#4C8C8A", "#D08C60","#8A8F73")

# purple-green variation 
cbpal_int <- c("#2B2B2B", "#8AA05A", "#6B7AA1", "#A7B0A8")



