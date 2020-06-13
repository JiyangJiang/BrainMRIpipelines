# Function "parameterSpecifations()" prints labels of a MxMatrix with
# square brackets surrounding free parameters; returns a matrix of strings
# downloaded from http://vipbg.vcu.edu/vipbg/Tc24//GenEpiHelperFunctions.R
# -----------------------------------------------------------------------
parameterSpecifications <- function(model) {
	resultsList <- .collectParameterSpecifications(model)
	if(length(resultsList) > 0) {
		resultsNames <- names(resultsList)
		for(i in 1:length(resultsList)) {
			cat(resultsNames[[i]],'\n')
			print(resultsList[[i]], quote=FALSE)
			cat('\n')
		}
	}
}

.collectParameterSpecifications <- function(model) {
	listReturn <- list()
	if(length(model@matrices) > 0) {
		for(i in 1:length(model@matrices)) {
			current <- model@matrices[[i]]
			extract <- is(current, "FullMatrix") ||
				is(current, "LowerMatrix") ||
				is(current, "DiagMatrix") ||
				is(current, "SymmMatrix") ||
				is(current, "StandMatrix")
			if(extract) {
				retval <- mapply(.parameterSpecificationsHelper, 
					current@labels, current@free, current@values)
				retval <- matrix(retval, nrow(current), ncol(current))
				dimnames(retval) <- dimnames(current)
				storeName <- paste('model:', model@name,', matrix:', current@name, sep='')
				listReturn[[storeName]] <- retval
			}
		}
	}
	names(model@submodels) <- NULL
	matrices <- lapply(model@submodels, .collectParameterSpecifications)
	listReturn <- append(listReturn, unlist(matrices, FALSE))
	return(listReturn)
}

.parameterSpecificationsHelper <- function(label, free, value) {
	if(free) return(paste('[', label, ']', sep = ''))
	else return(value)
}


# Function "expectedMeansCovariances()" prints expected means and 
# expected covariance matrices for all submodels
# -----------------------------------------------------------------------
expectedMeansCovariances <- function(model) {
   resultsList <- .collectExpectedMeansCovariances(model, model)
   if(length(resultsList) > 0) {
      resultsNames <- names(resultsList)
      for(i in 1:length(resultsList)) {
         cat(resultsNames[[i]],'\n')
         print(resultsList[[i]])
         cat('\n')
      }
   }
}

.collectExpectedMeansCovariances <- function(model, topModel) {
   listReturn <- list()
   if(!is.null(model$objective)) {
      objective <- model$objective
      slots <- slotNames(objective)

      # extract the covariance
      if('covariance' %in% slots) {
         covName <- objective@covariance
         if(length(grep('.', covName, fixed=TRUE)) == 1) {
            covariance <- eval(substitute(mxEval(x, topModel), list(x = as.symbol(covName))))
         } else {
            covariance <- eval(substitute(mxEval(x, model), list(x = as.symbol(covName))))
         }
         storeName <- paste('model:', model@name,', covariance:', covName, sep='')
         listReturn[[storeName]] <- covariance
      }

      # extract the means
      if('means' %in% slots) {
         meansName <- objective@means
         if(length(grep('.', meansName, fixed=TRUE)) == 1) {
            means <- eval(substitute(mxEval(x, topModel), list(x = as.symbol(meansName))))
         } else {
            means <- eval(substitute(mxEval(x, model), list(x = as.symbol(meansName))))
         }
         storeName <- paste('model:', model@name,', means:', meansName, sep='')
         listReturn[[storeName]] <- means
      }      

      # extract the thresholds
      if('thresholds' %in% slots) {
         thresholdsName <- objective@thresholds
         if(length(thresholdsName) == 1 && is.na(thresholdsName)) {
         } else {
	         if(length(grep('.', thresholdsName, fixed=TRUE)) == 1) {
   		         thresholds <- eval(substitute(mxEval(x, topModel), list(x = as.symbol(thresholdsName))))
   		      } else {
        	    thresholds <- eval(substitute(mxEval(x, model), list(x = as.symbol(thresholdsName))))
         		}
	        	storeName <- paste('model:', model@name,', thresholds:', thresholdsName, sep='')
         		listReturn[[storeName]] <- thresholds
         }
      }      
   }

   # Recursively collect means and covariances of submodels
   names(model@submodels) <- NULL
   submodels <- lapply(model@submodels, .collectExpectedMeansCovariances, topModel)
   listReturn <- append(listReturn, unlist(submodels, FALSE))
   return(listReturn)
}


# Function "formatOutputMatrices()" prints matrix with specified labels and
# number of decimals
# -----------------------------------------------------------------------
#parse(text=matricesList[k]) == matricesList[[k]]
formatOutputMatrices <- function(fittedModel,matricesList,labelsList,vars,digits) {
	if(length(matricesList) > 0) {
	for(k in 1:length(matricesList)) {
		print(paste("Matrix",matricesList[[k]]))
		print(formatOutputMatrix(
			evalQuote(matricesList[[k]], fittedModel),
			labelsList[[k]],vars,digits), quote=FALSE)
			cat('\n')
		}
	}
}

formatOutputMatrix <- function(matrix,label,vars,digits) {
	#table <- round(eval(substitute(mxEval(Matrix,Model))),ND)
	matrix <- apply(matrix, c(1,2), round, digits = digits)
	retval <- apply(matrix, c(1,2), format, scientific=FALSE, nsmall = digits)

	cols <- character(ncol(retval))
	for(i in 1:ncol(retval)) {paste(label,i,sep="")} -> cols[i]
	colnames(retval) <- cols
	if (nrow(retval) == length(vars)) {
	rownames(retval) <- vars
	} else {
	rows <- character(nrow(retval))
	for(j in 1:nrow(retval)) {paste("LP",j,sep="")} -> rows[j]
	rownames(retval) <- rows
	}
	return(retval)
}


# Function "formatMatrix()" returns a matrix with specified dimnames and # of decimal places
# -----------------------------------------------------------------------
formatMatrix <- function(matrix, dimnames, digits) {
	retval <- apply(matrix, c(1,2), round, digits)
	dimnames(retval) <- dimnames
	return(retval)
}

evalQuote <- function(expstring, model, compute = FALSE, show = FALSE) {
	return(eval(substitute(mxEval(x, model, compute, show),
			list(x = parse(text=expstring)[[1]]))))
}


#print(formatMatrix(value, dimnames = list(Vars, c()), digits = 4))

#nmat <- c("X","Y","Z","solve(sqrt(I*V))")
#nlab <- c("peX","peY","peZ","SD")
#for(j in 1:length(nmat)) {
#	print(paste("Matrix",nmat[j]))
#	print(formatMatrix(
#		evalQuote(nmat[[j]], cholACEFit), 
#		dimnames = list(Vars, c()), digits = 4))}


# Function "tableFitStatistics()" prints fit statistics with labels
# for Full Model and list of Nested Models
# -----------------------------------------------------------------------
tableFitStatistics <- function(reference, compare) {
	resultsTable <- .showFitStatistics(reference, compare)
	rows <- 1
	for(i in 1:nrow(resultsTable)) {paste("Model",i,":")} -> rows[i]
	rownames(resultsTable) <- rows
	print(resultsTable, quote=FALSE)
	cat('\n')
}

.showFitStatistics <- function(reference, compare) {
	refSummary <- summary(reference)
	if (missing(compare)) {
		return(.collectFitStatistics(refSummary, reference@name))	
	} else if (!is.list(compare)) {
		return(.collectFitStatistics(refSummary, reference@name, compare))
	} else if (is.list(compare)) {
		if (length(compare) == 0) {
			return(.collectFitStatistics(refSummary, reference@name))	
		} else {
			stats <- lapply(compare, function(x) {
				.collectFitStatistics(refSummary, reference@name, x) })
			results <- matrix("", length(stats) + 1, ncol(stats[[1]]))
			dimnames(results) <- list(c(), dimnames(stats[[1]])[[2]])
			results[1,] <- stats[[1]][1,]
			results[2,] <- stats[[1]][2,]
			if (length(compare) > 1) {
				for(i in 2:length(stats)) {
					results[i + 1, ] <- stats[[i]][2,]
				}
			}
			return(results)
		}
	}
}

.collectFitStatistics <- function(refSummary, refName, compare) {
	if (missing(compare)) {
		stats <- as.matrix(cbind(
			refName,
			refSummary$estimatedParameters,
			round(refSummary$Minus2LogLikelihood,2),
			refSummary$degreesOfFreedom,
			round(refSummary$AIC.Mx,2)))
		colnames(stats) <- c("Name","ep","-2LL", "df", "AIC")
		return(stats)
	} else {
		fullStats <- as.matrix(cbind(
			refName, 
			refSummary$estimatedParameters,
			round(refSummary$Minus2LogLikelihood,2),
			refSummary$degreesOfFreedom,
			round(refSummary$AIC.Mx,2),
			"-","-","-"))
		compareSummary <- summary(compare)
		nestedStats <- as.matrix(cbind(
			compare@name, 
			compareSummary$estimatedParameters,
			round(compareSummary$Minus2LogLikelihood, 2),
			compareSummary$degreesOfFreedom,
			round(compareSummary$AIC.Mx, 2),
			round(compareSummary$Minus2LogLikelihood - refSummary$Minus2LogLikelihood, 2),
			compareSummary$degreesOfFreedom - refSummary$degreesOfFreedom, 
			round(pchisq(compareSummary$Minus2LogLikelihood - refSummary$Minus2LogLikelihood,
				compareSummary$degreesOfFreedom - refSummary$degreesOfFreedom,lower.tail=F),2)))
		stats <- rbind(fullStats,nestedStats)
		colnames(stats) <- c("Name","ep","-2LL", "df", "AIC","diffLL","diffdf","p")
		return(stats)
	}
}



# Lists of Matrices/Algebras to print with associated labels
# -----------------------------------------------------------------------
ACEpathMatrices <- c("ACE.a","ACE.c","ACE.e","ACE.iSD","ACE.iSD %*% ACE.a","ACE.iSD %*% ACE.c","ACE.iSD %*% ACE.e")
ACEpathLabels <- c("pathEst_a","pathEst_c","pathEst_e","iSD","stPathEst_a","stPathEst_c","stPathEst_e")

ACEcovMatrices <- c("ACE.A","ACE.C","ACE.E","ACE.V","ACE.A/ACE.V","ACE.C/ACE.V","ACE.E/ACE.V")
ACEcovLabels <- c("covComp_A","covComp_C","covComp_E","Var","stCovComp_A","stCovComp_C","stCovComp_E")

ACEpathMatricesC <- c("ACE.ac","ACE.cc","ACE.ec","ACE.iSD","ACE.iSD %*% ACE.ac","ACE.iSD %*% ACE.cc","ACE.iSD %*% ACE.ec")
ACEpathLabelsC <- c("pathEst_ac","pathEst_cc","pathEst_ec","iSD","stPathEst_ac","stPathEst_cc","stPathEst_ec")
ACEpathMatricesS <- c("ACE.as","ACE.cs","ACE.es","ACE.iSD","ACE.iSD %*% ACE.as","ACE.iSD %*% ACE.cs","ACE.iSD %*% ACE.es")
ACEpathLabelsS <- c("pathEst_as","pathEst_cs","pathEst_es","iSD","stPathEst_as","stPathEst_cs","stPathEst_es")

ACEpathMatricesLP <- c("ACE.a","ACE.c","ACE.e","ACE.f","ACE.iSD","ACE.iSD %*% ACE.f")
ACEpathLabelsLP <- c("stPathEst_a","stPathEst_c","stPathEst_e","PathEst_f","iSD","stPathEst_f")

ACEpathMatricesM <- c("ACE.am","ACE.cm","ACE.em","ACE.iSDm","ACE.iSDm %*% ACE.am","ACE.iSDm %*% ACE.cm","ACE.iSDm %*% ACE.em")
ACEpathLabelsM <- c("pathEst_am","pathEst_cm","pathEst_em","iSDm","stPathEst_am","stPathEst_cm","stPathEst_em")
ACEpathMatricesF <- c("ACE.af","ACE.cf","ACE.ef","ACE.iSDf","ACE.iSDf %*% ACE.af","ACE.iSDf %*% ACE.cf","ACE.iSDf %*% ACE.ef")
ACEpathLabelsF <- c("pathEst_af","pathEst_cf","pathEst_ef","iSDf","stPathEst_af","stPathEst_cf","stPathEst_ef")

ACEcovMatricesM <- c("ACE.Am","ACE.Cm","ACE.Em","ACE.Vm","ACE.Am/ACE.Vm","ACE.Cm/ACE.Vm","ACE.Em/ACE.Vm")
ACEcovLabelsM <- c("covComp_Am","covComp_Cm","covComp_Em","Varm","stCovComp_Am","stCovComp_Cm","stCovComp_Em")
ACEcovMatricesF <- c("ACE.Af","ACE.Cf","ACE.Ef","ACE.Vf","ACE.Af/ACE.Vf","ACE.Cf/ACE.Vf","ACE.Ef/ACE.Vf")
ACEcovLabelsF <- c("covComp_Af","covComp_Cf","covComp_Ef","Varf","stCovComp_Af","stCovComp_Cf","stCovComp_Ef")

ACEpathMatricesI <- c("ACE.aI","ACE.cI","ACE.eI")
ACEpathLabelsI <- c("pathEst_aI","pathEst_cI","pathEst_eI")
ACEpathMatricesT <- c("ACE.at","ACE.ct","ACE.et","ACE.iSD","ACE.iSD %*% ACE.at","ACE.iSD %*% ACE.ct","ACE.iSD %*% ACE.et")
ACEpathLabelsT <- c("pathEst_at","pathEst_ct","pathEst_et","sd","stPathEst_at","stPathEst_ct","stPathEst_et")
ACEpathMatricesI <- c("ACE.ai","ACE.ci","ACE.ei","ACE.iSD","ACE.iSD %*% ACE.ai","ACE.iSD %*% ACE.ci","ACE.iSD %*% ACE.ei")
ACEpathLabelsI <- c("pathEst_ai","pathEst_ci","pathEst_ei","sd","stPathEst_ai","stPathEst_ci","stPathEst_ei")


