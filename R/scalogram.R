#'Function to compute a scalogram
#'
#'The function decomposes the variance of a variable \code{x} on a basis of 
#'orthogonal vectors. The significance of the associated R-squared values is 
#'tested by a randomization procedure. A smoothed scalogram is obtained by 
#'summing the R-squared values into \code{nblocks}.
#'
#'On the plot, oberved R-squared values are represent by bars. A black line 
#'indicate the 0.95 quantile of the values obtained by permutations. Significant
#'values are indicated by a '*'
#'
#'@author Stéphane Dray \email{stephane.dray@@univ-lyon1.fr}
#'@aliases scalogram plot.scalogram
#'@param x a numeric vector for univariate data or an object of class \code{dudi} for 
#' multivariate data (for \code{scalogram}) or an object of class 
#'  \code{scalogram} (for \code{plot.scalogram})
#'@param orthobasisSp an object of class \code{orthobasisSp}
#'@param nblocks an integer indicating the number of blocks in the smoothed scalogram
#'@param nrepet an integer indicating the number of permutations used in the 
#'  randomization procedure
#'@param p.adjust.method a string indicating a method for multiple adjustment, 
#'  see \code{p.adjust.methods} for possible choices.
#'@param pos an integer indicating the position of the environment where the 
#'  data are stored, relative to the environment where the function is called. 
#'  Useful only if ‘storeData’ is ‘FALSE’
#'@param plot a logical indicating if the graphics is displayed
#'@param \dots additional graphical parameters (see ‘adegpar’ and 
#'  ‘trellis.par.get’)
#'  
#'@return The function \code{scalogram} returns an object of class 
#'  \code{scalogram}, subclass \code{krandtest}. The \code{plot} function 
#'  returns an object of class \code{ADEgS}, generated by the functions of the 
#'  \code{adegraphics} package
#'  
#'@seealso \code{\link{mem}} \code{\link[ade4]{orthobasis}}
#'@references
#'
#'Dray S., Pélissier R., Couteron P., Fortin M.J., Legendre P., Peres-Neto P.R.,
#'Bellier E., Bivand R., Blanchet F.G., De Caceres M., Dufour A.B., Heegaard E.,
#'Jombart T., Munoz F., Oksanen J., Thioulouse J., Wagner H.H. (2012). Community
#'ecology in the age of multivariate multiscale spatial analysis. 
#'\emph{Ecological Monographs} \bold{82}, 257--275.
#'
#'@keywords spatial
#' @examples
#' if(require("ade4", quietly = TRUE) & require("spdep", quietly = TRUE)){
#' data(mafragh)
#' me <- mem(nb2listw(mafragh$nb))
#' 
#' if(require("adegraphics", quietly = TRUE)){
#' sc1 <- scalogram(mafragh$env$Conduc, me, nblocks = 10)
#' plot(sc1) 
#' }
#' }
#'  
#'@importFrom ade4 as.krandtest scalewt
#'@importFrom adegraphics sortparamADEgS
#'@importFrom graphics plot
#'@importFrom stats weighted.mean
#'@importFrom utils modifyList
#'@export scalogram
scalogram <- function(x, orthobasisSp, nblocks = ncol(orthobasisSp), nrepet = 999, p.adjust.method = "none"){
    wt <- attr(orthobasisSp, "weights")
    if(ncol(orthobasisSp) < ncol(orthobasisSp) - 1)
        warning(paste("The orthobasis contains only", ncol(orthobasisSp), "vectors. The decomposition of variance is thus incomplete."))
    if(is.numeric(x)){
        R2 <- (t(scalewt(x, wt))%*%diag(wt)%*%as.matrix(orthobasisSp))^2  
    } else if(inherits(x, "dudi")){
        if(!isTRUE(all.equal(wt, x$lw)))
           stop("Rows weights are not equal")
        wm <- apply(x$tab, 2, weighted.mean, w = x$lw)
        if(!isTRUE(all.equal(wm, rep(0, ncol(x$tab)), check.attributes = FALSE)))
            warning("Variables in 'x' are not centred. Results may be uninterpretable")
        
        fR2 <- function(i, ortho, dudi){
            R2 <- as.matrix(ortho[,i])%*%t(as.matrix(ortho[,i]))%*%diag(dudi$lw)%*%as.matrix(dudi$tab)
            R2 <- R2 * sqrt(dudi$lw)
            R2 <- sweep(R2, 2, sqrt(dudi$cw), "*")
            R2 <- sum(R2 * R2)
            return(R2)
        }
        
        R2 <- sapply(1:ncol(orthobasisSp), fR2, dudi = x, ortho = orthobasisSp)
        
        Iner <- x$tab * sqrt(wt)
        Iner <- sweep(Iner, 2, sqrt(x$cw), "*")
        Iner <- sum(Iner * Iner)
        
        R2 <- R2 / Iner

    } else {
        stop("Invalid 'x' argument")
    }
    
    fac <- cut(1:ncol(orthobasisSp), nblocks)
    i.start <- tapply(1:ncol(orthobasisSp), fac, min)
    i.stop <- tapply(1:ncol(orthobasisSp), fac, max)
    if(nblocks < ncol(orthobasisSp)){
        levels(fac) <- paste("[", i.start, "-", i.stop, "]", sep="")
    } else {
        levels(fac) <- 1:ncol(orthobasisSp)
    }
    
    R2.smooth <- tapply(R2, fac, sum)
    sim <- matrix(0, nrepet, nblocks)
    for(i in 1:nrepet){
        if(is.numeric(x)){
            R2.sim <- as.vector((t(scalewt(sample(x), wt))%*%diag(wt)%*%as.matrix(orthobasisSp))^2)
            sim[i, ] <- tapply(R2.sim, fac, sum)
        } else {
            if(length(unique(wt)) == 1){
                ## uniform weights
                R2.sim <- sapply(1:ncol(orthobasisSp), fR2, dudi = x, ortho = orthobasisSp[sample(nrow(x$tab)),])
            } else {
                ## permute orthobasis and recompute to preserves orthogonality
                idx <- sample(nrow(x$tab))
                appel <- as.list(attr(orthobasisSp, "call"))
                appel$wt <- wt[order(idx)]
                newortho <- eval.parent(as.call(appel))[idx,]
                R2.sim <- sapply(1:ncol(orthobasisSp), fR2, dudi = x, ortho = newortho)
            }
            
            R2.sim <- R2.sim / Iner
            sim[i, ] <- tapply(R2.sim, fac, sum)
        }
    }
    res <- as.krandtest(sim, R2.smooth, names = levels(fac), call = match.call(), output = "full")
    class(res) <- c("scalogram", class(res))
    return(res)
}

#' @rdname scalogram
#' @export
plot.scalogram <- function(x, pos = -1, plot = TRUE, ...){
    
    ## sort parameters for each graph
    graphsnames <- c("obs", "sim")
    sortparameters <- sortparamADEgS(..., graphsnames = graphsnames)
    
    ## parameters management
    params <- list()
    params$obs <- list(p1d.horizontal = FALSE, plabels.cex = 2, paxes.draw = TRUE, ylab = expression(R^2), scales = list(x = list(labels = x$names)), ylim = c(0,1))
    params$sim <- list(p1d.horizontal = FALSE)
    names(params) <- graphsnames
    sortparameters <- modifyList(params, sortparameters, keep.null = TRUE)
    
    ## prepare and create plots
    g1 <- do.call("s1d.barchart", c(list(score = substitute(x$obs), labels = substitute(ifelse(x$adj.pvalue < 0.05, "*", " ")), plot = FALSE, pos = pos - 2), sortparameters$obs))
    g2 <- do.call("s1d.curve", c(list(score = substitute(apply(x$sim, 2, quantile, 0.95)), plot = FALSE, pos = pos - 2), sortparameters$sim))
    
    ## create the final ADEgS
    object <- do.call("superpose", list(g1, g2))
    object@Call <- call("superpose", g1@Call, g2@Call)
    names(object) <- graphsnames[1:length(object)]
    object@Call <- match.call()
    if(plot) 
        print(object)
    invisible(object)
    
}
