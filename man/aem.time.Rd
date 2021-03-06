% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/aem.time.R
\name{aem.time}
\alias{aem.time}
\title{AEM for time series}
\usage{
aem.time(n, w = NULL, moran = FALSE, plot.moran = FALSE)
}
\arguments{
\item{n}{Numeric. Number of points in the series.}

\item{w}{A vector of weights to be applied to the edges (columns of matrix
E). Equal weights are used if no vector \code{w} is provided. The length of
vector \code{w} must be (\code{n}-1) where \code{n} is the number of points
in the spatial or temporal series.}

\item{moran}{Logical. If \code{TRUE}, Moran's I are computed for all AEM. If
\code{FALSE} (default value), Moran's I are not computed.}

\item{plot.moran}{Logical.  If \code{TRUE}, a plot of the Moran's I
associated to each AEM is drawn, if \code{FALSE} (default value) no plot is
drawn. Also, if \code{moran} is \code{FALSE}, this argument becomes
invalid.}
}
\value{
\item{E}{Nodes-by-edges matrix E. } \item{values}{Eigenvalues of the
principal component analysis of E. } \item{aem}{Matrix of AEM eigenfunctions
normalized to unit length. } \item{Moran}{A three-column table giving:
\code{Moran} = Moran's I statistics, \code{p.value} = p-values (2-tailed
parametric test), \code{Positive} = 1 for Moran's I larger than the expected
value. Computed using function \code{moran.I.multi} of the AEM package. }
\item{expected_Moran}{The expected value of Moran's I. }
}
\description{
This function constructs AEM eigenfunctions for multi-scale analysis of a
regular time series or spatial transect of univariate or multivariate data.
}
\details{
Time series represent a form of directional stochastic process. To emphasize
the directional nature of the process influencing the data, AEM analysis,
which was designed to take trends into account, should be applied to the
non-detrended series. MEM analysis (see \code{scores.listw}) can be applied
to data series that were detrended to remove the directional component as
recommended by Blanchet et al. (2008, 2011) and  Legendre & Legendre (2012,
Subsection 14.1.2). Detrended palaeoecological sediment core data, for
example, could be studied by MEM analysis.

No data file needs to be provided to this function. The AEM eigenvectors are
constructed from a matrix E generated from the regular sequence of points
along the series.

A vector of weights \code{w} can be provided, representing the ease of
communication of matter, energy or information among the points. The most
simple form would be the inverse of (d/dmax) where d is the distance between
adjacent nodes and dmax is the maximum distance between adjacent nodes in the
spatial or time series. More general forms of weights may represent the
inverse of landscape resistance to the movement of organisms, propagules,
genes, etc.

If the calculation of Moran's I is requested, the point coordinates are
generated from the point positions along the series.
}
\examples{

# Time series containing 20 equispaced observations
out <- aem.time(20, moran=TRUE, plot.moran=TRUE)

# Time series containing 20 observations with unequal spacing
# Generate (n-1) random interpoint distances
distances <- runif(19,1,5)

# Compute weights representing the ease of communication among points
w <- 1/(distances/max(distances))

# Compute the AEM eigenfunctions
out <- aem.time(20, w=w, moran=TRUE, plot.moran=TRUE)

}
\references{
Blanchet F.G., P. Legendre and Borcard D. (2008) Modelling directional
spatial processes in ecological data. \emph{Ecological Modelling}, 215,
325-336.

Blanchet F.G., P. Legendre, R. Maranger, D. Monti, and P. Pepin. (2011)
Modelling the effect of directional spatial ecological processes at different
scales. \emph{Oecologia}, 166, 357-368.

Legendre, P. and L. Legendre (2012) \emph{Numerical Ecology}, 3rd English
edition. Elsevier Science BV, Amsterdam.

Legendre, P. and O. Gauthier (2014) Statistical methods for temporal and
space-time analysis of community composition data. \emph{Proceedings of the
Royal Society B - Biological Sciences}, 281, 20132728.
}
\seealso{
\code{\link{aem}}, \code{scores.listw}
}
\author{
Pierre Legendre and F. Guillaume Blanchet
}
\keyword{multivariate}
\keyword{spatial}
