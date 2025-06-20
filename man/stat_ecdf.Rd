% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/stat-ecdf.R
\name{stat_ecdf}
\alias{stat_ecdf}
\title{Compute empirical cumulative distribution}
\usage{
stat_ecdf(
  mapping = NULL,
  data = NULL,
  geom = "step",
  position = "identity",
  ...,
  n = NULL,
  pad = TRUE,
  na.rm = FALSE,
  show.legend = NA,
  inherit.aes = TRUE
)
}
\arguments{
\item{mapping}{Set of aesthetic mappings created by \code{\link[=aes]{aes()}}. If specified and
\code{inherit.aes = TRUE} (the default), it is combined with the default mapping
at the top level of the plot. You must supply \code{mapping} if there is no plot
mapping.}

\item{data}{The data to be displayed in this layer. There are three
options:

If \code{NULL}, the default, the data is inherited from the plot
data as specified in the call to \code{\link[=ggplot]{ggplot()}}.

A \code{data.frame}, or other object, will override the plot
data. All objects will be fortified to produce a data frame. See
\code{\link[=fortify]{fortify()}} for which variables will be created.

A \code{function} will be called with a single argument,
the plot data. The return value must be a \code{data.frame}, and
will be used as the layer data. A \code{function} can be created
from a \code{formula} (e.g. \code{~ head(.x, 10)}).}

\item{geom}{The geometric object to use to display the data for this layer.
When using a \verb{stat_*()} function to construct a layer, the \code{geom} argument
can be used to override the default coupling between stats and geoms. The
\code{geom} argument accepts the following:
\itemize{
\item A \code{Geom} ggproto subclass, for example \code{GeomPoint}.
\item A string naming the geom. To give the geom as a string, strip the
function name of the \code{geom_} prefix. For example, to use \code{geom_point()},
give the geom as \code{"point"}.
\item For more information and other ways to specify the geom, see the
\link[=layer_geoms]{layer geom} documentation.
}}

\item{position}{A position adjustment to use on the data for this layer. This
can be used in various ways, including to prevent overplotting and
improving the display. The \code{position} argument accepts the following:
\itemize{
\item The result of calling a position function, such as \code{position_jitter()}.
This method allows for passing extra arguments to the position.
\item A string naming the position adjustment. To give the position as a
string, strip the function name of the \code{position_} prefix. For example,
to use \code{position_jitter()}, give the position as \code{"jitter"}.
\item For more information and other ways to specify the position, see the
\link[=layer_positions]{layer position} documentation.
}}

\item{...}{Other arguments passed on to \code{\link[=layer]{layer()}}'s \code{params} argument. These
arguments broadly fall into one of 4 categories below. Notably, further
arguments to the \code{position} argument, or aesthetics that are required
can \emph{not} be passed through \code{...}. Unknown arguments that are not part
of the 4 categories below are ignored.
\itemize{
\item Static aesthetics that are not mapped to a scale, but are at a fixed
value and apply to the layer as a whole. For example, \code{colour = "red"}
or \code{linewidth = 3}. The geom's documentation has an \strong{Aesthetics}
section that lists the available options. The 'required' aesthetics
cannot be passed on to the \code{params}. Please note that while passing
unmapped aesthetics as vectors is technically possible, the order and
required length is not guaranteed to be parallel to the input data.
\item When constructing a layer using
a \verb{stat_*()} function, the \code{...} argument can be used to pass on
parameters to the \code{geom} part of the layer. An example of this is
\code{stat_density(geom = "area", outline.type = "both")}. The geom's
documentation lists which parameters it can accept.
\item Inversely, when constructing a layer using a
\verb{geom_*()} function, the \code{...} argument can be used to pass on parameters
to the \code{stat} part of the layer. An example of this is
\code{geom_area(stat = "density", adjust = 0.5)}. The stat's documentation
lists which parameters it can accept.
\item The \code{key_glyph} argument of \code{\link[=layer]{layer()}} may also be passed on through
\code{...}. This can be one of the functions described as
\link[=draw_key]{key glyphs}, to change the display of the layer in the legend.
}}

\item{n}{if NULL, do not interpolate. If not NULL, this is the number
of points to interpolate with.}

\item{pad}{If \code{TRUE}, pad the ecdf with additional points (-Inf, 0)
and (Inf, 1)}

\item{na.rm}{If \code{FALSE} (the default), removes missing values with
a warning.  If \code{TRUE} silently removes missing values.}

\item{show.legend}{logical. Should this layer be included in the legends?
\code{NA}, the default, includes if any aesthetics are mapped.
\code{FALSE} never includes, and \code{TRUE} always includes.
It can also be a named logical vector to finely select the aesthetics to
display. To include legend keys for all levels, even
when no data exists, use \code{TRUE}.  If \code{NA}, all levels are shown in legend,
but unobserved levels are omitted.}

\item{inherit.aes}{If \code{FALSE}, overrides the default aesthetics,
rather than combining with them. This is most useful for helper functions
that define both data and aesthetics and shouldn't inherit behaviour from
the default plot specification, e.g. \code{\link[=annotation_borders]{annotation_borders()}}.}
}
\description{
The empirical cumulative distribution function (ECDF) provides an alternative
visualisation of distribution. Compared to other visualisations that rely on
density (like \code{\link[=geom_histogram]{geom_histogram()}}), the ECDF doesn't require any
tuning parameters and handles both continuous and categorical variables.
The downside is that it requires more training to accurately interpret,
and the underlying visual tasks are somewhat more challenging.
}
\details{
The statistic relies on the aesthetics assignment to guess which variable to
use as the input and which to use as the output. Either x or y must be provided
and one of them must be unused. The ECDF will be calculated on the given aesthetic
and will be output on the unused one.

If the \code{weight} aesthetic is provided, a weighted ECDF will be computed. In
this case, the ECDF is incremented by \code{weight / sum(weight)} instead of
\code{1 / length(x)} for each observation.
}
\section{Computed variables}{

These are calculated by the 'stat' part of layers and can be accessed with \link[=aes_eval]{delayed evaluation}.
\itemize{
\item \code{after_stat(ecdf)}\cr Cumulative density corresponding to \code{x}.
\item \code{after_stat(y)}\cr \ifelse{html}{\href{https://lifecycle.r-lib.org/articles/stages.html#superseded}{\figure{lifecycle-superseded.svg}{options: alt='[Superseded]'}}}{\strong{[Superseded]}} For backward compatibility.
}
}

\section{Dropped variables}{

\describe{
\item{weight}{After calculation, weights of individual observations (if
supplied), are no longer available.}
}
}

\examples{
set.seed(1)
df <- data.frame(
  x = c(rnorm(100, 0, 3), rnorm(100, 0, 10)),
  g = gl(2, 100)
)
ggplot(df, aes(x)) +
  stat_ecdf(geom = "step")

# Don't go to positive/negative infinity
ggplot(df, aes(x)) +
  stat_ecdf(geom = "step", pad = FALSE)

# Multiple ECDFs
ggplot(df, aes(x, colour = g)) +
  stat_ecdf()

# Using weighted eCDF
weighted <- data.frame(x = 1:10, weights = c(1:5, 5:1))
plain <- data.frame(x = rep(weighted$x, weighted$weights))

ggplot(plain, aes(x)) +
  stat_ecdf(linewidth = 1) +
  stat_ecdf(
    aes(weight = weights),
    data = weighted, colour = "green"
  )
}
\section{Aesthetics}{

\code{stat_ecdf()} understands the following aesthetics. Required aesthetics are displayed in bold and defaults are displayed for optional aesthetics:
\tabular{rll}{
 • \tab \strong{\code{\link[=aes_position]{x}} \emph{or} \code{\link[=aes_position]{y}}} \tab   \cr
 • \tab \code{\link[=aes_group_order]{group}} \tab → inferred \cr
 • \tab \code{weight} \tab → \code{NULL} \cr
}

Learn more about setting these aesthetics in \code{vignette("ggplot2-specs")}.
}
