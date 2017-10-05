require("rjson")

## Reads lines from file
processFile <- function(filepath) {
    lines <- c()
    con = file(filepath, "r")
    while ( TRUE ) {
        line = readLines(con, n = 1)
        if ( length(line) == 0 ) {
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
temp <- unlist(lapply(run_strings, function(x) strsplit(x, " ")))
temp <- temp[which(temp != "")] # remove empty strings???
runpeaks <- matrix(temp, ncol=3, byrow = TRUE)
runs <- unlist(lapply(runpeaks[,1], function(x) as.numeric(gsub("[^\\d]+", "", x, perl=TRUE))))
peaks <- unlist(lapply(runpeaks[,2], function(x) as.numeric(x)))
hits <-  unlist(lapply(runpeaks[,3], function(x) as.numeric(x)))

## select jsons with corresponding run number
jsons <- jsons[(runs[1]+1):(runs[length(runs)]+1)]

## get a parameter from the json, plot peak position vs parameter to look for trends
sums <- numeric(length(jsons))
for (i in 1:length(jsons[[1]])) {
    for (j in 1:length(unlist(jsons[[1]][i]))) {
        vals <- unlist(lapply(jsons, function(x) as.numeric(unlist(x[i])[j])))
        val_mean <- as.numeric(unlist(central_jsons[[1]][i])[j])
        val_sig <- as.numeric(unlist(central_jsons[[2]][i])[j])
        
        tempval <- vals[1]
        if (is.na(val_sig)) {
            vals <- numeric(length(jsons))
        }
        else {
            vals <- unlist(lapply(vals, function(x) (x-val_mean)^2 / val_sig^2 ))
        }
        print(c(tempval, val_mean, val_sig, vals[1]))
        
        sums <- sums + vals
        #print(fit$coefficients[2])
    }
}
print(sums)
chisquares <- ((peaks - 74.1)^2 / 74.1) + sums
gqe <- peaks / hits
plot(chisquares~gqe)

# confidence interval
min_chsq <- min(chisquares)
min_chsq_idx <- which.min(chisquares)

sums <- numeric(length(jsons))
for (i in 1:length(jsons[[1]])) {
    for (j in 1:length(unlist(jsons[[1]][i]))) {
        vals <- unlist(lapply(jsons, function(x) as.numeric(unlist(x[i])[j])))
        val_mean <- as.numeric(unlist(jsons[[min_chsq_idx]][i])[j])
        val_sig <- as.numeric(unlist(central_jsons[[2]][i])[j])
        
        tempval <- vals[234]
        if (is.na(val_sig)) {
            vals <- numeric(length(jsons))
        }
        else {
            vals <- unlist(lapply(vals, function(x) (x-val_mean)^2 / val_sig^2 ))
        }
        print(c(tempval, val_mean, val_sig, vals[234]))
        
        sums <- sums + vals
        #print(fit$coefficients[2])
    }
}

chisquares <- ((peaks - peaks[min_chsq_idx])^2 / peaks[min_chsq_idx]) + sums
gqes <- peaks / hits
plot(chisquares~gqes)

cutoff <- qchisq(0.95, df=length(unlist(jsons[[1]])) - 1) # one dummy parameter in jsons
gqes_cut <- gqes[which(chisquares < cutoff)]
ci <- c(min(gqes_cut), max(gqes_cut))
print(length(gqes_cut))
hist(gqes_cut)
print(ci)

lowers <- c()
uppers <- c()
for (i in 1:1000) {
    cutoff <- qchisq(i / 1000, df=length(unlist(jsons[[1]])) - 1) # one dummy parameter in jsons
    gqes_cut <- gqes[which(chisquares < cutoff)]
    lowers <- c(lowers, min(gqes_cut))
    uppers <- c(uppers, max(gqes_cut))
}
ilist <- (1:1000) / 1000
plot(lowers~ilist, type="l", col="blue", ylim=c(0.003, 0.013), ylab="CI", xlab="Level")
lines(uppers~ilist, col="red")