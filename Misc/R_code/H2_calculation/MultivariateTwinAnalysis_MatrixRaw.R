# -----------------------------------------------------------------------
# Program: MultivariateTwinAnalysis_MatrixRaw.R  
#  Author: Hermine Maes
#    Date: 01 13 2010 
#
# Multivariate Twin Saturated model to estimate means and (co)variances across multiple groups
# Multivariate Cholesky ACE model to estimate genetic and environmental sources of variance 
# Matrix style model input - Raw data input
#
# Revision History
#   Hermine Maes -- 02 01 2010 updated & reformatted
#
# downloaded from http://vipbg.vcu.edu/vipbg/Tc24//MultivariateTwinAnalysis_MatrixRaw.R
# -----------------------------------------------------------------------

require(OpenMx)
source("GenEpiHelperFunctions.R")

# Prepare Data
# -----------------------------------------------------------------------
allVars <- c('fan','zyg',
 't1age','t1sex','t1var1','t1var2','t1var3','t1var4','t1var5','t1var6',
 't2age','t2sex','t2var1','t2var2','t2var3','t2var4','t2var5','t2var6')
iqnl <- read.table("myData/iqnl.rec",header=F, na.strings="-1.00",col.names=allVars)
summary(iqnl)
Vars <- c('var1','var2','var3','var4','var5','var6') 
nv <- 6
selVars <- paste("t",c(rep(1,nv),rep(2,nv)),Vars,sep="")
ntv <- nv*2
mzData <- subset(iqnl, zyg<3, selVars)
dzData <- subset(iqnl, zyg>2, selVars)

# Print Descriptive Statistics
# -----------------------------------------------------------------------
summary(mzData)
colMeans(mzData,na.rm=TRUE)
cov(mzData,use="complete")
summary(dzData)
colMeans(dzData,na.rm=TRUE)
cov(dzData,use="complete")

# Fit Multivariate Saturated Model
# -----------------------------------------------------------------------
multiTwinSatModel <- mxModel("multiTwinSat",
    mxModel("MZ",
        mxMatrix( type="Lower", nrow=ntv, ncol=ntv, free=TRUE, values=.5, name="CholMZ" ),
        mxAlgebra( expression=CholMZ %*% t(CholMZ), name="ExpCovMZ" ),
        mxAlgebra( expression=diag2vec(ExpCovMZ), name="ExpVarMZ"),
        mxMatrix( type="Full", nrow=1, ncol=ntv, free=T, values=20, name="ExpMeanMZ" ),
        mxData( observed=mzData, type="raw" ),
        mxFIMLObjective( covariance="ExpCovMZ", means="ExpMeanMZ", dimnames=selVars)
    ),
    mxModel("DZ",
        mxMatrix( type="Lower", nrow=ntv, ncol=ntv, free=TRUE, values=.5, name="CholDZ" ),
        mxAlgebra( expression=CholDZ %*% t(CholDZ), name="ExpCovDZ" ),
        mxAlgebra( expression=diag2vec(ExpCovDZ), name="ExpVarDZ"),
        mxMatrix( type="Full", nrow=1, ncol=ntv, free=T, values=20, name="ExpMeanDZ" ),
        mxData( observed=dzData, type="raw" ),
        mxFIMLObjective( covariance="ExpCovDZ", means="ExpMeanDZ", dimnames=selVars)
    ),
    mxAlgebra( MZ.objective + DZ.objective, name="-2sumll" ),
    mxAlgebraObjective("-2sumll")
)

multiTwinSatFit <- mxRun(multiTwinSatModel)
multiTwinSatSumm <- summary(multiTwinSatFit)

# Generate Saturated Output
# -----------------------------------------------------------------------
parameterSpecifications(multiTwinSatFit)
expectedMeansCovariances(multiTwinSatFit)
tableFitStatistics(multiTwinSatFit)

# Fit Model with Equal Means & Variances across Zygosity
# -----------------------------------------------------------------------
# Constrain expected variances to be equal across groups
multiEqMeansVarsZygModel <- mxModel(multiTwinSatFit, name="multiEqMeansVarsZyg",
    mxModel(multiTwinSatFit$DZ,
        mxConstraint( alg1="MZ.ExpVarMZ", "=", alg2="ExpVarDZ", name="VarMZ=DZ"),
        mxConstraint( alg1="MZ.ExpMeanMZ", "=", alg2="ExpMeanDZ", name="MeanMZ=DZ")
    )
)     
multiEqMeansVarsZygFit <- mxRun(multiEqMeansVarsZygModel)
multiEqMeansVarsZygSumm <- summary(multiEqMeansVarsZygFit)
parameterSpecifications(multiEqMeansVarsZygFit)
tableFitStatistics(multiTwinSatFit, multiEqMeansVarsZygFit)


# Fit Multivariate ACE Model with RawData and Matrices Input
# -----------------------------------------------------------------------
multiCholACEModel <- mxModel("multiCholACE",
    mxModel("ACE",
    # Matrices a, c, and e to store a, c, and e path coefficients
        mxMatrix( type="Lower", nrow=nv, ncol=nv, free=TRUE, values=.6, name="a" ),
        mxMatrix( type="Lower", nrow=nv, ncol=nv, free=TRUE, values=.6, name="c" ),
        mxMatrix( type="Lower", nrow=nv, ncol=nv, free=TRUE, values=.6, name="e" ),
    # Matrices A, C, and E compute variance components
        mxAlgebra( expression=a %*% t(a), name="A" ),
        mxAlgebra( expression=c %*% t(c), name="C" ),
        mxAlgebra( expression=e %*% t(e), name="E" ),
    # Algebra to compute total variances and standard deviations (diagonal only)
        mxAlgebra( expression=A+C+E, name="V" ),
        mxMatrix( type="Iden", nrow=nv, ncol=nv, name="I"),
        mxAlgebra( expression=solve(sqrt(I*V)), name="isd"),
    ## Note that the rest of the mxModel statements do not change for bivariate/multivariate case
    # Matrix & Algebra for expected means vector
        mxMatrix( type="Full", nrow=1, ncol=nv, free=TRUE, values= 80, name="M" ),
        mxAlgebra( expression= cbind(M,M), name="expMean"),
    # Algebra for expected variance/covariance matrix in MZ
        mxAlgebra( expression= rbind  ( cbind(A+C+E , A+C),
                                        cbind(A+C   , A+C+E)), name="expCovMZ" ),
    # Algebra for expected variance/covariance matrix in DZ, note use of 0.5, converted to 1*1 matrix
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
    mxAlgebra( expression=MZ.objective + DZ.objective, name="-2sumll" ),
    mxAlgebraObjective("-2sumll")
)
multiCholACEFit <- mxRun(multiCholACEModel)
multiCholACESumm <- summary(multiCholACEFit)

# Generate Multivariate Cholesky ACE Output
# -----------------------------------------------------------------------
parameterSpecifications(multiCholACEFit)
expectedMeansCovariances(multiCholACEFit)
tableFitStatistics(multiCholACEFit)

# Generate List of Parameter Estimates and Derived Quantities using formatOutputMatrices
ACEpathMatrices <- c("ACE.a","ACE.c","ACE.e","ACE.isd","ACE.isd %*% ACE.a","ACE.isd %*% ACE.c","ACE.isd %*% ACE.e")
ACEpathLabels <- c("pathEst_a","pathEst_c","pathEst_e","sd","stPathEst_a","stPathEst_c","stPathEst_e")
formatOutputMatrices(multiCholACEFit,ACEpathMatrices,ACEpathLabels,4)

ACEcovMatrices <- c("ACE.A","ACE.C","ACE.E","ACE.V","ACE.A/ACE.V","ACE.C/ACE.V","ACE.E/ACE.V")
ACEcovLabels <- c("covComp_A","covComp_C","covComp_E","Var","stCovComp_A","stCovComp_C","stCovComp_E")
formatOutputMatrices(multiCholACEFit,ACEcovMatrices,ACEcovLabels,4)


# Fit Independent Pathway ACE Model with RawData and Matrices Input
# -----------------------------------------------------------------------
nf <- 1
multiIndPathACEModel <- mxModel("multiIndPathACE",
    mxModel("ACE",
    # Matrices ac, cc, and ec to store a, c, and e path coefficients for common factors
        mxMatrix( type="Full", nrow=nv, ncol=nf, free=TRUE, values=.6, name="ac" ),
        mxMatrix( type="Full", nrow=nv, ncol=nf, free=TRUE, values=.6, name="cc" ),
        mxMatrix( type="Full", nrow=nv, ncol=nf, free=TRUE, values=.6, name="ec" ),
    # Matrices as, cs, and es to store a, c, and e path coefficients for specific factors
        mxMatrix( type="Diag", nrow=nv, ncol=nv, free=TRUE, values=4, name="as" ),
        mxMatrix( type="Diag", nrow=nv, ncol=nv, free=TRUE, values=4, name="cs" ),
        mxMatrix( type="Diag", nrow=nv, ncol=nv, free=TRUE, values=5, name="es" ),
    # Matrices A, C, and E compute variance components
        mxAlgebra( expression=ac %*% t(ac) + as %*% t(as), name="A" ),
        mxAlgebra( expression=cc %*% t(cc) + cs %*% t(cs), name="C" ),
        mxAlgebra( expression=ec %*% t(ec) + es %*% t(es), name="E" ),
    # Algebra to compute total variances and standard deviations (diagonal only)
        mxAlgebra( expression=A+C+E, name="V" ),
        mxMatrix( type="Iden", nrow=nv, ncol=nv, name="I"),
        mxAlgebra( expression=solve(sqrt(I*V)), name="isd"),
    ## Note that the rest of the mxModel statements do not change for bivariate/multivariate case
    # Matrix & Algebra for expected means vector
        mxMatrix( type="Full", nrow=1, ncol=nv, free=TRUE, values= 80, name="M" ),
        mxAlgebra( expression= cbind(M,M), name="expMean"),
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
    mxAlgebra( expression=MZ.objective + DZ.objective, name="-2sumll" ),
    mxAlgebraObjective("-2sumll")
)

multiIndPathACEFit <- mxRun(multiIndPathACEModel)
multiIndPathACESumm <- summary(multiIndPathACEFit)

# Generate Independent Pathway ACE Output
# -----------------------------------------------------------------------
parameterSpecifications(multiIndPathACEFit)
tableFitStatistics(multiIndPathACEFit)

ACEpathMatricesC <- c("ACE.ac","ACE.cc","ACE.ec","ACE.isd","ACE.isd %*% ACE.ac","ACE.isd %*% ACE.cc","ACE.isd %*% ACE.ec")
ACEpathLabelsC <- c("pathEst_ac","pathEst_cc","pathEst_ec","sd","stPathEst_ac","stPathEst_cc","stPathEst_ec")
ACEpathMatricesS <- c("ACE.as","ACE.cs","ACE.es","ACE.isd","ACE.isd %*% ACE.as","ACE.isd %*% ACE.cs","ACE.isd %*% ACE.es")
ACEpathLabelsS <- c("pathEst_as","pathEst_cs","pathEst_es","sd","stPathEst_as","stPathEst_cs","stPathEst_es")

formatOutputMatrices(multiIndPathACEFit,ACEpathMatricesC,ACEpathLabelsC,4)
formatOutputMatrices(multiIndPathACEFit,ACEpathMatricesS,ACEpathLabelsS,4)
formatOutputMatrices(multiIndPathACEFit,ACEcovMatrices,ACEcovLabels,4)


# Fit Common Pathway ACE Model with RawData and Matrices Input
# -----------------------------------------------------------------------
multiComPathACEModel <- mxModel("multiComPathACE",
    mxModel("ACE",
    # Matrices ac, cc, and ec to store a, c, and e path coefficients for latent phenotype(s)
        mxMatrix( type="Lower", nrow=nf, ncol=nf, free=TRUE, values=.6, name="a" ),
        mxMatrix( type="Lower", nrow=nf, ncol=nf, free=TRUE, values=.6, name="c" ),
        mxMatrix( type="Lower", nrow=nf, ncol=nf, free=TRUE, values=.6, name="e" ),
    # Matrix and Algebra for constraint on variance of latent phenotype
        mxAlgebra( expression= (a %*% t(a)) + (c %*% t(c)) + (e %*% t(e)), name="VarLP" ),
        mxMatrix( type="Unit", nrow=1, ncol=1, name="Unit"),
        mxConstraint( 'VarLP', '=', 'Unit'),
    # Matrix f for factor loadings on latent phenotype
        mxMatrix( type="Full", nrow=nv, ncol=nf, free=TRUE, values=15, name="f" ),
    # Matrices as, cs, and es to store a, c, and e path coefficients for specific factors
        mxMatrix( type="Diag", nrow=nv, ncol=nv, free=TRUE, values=4, name="as" ),
        mxMatrix( type="Diag", nrow=nv, ncol=nv, free=TRUE, values=4, name="cs" ),
        mxMatrix( type="Diag", nrow=nv, ncol=nv, free=TRUE, values=5, name="es" ),
    # Matrices A, C, and E compute variance components
        mxAlgebra( expression=f %&% (a %*% t(a)) + as %*% t(as), name="A" ),
        mxAlgebra( expression=f %&% (c %*% t(c)) + cs %*% t(cs), name="C" ),
        mxAlgebra( expression=f %&% (e %*% t(e)) + es %*% t(es), name="E" ),
    # Algebra to compute total variances and standard deviations (diagonal only)
        mxAlgebra( expression=A+C+E, name="V" ),
        mxMatrix( type="Iden", nrow=nv, ncol=nv, name="I"),
        mxAlgebra( expression=solve(sqrt(I*V)), name="isd"),
    ## Note that the rest of the mxModel statements do not change for bivariate/multivariate case
    # Matrix & Algebra for expected means vector
        mxMatrix( type="Full", nrow=1, ncol=nv, free=TRUE, values= 80, name="M" ),
        mxAlgebra( expression= cbind(M,M), name="expMean"),
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
    mxAlgebra( expression=MZ.objective + DZ.objective, name="-2sumll" ),
    mxAlgebraObjective("-2sumll")
)

multiComPathACEFit <- mxRun(multiComPathACEModel)
multiComPathACESumm <- summary(multiComPathACEFit)

# Generate Common Pathway ACE Output
# -----------------------------------------------------------------------
parameterSpecifications(multiComPathACEFit)
tableFitStatistics(multiComPathACEFit)

ACEpathMatricesLP <- c("ACE.a","ACE.c","ACE.e")
ACEpathLabelsLP <- c("stParEst_a","stPathEst_c","stPathEst_e")
formatOutputMatrices(multiComPathACEFit,ACEpathMatricesLP,ACEpathLabelsLP,4)
formatOutputMatrices(multiComPathACEFit,ACEpathMatricesS,ACEpathLabelsS,4)
formatOutputMatrices(multiComPathACEFit,ACEcovMatrices,ACEcovLabels,4)

multiACENested <- list(multiIndPathACEFit, multiComPathACEFit)
tableFitStatistics(multiCholACEFit, multiACENested)

formatOutputMatrices(multiComPathACEFit,"ACE.sd %*% ACE.f", "stPathEst_f",4)for (i in 1:nv) {multiCholACEFit$ACE$a@values[i,i] <- 10}

