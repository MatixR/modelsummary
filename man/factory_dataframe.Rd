% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/factory_dataframe.R
\name{factory_dataframe}
\alias{factory_dataframe}
\title{Internal function to build table with `data.frame` with other arguments as
attributes. Useful for testing.}
\usage{
factory_dataframe(
  tab,
  align = NULL,
  hrule = NULL,
  notes = NULL,
  output_file = NULL,
  output_format = NULL,
  add_rows = NULL,
  title = NULL,
  ...
)
}
\arguments{
\item{tab}{table body (data.frame)}

\item{align}{A character string of length equal to the number of columns in
the table.  "lcr" means that the first column will be left-aligned, the 2nd
column center-aligned, and the 3rd column right-aligned.}

\item{hrule}{position of horizontal rules (integer vector)}

\item{notes}{list or vector of notes to append to the bottom of the table.}

\item{output_file}{file path (character or NULL)}

\item{output_format}{character}

\item{title}{string}

\item{...}{all other arguments are passed to the `tidy` and `glance` methods
used to extract estimates from the model. For example, this allows users to
set `exponentiate=TRUE` to exponentiate logistic regression coefficients.}
}
\value{
data.frame
}
\description{
Internal function to build table with `data.frame` with other arguments as
attributes. Useful for testing.
}
\keyword{internal}
