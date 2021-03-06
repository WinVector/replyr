% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/uniqueValues.R
\name{replyr_uniqueValues}
\alias{replyr_uniqueValues}
\title{Compute number of unique values for each level in a column.}
\usage{
replyr_uniqueValues(x, cname)
}
\arguments{
\item{x}{tbl or item that can be coerced into such.}

\item{cname}{name of columns to examine, must not be equal to 'replyr_private_value_n'.}
}
\value{
unique values for the column.
}
\description{
Compute number of unique values for each level in a column.
}
\examples{

d <- data.frame(x=c(1,2,3,3))
replyr_uniqueValues(d,'x')

}
