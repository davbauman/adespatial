% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/scores.listw.R
\name{scores.listw}
\alias{scores.listw}
\alias{mem}
\alias{orthobasis.listw}
\alias{[.orthobasisSp}
\alias{mem}
\alias{orthobasis.listw}
\alias{[.orthobasisSp}
\title{Function to compute and manage Moran's Eigenvector Maps (MEM) of a listw
object}
\usage{
scores.listw(listw, wt = rep(1, length(listw$neighbours)),
  MEM.autocor = c("non-null", "all", "positive", "negative"),
  store.listw = FALSE)

mem(listw, wt = rep(1, length(listw$neighbours)),
  MEM.autocor = c("non-null", "all", "positive", "negative"),
  store.listw = FALSE)

orthobasis.listw(listw, wt = rep(1, length(listw$neighbours)),
  MEM.autocor = c("non-null", "all", "positive", "negative"),
  store.listw = FALSE)

\method{[}{orthobasisSp}(x, i, j, drop = TRUE)
}
\arguments{
\item{listw}{An object of the class \code{listw} created by functions of the
\code{spdep} package}

\item{wt}{A vector of weights. It is used to orthogonalize the eigenvectors.
It could be useful if MEM are used in weighted regression or canonical
correspondence analysis}

\item{MEM.autocor}{A string indicating if all MEMs must be returned or only
those corresponding to non-null, positive or negative autocorrelation. The
difference between options \code{all} and \code{non-null} is the following:
when there are several null eigenvalues, option \code{all} removes only one
of the eigenvectors with null eigenvalues and returns (n-1) eigenvectors,
whereas \code{non-null} does not return any of the eigenvectors with null
eigenvalues.}

\item{store.listw}{A logical indicating if the spatial weighting matrix
should be stored in the attribute \code{listw} of the returned object}

\item{x}{An object of class \code{orthobasisSp}.}

\item{i, j}{Elements to extract (integer or empty): index of rows (i) and
columns (j).}

\item{drop}{A logical. If TRUE, object containing only one colum is converted in 
vector}
}
\value{
An object of class \code{orthobasisSp} , subclass \code{orthobasis}. 
  The MEMs are stored as a \code{data.frame}. It contains several attributes 
  (see \code{?attributes}) including: \itemize{\item \code{values}: The 
  associated eigenvalues. \item \code{listw}: The associated spatial 
  weighting matrix (if \code{store.listw = TRUE}). }
}
\description{
These functions compute MEM (i.e., eigenvectors of a doubly centered spatial
weighting matrix). Corresponding eigenvalues are linearly related to Moran's
index of spatial autocorrelation.
}
\details{
Testing the nullity of eigenvalues is based on E(i)/E(1) where E(i) is i-th
eigenvalue and E(1) is the maximum absolute value of eigenvalues
}
\examples{

if(require("ade4", quietly = TRUE) & require("spdep", quietly = TRUE)){
data(oribatid)
nbtri <- tri2nb(as.matrix(oribatid$xy))
sc.tri <- scores.listw(nb2listw(nbtri, style = "B"))
summary(sc.tri)
}
if(require("adegraphics", quietly = TRUE)){
s.value(oribatid$xy,sc.tri[,1:9])
plot(sc.tri[,1:6], oribatid$xy, pSp.cex = 5, pSp.alpha = 0.5, pbackground.col = 'lightblue')
}

}
\references{
Dray, S., Legendre, P., and Peres-Neto, P. R. (2006). Spatial
  modeling: a comprehensive framework for principal coordinate analysis of
  neighbor matrices (PCNM). \emph{Ecological Modelling} \bold{196}, 483--493.

  Griffith D. A. (1996) Spatial autocorrelation and eigenfunctions of the
  geographic weights matrix accompanying geo-referenced data. \emph{Canadian
  Geographer} \bold{40}, 351--367.
}
\seealso{
\code{\link[spdep]{nb2listw}} \code{\link[ade4]{orthobasis}}
}
\author{
Stéphane Dray \email{stephane.dray@univ-lyon1.fr}
}
\keyword{spatial}
