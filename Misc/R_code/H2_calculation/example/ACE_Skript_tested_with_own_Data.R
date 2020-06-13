
############################### ACE Model #######################
### Data import
Data<-read.delim("Test Data ACE Model.csv", header = TRUE, sep = ";")

# zyg as factor
Data$zyg<- factor(Data$zyg, levels= c(1:2),labels= c("MZ", "DZ"))


### loading packages
require(OpenMx)
require(psych)

# Load Data 
describe(Data, skew=F)

# Prepare Data
Vars      <- 'duration'                   # choosing variable
nv        <- 1                            # nv = number of variables
ntv       <- nv*2                         # number of total variables (number types of twins(2) * number of variables
selVars   <- c("duration1", "duration2")# selecting variables according to colume name
selVars


# Select Data for Analysis
mzData    <- subset(Data, zyg=="MZ", selVars)
dzData    <- subset(Data, zyg=="DZ", selVars)

# Generate Descriptive Statistics
colMeans(mzData)
colMeans(dzData,na.rm=TRUE)
cov(mzData,use="complete")
cov(dzData,use="complete")


# Set Starting Values
svMe      <- 20      # start value for means
svPa      <- .6      # start value for path coefficients (sqrt(variance/#ofpaths))

# ACE Model
# Matrices declared to store a, c, and e Path Coefficients
pathA     <- mxMatrix( type="Full", nrow=nv, ncol=nv,
                       free=TRUE, values=svPa, label="a11", name="a" ) # matrix names with 11 referring to the first row and column of the matrix
pathC     <- mxMatrix( type="Full", nrow=nv, ncol=nv,
                       free=TRUE, values=svPa, label="c11", name="c" )
pathE     <- mxMatrix( type="Full", nrow=nv, ncol=nv,
                       free=TRUE, values=svPa, label="e11", name="e" )

# Matrices generated to hold A, C, and E computed Variance Components
covA      <- mxAlgebra( expression=a %*% t(a), name="A" )
covC      <- mxAlgebra( expression=c %*% t(c), name="C" )
covE      <- mxAlgebra( expression=e %*% t(e), name="E" )

# Algebra to compute total variances
covP      <- mxAlgebra( expression=A+C+E, name="V" )

# Algebra for expected Mean and Variance/Covariance Matrices in MZ & DZ twins
meanG     <- mxMatrix( type="Full", nrow=1, ncol=ntv,
                       free=TRUE, values=svMe, label="mean", name="expMean" )

# Algebra for expected and Variance/Covariance Matrices in MZ & DZ twins
covMZ     <- mxAlgebra( expression=rbind( cbind(V, A+C),
                                          cbind(A+C, V)), name="expCovMZ" )
covDZ     <- mxAlgebra( expression=rbind( cbind(V, 0.5%x%A+ C),
                                          cbind(0.5%x%A+C , V)), name="expCovDZ" )

# Data objects for Multiple Groups
dataMZ    <- mxData( observed=mzData, type="raw" )
dataDZ    <- mxData( observed=dzData, type="raw" )

# Objective objects for Multiple Groups
expMZ     <- mxExpectationNormal( covariance="expCovMZ", means="expMean",
                                  dimnames=selVars )
expDZ     <- mxExpectationNormal( covariance="expCovDZ", means="expMean",
                                  dimnames=selVars )
funML     <- mxFitFunctionML()

# Combine Groups
pars      <- list( pathA, pathC, pathE, covA, covC, covE, covP )
modelMZ   <- mxModel( pars, meanG, covMZ, dataMZ, expMZ, funML, name="MZ" )
modelDZ   <- mxModel( pars, meanG, covDZ, dataDZ, expDZ, funML, name="DZ" )
fitML     <- mxFitFunctionMultigroup(c("MZ.fitfunction","DZ.fitfunction") )
AceModel  <- mxModel( "ACE", pars, modelMZ, modelDZ, fitML )

# Run ACE model
AceFit    <- mxRun(AceModel, intervals=T)
AceSumm   <- summary(AceFit)
AceSumm

# Generate ACE Model Output
estMean   <- mxEval(expMean, AceFit$MZ)       # expected mean
estCovMZ  <- mxEval(expCovMZ, AceFit$MZ)      # expected covariance matrix for MZ's
estCovDZ  <- mxEval(expCovDZ, AceFit$DZ)      # expected covariance matrix for DZ's
estVA     <- mxEval(a*a, AceFit)              # additive genetic variance, a^2
estVC     <- mxEval(c*c, AceFit)              # dominance variance, c^2
estVE     <- mxEval(e*e, AceFit)              # unique environmental variance, e^2
estVP     <- (estVA+estVC+estVE)              # total variance
estPropVA <- estVA/estVP                      # standardized additive genetic variance
estPropVC <- estVC/estVP                      # standardized dominance variance
estPropVE <- estVE/estVP                      # standardized unique environmental variance
estACE    <- rbind(cbind(estVA,estVC,estVE),  # table of estimates
                   cbind(estPropVA,estPropVC,estPropVE))
LL_ACE    <- mxEval(objective, AceFit)        # likelihood of ACE model

##################### Alternative Models an AE Model

# Run AE model
AeModel   <- mxModel( AceFit, name="AE" )
AeModel   <- omxSetParameters( AeModel, labels="c11", free=FALSE, values=0 )
AeFit     <- mxRun(AeModel)
AeSumm   <- summary(AeFit)
AeSumm

# Generate AE Model Output
estVA     <- mxEval(a*a, AeFit)               # additive genetic variance, a^2
estVE     <- mxEval(e*e, AeFit)               # unique environmental variance, e^2
estVP     <- (estVA+estVE)                    # total variance
estPropVA <- estVA/estVP                      # standardized additive genetic variance
estPropVE <- estVE/estVP                      # standardized unique environmental variance
estAE     <- rbind(cbind(estVA,estVE),        # table of estimates
                   cbind(estPropVA,estPropVE))
LL_AE     <- mxEval(objective, AeFit)         # likelihood of AE model

###################### Alternative Models an CE Model
# Run CE model 
CeModel <- mxModel(AceFit, name="CE")
CeModel <- omxSetParameters(CeModel, labels="a11", free=FALSE, values = 0)
CeFit <- mxRun(CeModel)
CeSumm   <- summary(AeFit)
CeSumm

# Generate AE Model Output
estVC     <- mxEval(c*c, CeFit)               # additive  variance, c^2
estVE     <- mxEval(e*e, CeFit)               # unique environmental variance, e^2
estVP     <- (estVC+estVE)                    # total variance
estPropVC <- estVC/estVP                      # standardized additive variance
estPropVE <- estVE/estVP                      # standardized unique environmental variance
estAE     <- rbind(cbind(estVC,estVE),        # table of estimates
                   cbind(estPropVC,estPropVE))
LL_AE     <- mxEval(objective, CeFit)         # likelihood of AE model  


