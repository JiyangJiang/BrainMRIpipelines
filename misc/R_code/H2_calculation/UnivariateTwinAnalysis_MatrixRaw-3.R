#
#   Copyright 2007-2010 The OpenMx Project
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
# 
#        http://www.apache.org/licenses/LICENSE-2.0
# 
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

# -----------------------------------------------------------------------
# Program: UnivariateTwinAnalysis_MatrixRaw.R  
#  Author: Hermine Maes
#    Date: 08 01 2009 
#
# Univariate Twin Analysis model to estimate causes of variation (ACE)
# Matrix style model input - Raw data input
#
# Revision History
#   Hermine Maes -- 10 08 2009 updated & reformatted
# -----------------------------------------------------------------------
#
#
# https://openmx.ssri.psu.edu//sites/default/files/UnivariateTwinAnalysis_MatrixRaw-3.R
#
setwd("~/Dropbox/Jiyang/CNSP/CNS/R_code/H2_calculation")

require(OpenMx)
require(psych)
source("GenEpiHelperFunctions.R")


### Data import
ASL_results = read.csv("ASLtbx2_part1_shrinked_wide_forR.csv", header = TRUE)

#Prepare Data
# -----------------------------------------------------------------------
# data(ASL_results)
summary(ASL_results)

# ========================= #
# ASLtbx2 - vox - raw score #
# ========================= #
# selVars = c("meanCBF_raw_vox_1", "meanCBF_raw_vox_2")
# selVars = c("meanCBF_tissOutlierRm_vox_1", "meanCBF_tissOutlierRm_vox_2")
# selVars = c("meanCBF_tissOutlierRm_GM_vox_1", "meanCBF_tissOutlierRm_GM_vox_2")
# selVars = c("meanCBF_tissOutlierRm_WM_vox_1", "meanCBF_tissOutlierRm_WM_vox_2")
# selVars = c("meanCBF_tissOutlierRm_caudate_vox_1", "meanCBF_tissOutlierRm_caudate_vox_2")
# selVars = c("meanCBF_tissOutlierRm_cerebellum_vox_1", "meanCBF_tissOutlierRm_cerebellum_vox_2")
# selVars = c("meanCBF_tissOutlierRm_frontal_vox_1", "meanCBF_tissOutlierRm_frontal_vox_2")
# selVars = c("meanCBF_tissOutlierRm_insula_vox_1", "meanCBF_tissOutlierRm_insula_vox_2")
# selVars = c("meanCBF_tissOutlierRm_occipital_vox_1", "meanCBF_tissOutlierRm_occipital_vox_2")
# selVars = c("meanCBF_tissOutlierRm_parietal_vox_1", "meanCBF_tissOutlierRm_parietal_vox_2")
# selVars = c("meanCBF_tissOutlierRm_putamen_vox_1", "meanCBF_tissOutlierRm_putamen_vox_2")
# selVars = c("meanCBF_tissOutlierRm_temporal_vox_1", "meanCBF_tissOutlierRm_temporal_vox_2")
# selVars = c("meanCBF_tissOutlierRm_thalamus_vox_1", "meanCBF_tissOutlierRm_thalamus_vox_2")

# ======================= #
# ASLtbx2 - vox - Z score #
# ======================= #
# selVars = c("ZmeanCBF_raw_vox_1", "ZmeanCBF_raw_vox_2")
# selVars = c("ZmeanCBF_tissOutlierRm_vox_1", "ZmeanCBF_tissOutlierRm_vox_2")
# selVars = c("ZmeanCBF_tissOutlierRm_GM_vox_1", "ZmeanCBF_tissOutlierRm_GM_vox_2")
# selVars = c("ZmeanCBF_tissOutlierRm_WM_vox_1", "ZmeanCBF_tissOutlierRm_WM_vox_2")
# selVars = c("ZmeanCBF_tissOutlierRm_caudate_vox_1", "ZmeanCBF_tissOutlierRm_caudate_vox_2")
# selVars = c("ZmeanCBF_tissOutlierRm_cerebellum_vox_1", "ZmeanCBF_tissOutlierRm_cerebellum_vox_2")
# selVars = c("ZmeanCBF_tissOutlierRm_frontal_vox_1", "ZmeanCBF_tissOutlierRm_frontal_vox_2")
# selVars = c("ZmeanCBF_tissOutlierRm_insula_vox_1", "ZmeanCBF_tissOutlierRm_insula_vox_2")
# selVars = c("ZmeanCBF_tissOutlierRm_occipital_vox_1", "ZmeanCBF_tissOutlierRm_occipital_vox_2")
# selVars = c("ZmeanCBF_tissOutlierRm_parietal_vox_1", "ZmeanCBF_tissOutlierRm_parietal_vox_2")
# selVars = c("ZmeanCBF_tissOutlierRm_putamen_vox_1", "ZmeanCBF_tissOutlierRm_putamen_vox_2")
# selVars = c("ZmeanCBF_tissOutlierRm_temporal_vox_1", "ZmeanCBF_tissOutlierRm_temporal_vox_2")
selVars = c("meanCBF_tissOutlierRm_thalamus_vox_1", "meanCBF_tissOutlierRm_thalamus_vox_2")

mzfData <- as.matrix(subset(ASL_results, zyg=="MZ", selVars))
dzfData <- as.matrix(subset(ASL_results, zyg=="DZ", selVars))

colMeans(mzfData,na.rm=TRUE)
colMeans(dzfData,na.rm=TRUE)
cov(mzfData,use="complete")
cov(dzfData,use="complete")

# # Fake up some Age & Sex data for the sample
# require(MASS)
# # simulate age in centuries, uniform distribution
ageT1MZ <- as.matrix(subset(ASL_results, zyg=="MZ", age_in_day_1))
ageT2MZ <- as.matrix(subset(ASL_results, zyg=="MZ", age_in_day_2))
ageT1DZ <- as.matrix(subset(ASL_results, zyg=="DZ", age_in_day_1))
ageT2DZ <- as.matrix(subset(ASL_results, zyg=="DZ", age_in_day_2))

# simulate binary 0/1 sex variable
sexT1MZ <- as.matrix(subset(ASL_results, zyg=="MZ", Sex01_1))
sexT2MZ <- as.matrix(subset(ASL_results, zyg=="MZ", Sex01_2))
sexT1DZ <- as.matrix(subset(ASL_results, zyg=="DZ", Sex01_1))
sexT2DZ <- as.matrix(subset(ASL_results, zyg=="DZ", Sex01_2))

mzData <- data.frame(mzfData,ageT1MZ,ageT2MZ,sexT1MZ,sexT2MZ)
dzData <- data.frame(dzfData,ageT1DZ,ageT2DZ,sexT1DZ,sexT2DZ)

# mzData <- data.frame(mzfData=mzfData,ageT1MZ=ageT1MZ,ageT2MZ=ageT2MZ,sexT1MZ=sexT1MZ,sexT2MZ=sexT2MZ)
# dzData <- data.frame(dzfData=dzfData,ageT1DZ=ageT1DZ,ageT2DZ=ageT2DZ,sexT1DZ=sexT1DZ,sexT2DZ=sexT2DZ)


#Fit ACE Model with RawData and Matrices Input
# -----------------------------------------------------------------------
twinACEModel <- mxModel("twinACE",
	# Matrices X, Y, and Z to store a, c, and e path coefficients
	mxMatrix( type="Full", nrow=1, ncol=1, free=TRUE, values=.6, label="a", name="X" ),
	mxMatrix( type="Full", nrow=1, ncol=1, free=TRUE, values=.6, label="c", name="Y" ),
	mxMatrix( type="Full", nrow=1, ncol=1, free=TRUE, values=.6, label="e", name="Z" ),
	# Matrices A, C, and E compute variance components
	mxAlgebra( expression=X %*% t(X), name="A" ),
	mxAlgebra( expression=Y %*% t(Y), name="C" ),
	mxAlgebra( expression=Z %*% t(Z), name="E" ),

	mxMatrix( type="Full", nrow=1, ncol=2, free=TRUE, values= 20, label="mean", name="expMean" ),
    # Declare a matrix for the definition variable regression parameters, called beta
    mxMatrix( type="Full", nrow=1, ncol=2, free=TRUE, values= 0, label=c("betaAge","betaSex"), name="beta"),
    # Algebra for expected variance/covariance matrix in MZ
    mxAlgebra(
		expression= rbind  (cbind(A+C+E , A+C),
							cbind(A+C   , A+C+E) ), 
		name="expCovMZ"),
    # Algebra for expected variance/covariance matrix in DZ
    # note use of 0.5, converted to 1*1 matrix
    mxAlgebra(
		expression= rbind  (cbind(A+C+E     , 0.5%x%A+C),
							cbind(0.5%x%A+C , A+C+E) ), 
		name="expCovDZ"),


	# Algebra for making the means a function of the definition variables age and sex
	mxModel("MZ", mxData( observed=mzData, type="raw" ),
	        mxMatrix( type="Full", nrow=2, ncol=2, free=F, label=c("data.age_in_day_1",
	        													   "data.Sex01_1",
	        													   "data.age_in_day_2",
	        													   "data.Sex01_2"), name="MZDefVars"),
	        mxAlgebra( expression=twinACE.expMean + twinACE.beta %*% MZDefVars, name="expMeanMZ"),
		    mxFIMLObjective( covariance="twinACE.expCovMZ", means="expMeanMZ", dimnames=selVars ) ),
	mxModel("DZ", mxData( observed=dzData, type="raw" ),
	        mxMatrix( type="Full", nrow=2, ncol=2, free=F, label=c("data.age_in_day_1",
	        													   "data.Sex01_1",
	        													   "data.age_in_day_2",
	        													   "data.Sex01_2"), name="DZDefVars"),
	        mxAlgebra( expression=twinACE.expMean + twinACE.beta %*% DZDefVars, name="expMeanDZ"),
		    mxFIMLObjective( covariance="twinACE.expCovDZ", means="expMeanDZ", dimnames=selVars ) ),


	# Algebra to compute total variances and standard deviations (diagonal only)
    mxAlgebra( expression=A+C+E, name="V" ),
    mxMatrix( type="Iden", nrow=1, ncol=1, name="I"),
    mxAlgebra( expression=solve(sqrt(I*V)), name="iSD"),
    # Algebra to compute standardized path estimares and variance components
    mxAlgebra( expression=a%*%iSD, name="sta"),
    mxAlgebra( expression=c%*%iSD, name="stc"),
    mxAlgebra( expression=e%*%iSD, name="ste"),
    mxAlgebra( expression=A/V, name="h2"),
    mxAlgebra( expression=C/V, name="c2"),
    mxAlgebra( expression=E/V, name="e2"),


    mxAlgebra( expression=MZ.objective + DZ.objective, name="twin" ),
	mxAlgebraObjective("twin")
)

#Run ACE model
# -----------------------------------------------------------------------
twinACEFit <- mxRun(twinACEModel)
summary(twinACEFit)

twinACEFit$twinACE.h2
twinACEFit$twinACE.c2
twinACEFit$twinACE.e2
twinACEFit$twinACE.sta
twinACEFit$twinACE.stc
twinACEFit$twinACE.ste
