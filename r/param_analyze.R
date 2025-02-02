require("rjson")
require("HistogramTools")
require("weights")

## Reads lines from file
processFile <- function(filepath) {
    lines <- c()
    con = file(filepath, "r")
    while (TRUE) {
        line = readLines(con, n = 1)
        if (length(line) == 0) {
            break
        }
        lines <- c(lines, line)
    }
    close(con)
    return (lines)
}

## get jsons from parameter list file
json_strings <- processFile("paramlist.txt")
central_json_strings <- processFile("default_parameters.txt")

jsons <- lapply(json_strings, function(x) fromJSON(json_str=x))
central_jsons <- lapply(central_json_strings, function(x) fromJSON(json_str=x))

## get peaks and run numbers
run_strings <- processFile("peaks.txt")
temp <- unlist(lapply(run_strings, function(x) strsplit(x, "\t")))
temp <- temp[which(temp != "")] # remove empty strings???
runpeaks <- matrix(temp, ncol=3, byrow = TRUE)
runs <- unlist(lapply(runpeaks[,1], function(x) as.numeric(gsub("[^\\d]+", "", x, perl=TRUE))))
peaks <- unlist(lapply(runpeaks[,2], function(x) as.numeric(x)))
hits <-  unlist(lapply(runpeaks[,3], function(x) as.numeric(x)))

## select jsons with corresponding run number
jsons <- jsons[runs+1]

rundata <- data.frame(runs, peaks, hits)
centraldata <- df <- data.frame(matrix(nrow = 2))

## separate json into column vectors
cnames <- c("runs", "peaks", "hits")
for (i in 1:length(jsons[[1]])) {
    for (j in 1:length(unlist(jsons[[1]][i]))) {
        
        # unpack json to get the given parameter for all runs
        vals <- unlist(lapply(jsons, function(x) as.numeric(unlist(x[i])[j])))
        
        val_mean <- as.numeric(unlist(central_jsons[[1]][i])[j])
        val_sig <- as.numeric(unlist(central_jsons[[2]][i])[j])
        
        paramname <- names(unlist(jsons[[1]][i])[j])
        if (paramname == "geo.glassthick2") {
            next
        }
        else {
            centraldata <- cbind(centraldata, matrix(c(val_mean, val_sig)))
            cnames <- c(cnames, paramname)
            rundata <- cbind(rundata, vals)
        }
    }
}

## complete the data frames
colnames(rundata) <- cnames
colnames(centraldata) <- cnames[3:length(cnames)]
centraldata <- centraldata[-1]

rundata$source.sourcewidth[which(rundata$source.sourcewidth < 0)] = 0

## compute global chisquare
get_chisquares <- function(ref_peak=74.1, ref_run=-1) {
    ## param 6,22 not implemented
    skip = c(6,22)
    
    if (is.null(skip))  {
        ref_base <- centraldata[2,]
        ref_params <- centraldata[1,]
    }
    else {
        ref_base <- centraldata[2,-(skip-3)]
        ref_params <- centraldata[1,-(skip-3)]
    }
    
    if (ref_run != -1) {
        param_chisquares <- sum((rundata[ref_run, -c(1:3, skip)] - ref_params)^2/ref_base^2)
        return (((peaks[ref_run] - ref_peak)^2 / ref_peak) + param_chisquares)
    }
    else {
        param_chisquares <- apply(rundata[,-c(1:3, skip)], 1, function(x) sum((x - ref_params)^2/ref_base^2))
        return (((peaks-ref_peak)^2 / ref_peak) + param_chisquares)
    }
}

#data_peaks = rnorm(100, mean=74.1, sd=0.2*74.1)
#data_peaks = 74.1
gqes <- peaks / hits
gqe_list <- c()
prob_list <- c()
for (j in 1:1) {
    for (i in 1:length(rundata[,1])) {
        data_peak <- rnorm(1, mean = 60.82, sd = 0.01*60.82)
        chisquares <- get_chisquares(data_peak, i)
        probs = 1 #exp(-0.5*chisquares)
        gqe_list <- c(gqe_list, gqes[i])
        prob_list <- c(prob_list, probs)
    }
    print(j)
}
## ecdf
par(mar = c(5,5,2,5), pch=20)
#par(mfrow=c(1,1), pch=20)
h <- wtd.hist(x=gqe_list, weight=prob_list, breaks=40, main=NA, xlab="GQE", ylab="Weighted Counts (arb.)", freq=TRUE,
              cex.lab=1.5, cex.axis=1.5, cex.sub=1.5)
ec <- HistToEcdf(h)

ecx <- knots(ec)
ecy <- ec(knots(ec))

fit <- smooth.spline(ecx, y = ecy, spar=0.5)

par(new = T)
plot(fit, xlab=NA, ylab=NA, axes=F, col="Red", type="l", lwd=1)
points(ecy~ecx, col="Red")

#lines(fit, axes=F, col="Red")

axis(4, at=seq(from = 0, to = 1, length.out = 6), labels=seq(0, 1, 0.2), col = 'red', col.axis = 'red', cex.axis=1.5, cex.main=1.5)
mtext(side = 4, line = 3, 'Cumulative Density', col = 'red', cex=1.5)

pred <- predict(fit)
draw_ci <- function(sign, dashed=FALSE, col="Red") {
    ci_lower <- approxfun(x=pred$y, y=pred$x)((1-sign)/2) 
    ci_upper <- approxfun(x=pred$y, y=pred$x)(1-(1-sign)/2) 
    med <- approxfun(x=pred$y, y=pred$x)(0.5)
    print(med)
    ci_bayes <- c(ci_lower, ci_upper)
    signs <- c((1-sign)/2, 1-(1-sign)/2)
    print(ci_bayes)
    print( c( abs(med-ci_bayes[1])/med, abs(med-ci_bayes[2])/med ) )
    #points(signs~ci_bayes, col=col)
    if (dashed) {
        abline(v=ci_bayes[1], col=col, lty=2, lwd=2)
        abline(v=ci_bayes[2], col=col, lty=2, lwd=2)        
    }
    else {
        abline(v=ci_bayes[1], col=col, lwd=2)
        abline(v=ci_bayes[2], col=col, lwd=2)
    }

}
draw_ci(0.68, TRUE, "Blue")
#draw_ci(0.95, TRUE)
#draw_ci(0.99, TRUE, "Blue")

legend(x=0.008, y=0.6,legend=c("Percentiles", "CDF", "68% C.I."),
       col=c("Red","Red", "Blue"), lty=c(-1,1,2), pch=c(20, NA, NA), cex=1.2, lwd=c(1,2,2), bty="n")

