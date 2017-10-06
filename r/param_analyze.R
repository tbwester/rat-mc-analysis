require("rjson")

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

## compute global chisquare
get_chisquares <- function(ref_idx=-1) {
    # sum of parameter deviations
    if (ref_idx == -1) {
        ref_peak <- 74.1
        param_chisquares <- apply(rundata[,-(1:3)], 1, function(x) sum((x - centraldata[1,])^2/centraldata[2,]^2))
    }
    else {
        ref_peak <- peaks[ref_idx]
        param_chisquares <- apply(rundata[,-(1:3)], 1, function(x) sum((x - rundata[ref_idx,-(1:3)])^2/centraldata[2,]^2))
    }
    
    return (((peaks - ref_peak)^2 / ref_peak) + param_chisquares)
}

chisquares <- get_chisquares()
gqe <- peaks / hits
plot(chisquares~gqe)

## confidence interval
min_chsq <- min(chisquares)
min_chsq_idx <- which.min(chisquares)

chisquares <- get_chisquares(min_chsq_idx) # now we give it a reference run
gqes <- peaks / hits
plot(chisquares~gqes)

cutoff <- qchisq(0.68, df=length(unlist(jsons[[1]])) - 1) # one dummy parameter in jsons
gqes_cut <- gqes[which(chisquares < cutoff)]
ci <- c(min(gqes_cut), max(gqes_cut))
#print(length(gqes_cut))
hist(gqes_cut)
print(ci)

## ci plot vs. cutoff
lowers <- c()
uppers <- c()
for (i in 1:1000) {
    cutoff <- qchisq(i / 1000, df=length(unlist(jsons[[1]])) - 1) # one dummy parameter in jsons
    gqes_cut <- gqes[which(chisquares < cutoff)]
    lowers <- c(lowers, min(gqes_cut))
    uppers <- c(uppers, max(gqes_cut))
}

## plots
par(mai=c(1,0.9,0.2,0.2))
layout(matrix(c(2,1),ncol=1), heights=c(7,5))
ilist <- (1:1000) / 1000
plot((uppers - lowers)~ilist, col="black", type="l", ylim=c(0.0, 0.013), ylab="CI Width", xlab="Level", lty=1)
grid()
plot(lowers~ilist, type="l", col="blue", ylim=c(0.0, 0.013), ylab="CI [GQE]", xlab="", lty=1)
lines(uppers~ilist, col="red", lty=1)
grid()
legend("bottomleft", legend=c("Upper Limit", "Lower Limit"), col=c("red", "blue"), lty=c(1,1))