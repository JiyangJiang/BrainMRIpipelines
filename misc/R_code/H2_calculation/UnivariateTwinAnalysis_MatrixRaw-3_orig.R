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
# https://openmx.ssri.psu.edu//sites/default/files/UnivariateTwinAnalysis_MatrixRaw-3.R
#

require(OpenMx)

#Prepare Data
# -----------------------------------------------------------------------
data(twinData)
summary(twinData)
selVars <- c('bmi1','bmi2')
mzfData <- as.matrix(subset(twinData, zyg==1, c(bmi1,bmi2)))
dzfData <- as.matrix(subset(twinData, zyg==3, c(bmi1,bmi2)))
colMeans(mzfData,na.rm=TRUE)
colMeans(dzfData,na.rm=TRUE)
cov(mzfData,use="complete")
cov(dzfData,use="complete")

# Fake up some Age & Sex data for the sample
require(MASS)
# simulate age in centuries, uniform distribution
ageT1MZ<-runif(n=length(mzfData),0,1)
ageT2MZ<-runif(n=length(mzfData),0,1)
ageT1DZ<-runif(n=length(dzfData),0,1)
ageT2DZ<-runif(n=length(dzfData),0,1)

# simulate binary 0/1 sex variable
sexT1MZ<-cut(as.vector(runif(n=length(mzfData),0,1)), c(-Inf,0.5,Inf), labels=F)
sexT2MZ<-cut(as.vector(runif(n=length(mzfData),0,1)), c(-Inf,0.5,Inf), labels=F)
sexT1DZ<-cut(as.vector(runif(n=length(dzfData),0,1)), c(-Inf,0.5,Inf), labels=F)
sexT2DZ<-cut(as.vector(runif(n=length(dzfData),0,1)), c(-Inf,0.5,Inf), labels=F)

mzData<-data.frame(mzfData,ageT1MZ,ageT2MZ,sexT1MZ,sexT2MZ)
dzData<-data.frame(dzfData,ageT1DZ,ageT2DZ,sexT1DZ,sexT2DZ)
head(mzData)
head(mzData)
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

	mxModel("MZ", mxData( observed=mzData, type="raw" ),
    # Algebra for making the means a function of the definition variables age and sex
        mxMatrix( type="Full", nrow=2, ncol=2, free=F, label=c("data.ageT1MZ","data.sexT1MZ","data.ageT2MZ","data.sexT2MZ"), name="MZDefVars"),
        mxAlgebra( expression=twinACE.expMean + twinACE.beta %*% MZDefVars, name="expMeanMZ"),
	    mxFIMLObjective( covariance="twinACE.expCovMZ", means="expMeanMZ", dimnames=selVars )	),
	mxModel("DZ", mxData( observed=dzData, type="raw" ),
        mxMatrix( type="Full", nrow=2, ncol=2, free=F, label=c("data.ageT1DZ","data.sexT1DZ","data.ageT2DZ","data.sexT2DZ"), name="DZDefVars"),
        mxAlgebra( expression=twinACE.expMean + twinACE.beta %*% DZDefVars, name="expMeanDZ"),
	    mxFIMLObjective( covariance="twinACE.expCovDZ", means="expMeanDZ", dimnames=selVars )	),
    mxAlgebra( expression=MZ.objective + DZ.objective, name="twin" ),
	mxAlgebraObjective("twin")
)

#Run ACE model
# -----------------------------------------------------------------------
twinACEFit <- mxRun(twinACEModel)
summary(twinACEFit)
