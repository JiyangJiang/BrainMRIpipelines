# -----------------------------------------------------------------------
# Program: UnivACE.R  
# Univariate Twin Analysis model to estimate causes of variation (ACE) for continuous data
# Matrix style model input - Raw data input
# -----------------------------------------------------------------------

setwd("~/Dropbox/Jiyang/CNSP/CNS/R_code/H2_calculation")

require(OpenMx)
require(psych)
source("GenEpiHelperFunctions.R")


### Data import
ASL_results = read.csv("ASLtbx2_part1_shrinked_wide_forR.csv", header = TRUE)

# zyg as factor
# ASLtbx2_results$zyg = factor(ASLtbx2_results$zyg, levels= c(1:2),labels= c("MZ", "DZ"))

# ============= #
# ASLtbx2 - vox #
# ============= #
# selVars = c("meanCBF_raw_vox_1", "meanCBF_raw_vox_2")
# selVars = c("meanCBF_tissOutlierRm_vox_1", "meanCBF_tissOutlierRm_vox_2")
selVars = c("meanCBF_tissOutlierRm_GM_vox_1", "meanCBF_tissOutlierRm_GM_vox_2")
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
# ASLtbx2 - csf - fixVal1 #
# ======================= #
# selVars = c("meanCBF_raw_csfFixVal1_1", "meanCBF_raw_csfFixVal1_2")
# selVars = c("meanCBF_tissOutlierRm_csfFixVal1_1", "meanCBF_tissOutlierRm_csfFixVal1_2")
# selVars = c("meanCBF_tissOutlierRm_GM_csfFixVal1_1", "meanCBF_tissOutlierRm_GM_csfFixVal1_2")
# selVars = c("meanCBF_tissOutlierRm_WM_csfFixVal1_1", "meanCBF_tissOutlierRm_WM_csfFixVal1_2")
# selVars = c("meanCBF_tissOutlierRm_caudate_csfFixVal1_1", "meanCBF_tissOutlierRm_caudate_csfFixVal1_2")
# selVars = c("meanCBF_tissOutlierRm_cerebellum_csfFixVal1_1", "meanCBF_tissOutlierRm_cerebellum_csfFixVal1_2")
# selVars = c("meanCBF_tissOutlierRm_frontal_csfFixVal1_1", "meanCBF_tissOutlierRm_frontal_csfFixVal1_2")
# selVars = c("meanCBF_tissOutlierRm_insula_csfFixVal1_1", "meanCBF_tissOutlierRm_insula_csfFixVal1_2")
# selVars = c("meanCBF_tissOutlierRm_occipital_csfFixVal1_1", "meanCBF_tissOutlierRm_occipital_csfFixVal1_2")
# selVars = c("meanCBF_tissOutlierRm_parietal_csfFixVal1_1", "meanCBF_tissOutlierRm_parietal_csfFixVal1_2")
# selVars = c("meanCBF_tissOutlierRm_putamen_csfFixVal1_1", "meanCBF_tissOutlierRm_putamen_csfFixVal1_2")
# selVars = c("meanCBF_tissOutlierRm_temporal_csfFixVal1_1", "meanCBF_tissOutlierRm_temporal_csfFixVal1_2")
# selVars = c("meanCBF_tissOutlierRm_thalamus_csfFixVal1_1", "meanCBF_tissOutlierRm_thalamus_csfFixVal1_2")



# ======================= #
# ASLtbx2 - csf - fixVal2 #
# ======================= #
# selVars = c("meanCBF_raw_csf_fixVal2_1", "meanCBF_raw_csf_fixVal2_2")
# selVars = c("meanCBF_tissOutlierRm_csf_fixVal2_1", "meanCBF_tissOutlierRm_csf_fixVal2_2")
# selVars = c("meanCBF_tissOutlierRm_GM_csf_fixVal2_1", "meanCBF_tissOutlierRm_GM_csf_fixVal2_2")
# selVars = c("meanCBF_tissOutlierRm_WM_csf_fixVal2_1", "meanCBF_tissOutlierRm_WM_csf_fixVal2_2")
# selVars = c("meanCBF_tissOutlierRm_caudate_csf_fixVal2_1", "meanCBF_tissOutlierRm_caudate_csf_fixVal2_2")
# selVars = c("meanCBF_tissOutlierRm_cerebellum_csf_fixVal2_1", "meanCBF_tissOutlierRm_cerebellum_csf_fixVal2_2")
# selVars = c("meanCBF_tissOutlierRm_frontal_csf_fixVal2_1", "meanCBF_tissOutlierRm_frontal_csf_fixVal2_2")
# selVars = c("meanCBF_tissOutlierRm_insula_csf_fixVal2_1", "meanCBF_tissOutlierRm_insula_csf_fixVal2_2")
# selVars = c("meanCBF_tissOutlierRm_occipital_csf_fixVal2_1", "meanCBF_tissOutlierRm_occipital_csf_fixVal2_2")
# selVars = c("meanCBF_tissOutlierRm_parietal_csf_fixVal2_1", "meanCBF_tissOutlierRm_parietal_csf_fixVal2_2")
# selVars = c("meanCBF_tissOutlierRm_putamen_csf_fixVal2_1", "meanCBF_tissOutlierRm_putamen_csf_fixVal2_2")
# selVars = c("meanCBF_tissOutlierRm_temporal_csf_fixVal2_1", "meanCBF_tissOutlierRm_temporal_csf_fixVal2_2")
# selVars = c("meanCBF_tissOutlierRm_thalamus_csf_fixVal2_1", "meanCBF_tissOutlierRm_thalamus_csf_fixVal2_2")



# ====================== #
# ASLtbx2 - wm - fixVal1 #
# ====================== #
# selVars = c("meanCBF_raw_wmFixVal1_1", "meanCBF_raw_wmFixVal1_2")
# selVars = c("meanCBF_tissOutlierRm_wmFixVal1_1", "meanCBF_tissOutlierRm_wmFixVal1_2")
# selVars = c("meanCBF_tissOutlierRm_GM_wmFixVal1_1", "meanCBF_tissOutlierRm_GM_wmFixVal1_2")
# selVars = c("meanCBF_tissOutlierRm_WM_wmFixVal1_1", "meanCBF_tissOutlierRm_WM_wmFixVal1_2")
# selVars = c("meanCBF_tissOutlierRm_caudate_wmFixVal1_1", "meanCBF_tissOutlierRm_caudate_wmFixVal1_2")
# selVars = c("meanCBF_tissOutlierRm_cerebellum_wmFixVal1_1", "meanCBF_tissOutlierRm_cerebellum_wmFixVal1_2")
# selVars = c("meanCBF_tissOutlierRm_frontal_wmFixVal1_1", "meanCBF_tissOutlierRm_frontal_wmFixVal1_2")
# selVars = c("meanCBF_tissOutlierRm_insula_wmFixVal1_1", "meanCBF_tissOutlierRm_insula_wmFixVal1_2")
# selVars = c("meanCBF_tissOutlierRm_occipital_wmFixVal1_1", "meanCBF_tissOutlierRm_occipital_wmFixVal1_2")
# selVars = c("meanCBF_tissOutlierRm_parietal_wmFixVal1_1", "meanCBF_tissOutlierRm_parietal_wmFixVal1_2")
# selVars = c("meanCBF_tissOutlierRm_putamen_wmFixVal1_1", "meanCBF_tissOutlierRm_putamen_wmFixVal1_2")
# selVars = c("meanCBF_tissOutlierRm_temporal_wmFixVal1_1", "meanCBF_tissOutlierRm_temporal_wmFixVal1_2")
# selVars = c("meanCBF_tissOutlierRm_thalamus_wmFixVal1_1", "meanCBF_tissOutlierRm_thalamus_wmFixVal1_2")


# ====================== #
# ASLtbx2 - wm - fixVal2 #
# ====================== #
# selVars = c("meanCBF_raw_wmFixVal2_1", "meanCBF_raw_wmFixVal2_2")
# selVars = c("meanCBF_tissOutlierRm_wmFixVal2_1", "meanCBF_tissOutlierRm_wmFixVal2_2")
# selVars = c("meanCBF_tissOutlierRm_GM_wmFixVal2_1", "meanCBF_tissOutlierRm_GM_wmFixVal2_2")
# selVars = c("meanCBF_tissOutlierRm_WM_wmFixVal2_1", "meanCBF_tissOutlierRm_WM_wmFixVal2_2")
# selVars = c("meanCBF_tissOutlierRm_caudate_wmFixVal2_1", "meanCBF_tissOutlierRm_caudate_wmFixVal2_2")
# selVars = c("meanCBF_tissOutlierRm_cerebellum_wmFixVal2_1", "meanCBF_tissOutlierRm_cerebellum_wmFixVal2_2")
# selVars = c("meanCBF_tissOutlierRm_frontal_wmFixVal2_1", "meanCBF_tissOutlierRm_frontal_wmFixVal2_2")
# selVars = c("meanCBF_tissOutlierRm_insula_wmFixVal2_1", "meanCBF_tissOutlierRm_insula_wmFixVal2_2")
# selVars = c("meanCBF_tissOutlierRm_occipital_wmFixVal2_1", "meanCBF_tissOutlierRm_occipital_wmFixVal2_2")
# selVars = c("meanCBF_tissOutlierRm_parietal_wmFixVal2_1", "meanCBF_tissOutlierRm_parietal_wmFixVal2_2")
# selVars = c("meanCBF_tissOutlierRm_putamen_wmFixVal2_1", "meanCBF_tissOutlierRm_putamen_wmFixVal2_2")
# selVars = c("meanCBF_tissOutlierRm_temporal_wmFixVal2_1", "meanCBF_tissOutlierRm_temporal_wmFixVal2_2")
# selVars = c("meanCBF_tissOutlierRm_thalamus_wmFixVal2_1", "meanCBF_tissOutlierRm_thalamus_wmFixVal2_2")










# selVars = c("globalCBF_native_exclCSF_1", "globalCBF_native_exclCSF_2")



# Prepare Data
#----------------------------------------------------------------------------------------------------------
# Reads data from csv spreadsheet in which mis val were recoded to 'NA'
# Variabels: Famid ADHD1 IQ1 ADHD2 IQ2 zyg (1=MZ, 2=DZ)
# ----------------------------------------------------------------------------------------------------------

nv <- 1			# number of variables for a twin = 1 in Univariate
ntv <- 2*nv		# number of variables for a pair = 2* 1 for Univariate

#twindata <- read.table ('ADHDiq.csv', header=T, sep=',')
# names (ASLtbx2_results)

#selVars <- c('IQ1','IQ2')
mzData <- subset(ASL_results, zyg=="MZ", selVars)
dzData <- subset(ASL_results, zyg=="DZ", selVars)

# Print Descriptive Statistics
# -----------------------------------------------------------------------

# describe(ASLtbx2_results)
# colMeans(mzData,na.rm=TRUE)
# # cov(mzData,use="complete")
# cov(mzData,use="everything")
# colMeans(dzData,na.rm=TRUE)
# # cov(dzData,use="complete")
# cov(dzData,use="everything")

#------------------------------------------------------------------------
# Fit Univariate Saturated Model
# -----------------------------------------------------------------------
univTwinSatModel <- mxModel("univTwinSat",
    mxModel("MZ",
        mxMatrix( type="Lower", nrow=ntv, ncol=ntv, free=TRUE, values=10, name="CholMZ" ),
        mxAlgebra( expression=CholMZ %*% t(CholMZ), name="expCovMZ" ),
        mxMatrix( type="Full", nrow=1, ncol=ntv, free=TRUE, values=90, name="expMeanMZ" ),
        mxData( observed=mzData, type="raw" ),
        mxFIMLObjective( covariance="expCovMZ", means="expMeanMZ", dimnames=selVars),
    # Algebra's needed for equality constraints    
        mxAlgebra( expression=expMeanMZ[1,1:nv], name="expMeanMZt1"),
        mxAlgebra( expression=expMeanMZ[1,(nv+1):ntv], name="expMeanMZt2"),
        mxAlgebra( expression=t(diag2vec(expCovMZ)), name="expVarMZ"),
        mxAlgebra( expression=expVarMZ[1,1:nv], name="expVarMZt1"),
        mxAlgebra( expression=expVarMZ[1,(nv+1):ntv], name="expVarMZt2")
    ),
    mxModel("DZ",
        mxMatrix( type="Lower", nrow=ntv, ncol=ntv, free=TRUE, values=10, name="CholDZ" ),
        mxAlgebra( expression=CholDZ %*% t(CholDZ), name="expCovDZ" ),
        mxMatrix( type="Full", nrow=1, ncol=ntv, free=T, values=90, name="expMeanDZ" ),
        mxData( observed=dzData, type="raw" ),
        mxFIMLObjective( covariance="expCovDZ", means="expMeanDZ", dimnames=selVars),
    # Algebra's needed for equality constraints    
        mxAlgebra( expression=expMeanDZ[1,1:nv], name="expMeanDZt1"),
        mxAlgebra( expression=expMeanDZ[1,(nv+1):ntv], name="expMeanDZt2"),
        mxAlgebra( expression=t(diag2vec(expCovDZ)), name="expVarDZ"),
        mxAlgebra( expression=expVarDZ[1,1:nv], name="expVarDZt1"),
        mxAlgebra( expression=expVarDZ[1,(nv+1):ntv], name="expVarDZt2")
    ),
    mxAlgebra( MZ.objective + DZ.objective, name="min2sumll" ),
    mxAlgebraObjective("min2sumll")
)

univTwinSatFit <- mxRun(univTwinSatModel)
univTwinSatSumm <- summary(univTwinSatFit)
univTwinSatSumm

# Generate Saturated Output
# -----------------------------------------------------------------------
# parameterSpecifications(univTwinSatFit)
# expectedMeansCovariances(univTwinSatFit)
# tableFitStatistics(univTwinSatFit)

        
# Fit ACE Model with RawData and Matrices Input
# -----------------------------------------------------------------------
univACEModel <- mxModel("univACE",
    mxModel("ACE",
    # Matrices a, c, and e to store a, c, and e path coefficients
        mxMatrix( type="Lower", nrow=nv, ncol=nv, free=TRUE, values=10, label="a11", name="a" ), 
        mxMatrix( type="Lower", nrow=nv, ncol=nv, free=TRUE, values=10, label="c11", name="c" ), 
        mxMatrix( type="Lower", nrow=nv, ncol=nv, free=TRUE, values=10, label="e11", name="e" ), 
    # Matrices A, C, and E compute variance components
        mxAlgebra( expression=a %*% t(a), name="A" ),
        mxAlgebra( expression=c %*% t(c), name="C" ),
        mxAlgebra( expression=e %*% t(e), name="E" ),
    # Algebra to compute total variances and standard deviations (diagonal only)
        mxAlgebra( expression=A+C+E, name="V" ),
        mxMatrix( type="Iden", nrow=nv, ncol=nv, name="I"),
        mxAlgebra( expression=solve(sqrt(I*V)), name="iSD"),
    # Algebra to compute standardized path estimares and variance components
        mxAlgebra( expression=a%*%iSD, name="sta"),
        mxAlgebra( expression=c%*%iSD, name="stc"),
        mxAlgebra( expression=e%*%iSD, name="ste"),
        mxAlgebra( expression=A/V, name="h2"),
        mxAlgebra( expression=C/V, name="c2"),
        mxAlgebra( expression=E/V, name="e2"),
    # Note that the rest of the mxModel statements do not change for bivariate/multivariate case
    # Matrix & Algebra for expected means vector
        mxMatrix( type="Full", nrow=1, ncol=nv, free=TRUE, values= 90, label="mean", name="Mean" ),
        mxAlgebra( expression= cbind(Mean,Mean), name="expMean"),
    # Algebra for expected variance/covariance matrix in MZ
        mxAlgebra( expression= rbind  ( cbind(A+C+E , A+C),
                                        cbind(A+C   , A+C+E)), name="expCovMZ" ),
    # Algebra for expected variance/covariance matrix in DZ
        mxAlgebra( expression= rbind  ( cbind(A+C+E     , 0.5%x%A+C),
                                        cbind(0.5%x%A+C , A+C+E)),  name="expCovDZ" ) 
    ),
    mxModel("MZ",
        mxData( observed=mzData, type="raw" ),
        mxFIMLObjective( covariance="ACE.expCovMZ", means="ACE.expMean", dimnames=selVars )
    ),
    mxModel("DZ", 
        mxData( observed=dzData, type="raw" ),
        mxFIMLObjective( covariance="ACE.expCovDZ", means="ACE.expMean", dimnames=selVars ) 
    ),
    mxAlgebra( expression=MZ.objective + DZ.objective, name="m2ACEsumll" ),
    mxAlgebraObjective("m2ACEsumll"),
    mxCI(c('ACE.a', 'ACE.c', 'ACE.e','ACE.A', 'ACE.C', 'ACE.E','ACE.h2', 'ACE.c2', 'ACE.e2'))
    
)

univACEFit <- mxRun(univACEModel, intervals=TRUE)
univACESumm <- summary(univACEFit)
univACESumm
univACEFit$ACE.h2
univACEFit$ACE.c2
univACEFit$ACE.e2
univACEFit$ACE.sta
univACEFit$ACE.stc
univACEFit$ACE.ste


# Generate ACE Output
# -----------------------------------------------------------------------
# parameterSpecifications(univACEFit)
# expectedMeansCovariances(univACEFit)
# tableFitStatistics(univACEFit)
# Generate Table of Parameter Estimates using mxEval
pathEstimatesACE <- mxEval(cbind(ACE.sta,ACE.stc,ACE.ste), univACEFit)
    rownames(pathEstimatesACE) <- 'pathEstimates'
    colnames(pathEstimatesACE) <- c('a','c','e')
pathEstimatesACE

varComponentsACE <- mxEval(cbind(ACE.h2,ACE.c2,ACE.e2), univACEFit)
    rownames(varComponentsACE) <- 'varComponents'
    colnames(varComponentsACE) <- c('a^2','c^2','e^2')
varComponentsACE

# Fit AE model
# -----------------------------------------------------------------------
univAEModel <- mxModel(univACEFit, name="univAE",
    mxModel(univACEFit$ACE,
        mxMatrix( type="Lower", nrow=1, ncol=1, free=FALSE, values=0, label="c11", name="c" ) # drop c at 0
    ),
    mxCI(c('ACE.a', 'ACE.c', 'ACE.e','ACE.A', 'ACE.C', 'ACE.E','ACE.h2', 'ACE.c2', 'ACE.e2'))
    
)
univAEFit <- mxRun(univAEModel)
univAESumm <- summary(univAEFit)
univAESumm

# # Generate AE Output
# # -----------------------------------------------------------------------
# # parameterSpecifications(univAEFit)
# # expectedMeansCovariances(univAEFit)
# # tableFitStatistics(univAEFit)

# Generate Table of Parameter Estimates using mxEval
pathEstimatesAE <- print(round(mxEval(cbind(ACE.sta,ACE.stc,ACE.ste), univAEFit),4))
varComponentsAE <- print(round(mxEval(cbind(ACE.h2,ACE.c2,ACE.e2), univAEFit),4))
	rownames(pathEstimatesAE) <- 'pathEstimates'
	colnames(pathEstimatesAE) <- c('a','c','e')
	rownames(varComponentsAE) <- 'varComponents'
	colnames(varComponentsAE) <- c('a^2','c^2','e^2')
pathEstimatesAE
varComponentsAE


# Fit CE model
# -----------------------------------------------------------------------
univCEModel <- mxModel(univACEFit, name="univCE",
    mxModel(univACEFit$ACE,
        mxMatrix( type="Lower", nrow=1, ncol=1, free=FALSE, values=0, label="a11", name="a" ) # drop a at 0
    ),
    mxCI(c('ACE.a', 'ACE.c', 'ACE.e','ACE.A', 'ACE.C', 'ACE.E','ACE.h2', 'ACE.c2', 'ACE.e2'))
    
)
univCEFit <- mxRun(univCEModel)
univCESumm <- summary(univCEFit)
univCESumm

# # Generate CE Output
# # -----------------------------------------------------------------------
# # parameterSpecifications(univCEFit)
# # expectedMeansCovariances(univCEFit)
# # tableFitStatistics(univCEFit)

# # Generate Table of Parameter Estimates using mxEval
# pathEstimatesCE <- print(round(mxEval(cbind(ACE.sta,ACE.stc,ACE.ste), univCEFit),4))
# varComponentsCE <- print(round(mxEval(cbind(ACE.h2,ACE.c2,ACE.e2), univCEFit),4))
# 	rownames(pathEstimatesCE) <- 'pathEstimates'
# 	colnames(pathEstimatesCE) <- c('a','c','e')
# 	rownames(varComponentsCE) <- 'varComponents'
# 	colnames(varComponentsCE) <- c('a^2','c^2','e^2')
# pathEstimatesCE
# varComponentsCE


# Fit E model
# -----------------------------------------------------------------------
# Note: we call the AE model and drop a, fix it to 0
univEModel <- mxModel(univAEFit, name="univE",
    mxModel(univAEFit$ACE,
        mxMatrix( type="Lower", nrow=1, ncol=1, free=FALSE, values=0, label="a11", name="a" ) # drop a at 0
    ),
    mxCI(c('ACE.a', 'ACE.c', 'ACE.e','ACE.A', 'ACE.C', 'ACE.E','ACE.h2', 'ACE.c2', 'ACE.e2'))
    
)
univEFit <- mxRun(univEModel)
univESumm <- summary(univEFit)
univESumm


# Generates an output table of all submodels (in 'list') compared to Fully Saturated model 
# -----------------------------------------------------------------------
univACENested <- list(univACEFit, univAEFit, univCEFit, univEFit)
tableFitStatistics(univTwinSatFit,univACENested)


# Generates an output table of all submodels (in 'list') compared to previous (Nested models)
# --------------------------------------------------------------------------------------------------------------------------------

Nested.fit <- 	rbind(mxCompare(univACEFit, univAEFit),
	   				  mxCompare(univACEFit, univCEFit)[2,],
	  				  mxCompare(univACEFit, univEFit)[2,])
Nested.fit


