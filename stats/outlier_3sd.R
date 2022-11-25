# example from Anbu

for (k in 1:length(mris))
{
	mri_outlier = as.numeric (scale (alldat [,mris[k]]))
	al = which (mri_outlier <= -3)
	ar = which (mri_outlier >= 3)
	outlier = c(al,ar)
	alldat = alldat [-outlier,]
}