#' Add data to a plotly visualization
#' 
#' @param p a plotly visualization
#' @param data a data frame.
#' @export
#' @examples 
#' 
#' plot_ly() %>% add_data(economics) %>% add_trace(x = ~date, y = ~pce)
add_data <- function(p, data = NULL) {
  if (is.null(data)) return(p)
  if (!is.plotly(p)) {
    stop("Don't know how to add traces to an object of class: ", 
         class(p), call. = FALSE)
  }
  id <- new_id()
  p$x$visdat[[id]] <- function() data
  p$x$cur_data <- id
  # TODO: should this also override the data used for the most recent trace?
  p
}

#' Add trace(s) to a plotly visualization
#' 
#' @param p a plotly or ggplot object.
#' @param ... These arguments are documented in the references section below.
#' Note that acceptable arguments depend on the trace type.
#' @param color Either a variable name or a vector to use for color mapping.
#' @param symbol Either a variable name or a (discrete) vector to use for symbol encoding.
#' @param size A variable name or numeric vector to encode the size of markers.
#' @param linetype Either a variable name or a (discrete) vector to use for linetype encoding.
#' @param data A data frame to associate with this trace (optional). If not 
#' provided, arguments are evaluated using the data frame in \code{\link{plot_ly}()}.
#' @param inherit inherit attributes from \code{\link{plot_ly}()}?
#' @param z a numeric matrix
#' @param x the x variable.
#' @param y the y variable.
#' @param text textual labels.
#' @param ymin a variable used to define the lower boundary of a polygon.
#' @param ymax a variable used to define the upper boundary of a polygon.
#' @param xend "final" x position (in this context, x represents "start")
#' @param yend "final" y position (in this context, y represents "start")
#' @seealso \code{\link{plot_ly}()}
#' @references \url{https://plot.ly/r/reference/}
#' @author Carson Sievert
#' @export
#' @rdname add_trace
#' @examples 
#' 
#' p <- plot_ly(economics, x = ~date, y = ~uempmed)
#' p
#' p %>% add_markers()
#' p %>% add_lines()
#' p %>% add_text(text = ".")
#' 
#' # attributes declared in plot_ly() carry over to downstream traces,
#' # but can be overwritten
#' plot_ly(economics, x = ~date, y = ~uempmed, color = I("red")) %>% 
#'   add_lines() %>%
#'   add_markers(color = ~pop) %>%
#'   layout(showlegend = FALSE)
#' 
add_trace <- function(p, ..., color, symbol, size, linetype, 
                      data = NULL, inherit = TRUE) {
  
  # "native" plotly arguments
  attrs <- list(...)
  
  # tack on "special" arguments
  attrs$color <- if (!missing(color)) color
  attrs$symbol <- if (!missing(symbol)) symbol
  attrs$linetype <- if (!missing(linetype)) linetype
  attrs$size <- if (!missing(size)) size
  
  if (!is.null(attrs[["group"]])) {
    warning("The group argument has been deprecated. Use group_by() instead.")
  }
  
  p <- add_data(p, data)
  
  # inherit attributes from the "first layer"
  if (inherit) {
    attrs <- modify_list(p$x$attrs[[1]], attrs)
  }
  
  p$x$attrs <- c(
    p$x$attrs %||% list(), 
    setNames(list(attrs), p$x$cur_data)
  )
  
  p
}


#' @inheritParams add_trace
#' @rdname add_trace
#' @export
add_markers <- function(p, x = NULL, y = NULL, z = NULL, ..., 
                        data = NULL, inherit = TRUE) {
  if (inherit) {
    x <- x %||% p$x$attrs[[1]][["x"]]
    y <- y %||% p$x$attrs[[1]][["y"]]
    z <- z %||% p$x$attrs[[1]][["z"]]
  }
  if (is.null(x) || is.null(y)) {
    stop("Must supply `x` and `y` attributes", call. = FALSE)
  }
  type <- if (!is.null(z)) "scatter3d" else "scatter"
  add_trace(
    p, x = x, y = y, z = z, type = type, mode = "markers", ...,
    data = data, inherit = inherit
  )
}


#' @inheritParams add_trace
#' @rdname add_trace
#' @export
add_text <- function(p, x = NULL, y = NULL, z = NULL, text = NULL, ...,
                     data = NULL, inherit = TRUE) {
  if (inherit) {
    x <- x %||% p$x$attrs[[1]][["x"]]
    y <- y %||% p$x$attrs[[1]][["y"]]
    z <- z %||% p$x$attrs[[1]][["z"]]
    text <- text %||% p$x$attrs[[1]][["text"]]
  }
  if (is.null(x) || is.null(y) || is.null(text)) {
    stop("Must supply `x`, `y` and `text` attributes", call. = FALSE)
  }
  type <- if (!is.null(z)) "scatter3d" else "scatter"
  add_trace(p, x = x, y = y, z = z, text = text, type = type, mode = "text", 
            ..., data = data, inherit = inherit)
}


#' @inheritParams add_trace
#' @rdname add_trace
#' @export
add_paths <- function(p, x = NULL, y = NULL, z = NULL, ...,
                      data = NULL, inherit = TRUE) {
  if (inherit) {
    x <- x %||% p$x$attrs[[1]][["x"]]
    y <- y %||% p$x$attrs[[1]][["y"]]
    z <- z %||% p$x$attrs[[1]][["z"]]
  }
  if (is.null(x) || is.null(y)) {
    stop("Must supply `x` and `y` attributes", call. = FALSE)
  }
  type <- if (!is.null(z)) "scatter3d" else "scatter"
  add_trace_classed(
    p, x = x, y = y, z = z, class = "plotly_path", type = type, mode = "lines", 
    ..., data = data, inherit = inherit
  )
}

#' @inheritParams add_trace
#' @rdname add_trace
#' @export
#' @examples 
#' txhousing %>% 
#'   group_by(city) %>% 
#'   plot_ly(x = ~date, y = ~median) %>%
#'   add_lines(fill = "black")
add_lines <- function(p, x = NULL, y = NULL, z = NULL, ...,
                      data = NULL, inherit = TRUE) {
  if (inherit) {
    x <- x %||% p$x$attrs[[1]][["x"]]
    y <- y %||% p$x$attrs[[1]][["y"]]
    z <- z %||% p$x$attrs[[1]][["z"]]
  }
  if (is.null(x) || is.null(y)) {
    stop("Must supply `x` and `y` attributes", call. = FALSE)
  }
  type <- if (!is.null(z)) "scatter3d" else "scatter"
  add_trace_classed(
    p, x = x, y = y, class = "plotly_line", type = type, mode = "lines", 
    ..., data = data, inherit = inherit
  )
}


#' @inheritParams add_trace
#' @rdname add_trace
#' @export
add_segments <- function(p, x = NULL, y = NULL, xend = NULL, yend = NULL, ...,
                         data = NULL, inherit = TRUE) {
  if (inherit) {
    x <- x %||% p$x$attrs[[1]][["x"]]
    xend <- xend %||% p$x$attrs[[1]][["xend"]]
    y <- y %||% p$x$attrs[[1]][["y"]]
    yend <- yend %||% p$x$attrs[[1]][["yend"]]
  }
  if (is.null(x) || is.null(y) || is.null(xend) || is.null(yend)) {
    stop("Must supply `x`/`y`/`xend`/`yend` attributes", call. = FALSE)
  }
  add_trace_classed(
    p, x = x, y = y, xend = xend, yend = yend,
    class = "plotly_segment", type = "scatter", mode = "lines", 
    ..., data = data, inherit = inherit
  )
}



#' @inheritParams add_trace
#' @rdname add_trace
#' @export
#' @examples 
#' 
#' ggplot2::map_data("world", "canada") %>%
#'   group_by(group) %>%
#'   plot_ly(x = ~long, y = ~lat) %>%
#'   add_polygons(hoverinfo = "none") %>%
#'   add_markers(text = ~paste(name, "<br />", pop), hoverinfo = "text",
#'     data = maps::canada.cities) %>%
#'   layout(showlegend = FALSE)
add_polygons <- function(p, x = NULL, y = NULL, ...,
                         data = NULL, inherit = TRUE) {
  if (inherit) {
    x <- x %||% p$x$attrs[[1]][["x"]]
    y <- y %||% p$x$attrs[[1]][["y"]]
  }
  if (is.null(x) || is.null(y)) {
    stop("Must supply `x`/`y` attributes", call. = FALSE)
  }
  add_trace_classed(
    p, class = "plotly_polygon", x = x, y = y,
    type = "scatter", fill = "toself", mode = "lines",  
    ..., data = data, inherit = inherit
  )
}


#' @inheritParams add_trace
#' @rdname add_trace
#' @export
#' @examples 
#' 
#' plot_ly(economics, x = ~date) %>% 
#'   add_ribbons(ymin = ~pce - 1e3, ymax = ~pce + 1e3)

add_ribbons <- function(p, x = NULL, ymin = NULL, ymax = NULL, ...,
                        data = NULL, inherit = TRUE) {
  if (inherit) {
    x <- x %||% p$x$attrs[[1]][["x"]]
    ymin <- ymin %||% p$x$attrs[[1]][["ymin"]]
    ymax <- ymax %||% p$x$attrs[[1]][["ymax"]]
  }
  if (is.null(x) || is.null(ymin) || is.null(ymax)) {
    stop("Must supply `x`/`ymin`/`ymax` attributes", call. = FALSE)
  }
  add_trace_classed(
    p, class = c("plotly_ribbon", "plotly_polygon"), 
    x = x, ymin = ymin, ymax = ymax, type = "scatter", mode = "lines",
    fill = "toself",  ..., data = data, inherit = inherit
  )
}


#' @inheritParams add_trace
#' @rdname add_trace
#' @export
#' @examples 
#' huron <- data.frame(year = 1875:1972, level = as.vector(LakeHuron))
#' plot_ly(huron, x = ~year, ymax = ~level) %>% add_area()
add_area <- function(p, x = NULL, ymax = NULL, ...,
                     data = NULL, inherit = TRUE) {
  
  if (inherit) {
    x <- x %||% p$x$attrs[[1]][["x"]]
    ymax <- ymax %||% p$x$attrs[[1]][["ymax"]]
  }
  if (is.null(x) || is.null(ymax)) {
    stop("Must supply `x`/`ymax` attributes", call. = FALSE)
  }
  add_trace_classed(
    p, class = c("plotly_area", "plotly_ribbon", "plotly_polygon"), 
    x = x, ymax = ymax,
    type = "scatter", fill = "toself", mode = "lines",  
    ..., data = data, inherit = inherit
  )
}



#' @inheritParams add_trace
#' @rdname add_trace
#' @export
#' @examples 
#' library(dplyr)
#' mtcars %>%
#'   count(vs) %>%
#'   plot_ly(x = ~vs, y = ~n) %>%
#'   add_bars()
add_bars <- function(p, x = NULL, y = NULL, ...,
                     data = NULL, inherit = TRUE) {
  if (inherit) {
    x <- x %||% p$x$attrs[[1]][["x"]]
    y <- y %||% p$x$attrs[[1]][["y"]]
  }
  if (is.null(x) || is.null(y)) {
    stop("Must supply `x`/`y` attributes", call. = FALSE)
  }
  # TODO: provide type checking in plotly_build for this trace type
  add_trace_classed(
    p, class = "plotly_bar", x = x, y = y, type = "bar", 
    ..., data = data, inherit = inherit
  )
}


#' @inheritParams add_trace
#' @rdname add_trace
#' @export
#' @examples 
#' 
#' plot_ly(x = ~rnorm(100)) %>% add_histogram()
add_histogram <- function(p, x = NULL, y = NULL, ...,
                          data = NULL, inherit = TRUE) {
  if (inherit) {
    x <- x %||% p$x$attrs[[1]][["x"]]
    y <- y %||% p$x$attrs[[1]][["y"]]
  }
  if (is.null(x) && is.null(y)) {
    stop("Must supply `x` and/or `y` attributes", call. = FALSE)
  }
  # TODO: provide type checking in plotly_build for this trace type
  add_trace_classed(
    p, class = "plotly_histogram", x = x, y = y, type = "histogram", 
    ..., data = data, inherit = inherit
  )
}


#' @inheritParams add_trace
#' @rdname add_trace
#' @export
#' @examples 
#' plot_ly(x = ~LETTERS, y = ~LETTERS) %>% add_histogram2d()
#' z <- as.matrix(table(LETTERS, LETTERS))
#' plot_ly(x = ~LETTERS, y = ~LETTERS, z = ~z) %>% add_histogram2d()
add_histogram2d <- function(p, x = NULL, y = NULL, z = NULL, ...,
                            data = NULL, inherit = TRUE) {
  if (inherit) {
    x <- x %||% p$x$attrs[[1]][["x"]]
    y <- y %||% p$x$attrs[[1]][["y"]]
    z <- z %||% p$x$attrs[[1]][["z"]]
  }
  if (is.null(z)) {
    if (is.null(x) || is.null(y)) {
      stop("Must supply both `x` and `y` attributes if `z` is NULL", call. = FALSE)
    }
  }
  # TODO: provide type checking in plotly_build for this trace type
  add_trace_classed(
    p, class = "plotly_histogram2d", x = x, y = y, z = z,
    type = "histogram2d",  ..., data = data, inherit = inherit
  )
}

#' @inheritParams add_trace
#' @rdname add_trace
#' @export
#' @examples 
#' plot_ly(MASS::geyser, x = ~waiting, y = ~duration) %>% 
#' add_histogram2dcontour()
add_histogram2dcontour <- function(p, x = NULL, y = NULL, z = NULL, ...,
                                   data = NULL, inherit = TRUE) {
  if (inherit) {
    x <- x %||% p$x$attrs[[1]][["x"]]
    y <- y %||% p$x$attrs[[1]][["y"]]
    z <- z %||% p$x$attrs[[1]][["z"]]
  }
  if (is.null(z)) {
    if (is.null(x) || is.null(y)) {
      stop("Must supply both `x` and `y` attributes if `z` is NULL", call. = FALSE)
    }
  }
  # TODO: provide type checking in plotly_build for this trace type
  add_trace_classed(
    p, class = "plotly_histogram2dcontour", x = x, y = y, z = z,
    type = "histogram2dcontour",  ..., data = data, inherit = inherit
  )
}



#' @inheritParams add_trace
#' @rdname add_trace
#' @export
#' @examples 
#' plot_ly(z = ~volcano) %>% add_heatmap()
add_heatmap <- function(p, x = NULL, y = NULL, z = NULL, ..., 
                        data = NULL, inherit = TRUE) {
  if (inherit) {
    x <- x %||% p$x$attrs[[1]][["x"]]
    y <- y %||% p$x$attrs[[1]][["y"]]
    z <- z %||% p$x$attrs[[1]][["z"]]
  }
  if (is.null(z)) {
    if (is.null(x) || is.null(y)) {
      stop("Must supply both `x` and `y` attributes if `z` is NULL", call. = FALSE)
    }
  }
  add_trace_classed(
    p, class = "plotly_heatmap", z = z,
    type = "heatmap",  ..., data = data, inherit = inherit
  )
}

#' @inheritParams add_trace
#' @rdname add_trace
#' @export
#' @examples 
#' plot_ly(z = ~volcano) %>% add_contour()
add_contour <- function(p, z = NULL, ..., data = NULL, inherit = TRUE) {
  if (inherit) {
    z <- z %||% p$x$attrs[[1]][["z"]]
  }
  if (is.null(z)) {
    stop("Must supply `z` attribute", call. = FALSE)
  }
  add_trace_classed(
    p, class = "plotly_contour", z = z, type = "contour",  ..., 
    data = data, inherit = inherit
  )
}


#' @inheritParams add_trace
#' @rdname add_trace
#' @export
#' @examples 
#' plot_ly(mtcars, x = ~factor(vs), y = ~mpg) %>% add_boxplot()
add_boxplot <- function(p, x = NULL, y = NULL, ..., data = NULL, inherit = TRUE) {
  if (inherit) {
    x <- x %||% p$x$attrs[[1]][["x"]]
    y <- y %||% p$x$attrs[[1]][["y"]]
  }
  if (is.null(x) && is.null(y)) {
    stop("Must supply either `x` or `y` attribute", call. = FALSE)
  }
  add_trace_classed(
    p, class = "plotly_boxplot", x = x,  y = y, type = "box", 
    ..., data = data, inherit = inherit
  )
}


#' @inheritParams add_trace
#' @rdname add_trace
#' @export
#' @examples 
#' plot_ly(z = ~volcano) %>% add_surface()
add_surface <- function(p, z = NULL, ..., data = NULL, inherit = TRUE) {
  if (inherit) {
    z <- z %||% p$x$attrs[[1]][["z"]]
  }
  if (is.null(z)) {
    stop("Must supply `z` attribute", call. = FALSE)
  }
  add_trace_classed(
    p, class = "plotly_surface", z = z, type = "surface", 
    ..., data = data, inherit = inherit
  )
}


#' @inheritParams add_trace
#' @rdname add_trace
#' @param geo anchor this trace on which geo object?
#' @export
#' @examples 
#' plot_ly() %>% add_scattergeo()
add_scattergeo <- function(p, geo = NULL, ..., data = NULL, inherit = TRUE) {
  if (inherit) {
    geo <- geo %||% p$x$attrs[[1]][["geo"]] %||% "geo"
  }
  add_trace_classed(
    p, class = "plotly_scattergeo", type = "scattergeo", geo = geo, 
    ..., data = data, inherit = inherit
  )
}


#' @inheritParams add_trace
#' @rdname add_trace
#' @export
#' @examples 
#' density <- state.x77[, "Population"] / state.x77[, "Area"]
#' plot_ly(z = ~density) %>% 
#'   add_choropleth(locations = state.abb, locationmode = 'USA-states') %>%
#'   layout(geo = list(scope = "usa"))
add_choropleth <- function(p, z = NULL, ..., data = NULL, inherit = TRUE) {
  if (inherit) {
    z <- z %||% p$x$attrs[[1]][["z"]]
  }
  if (is.null(z)) {
    stop("Must supply `z` attribute", call. = FALSE)
  }
  add_trace_classed(
    p, class = "plotly_choropleth", z = z, type = "choropleth", 
    ..., data = data, inherit = inherit
  )
}

# attach a class to a trace which informs data processing in plotly_build
add_trace_classed <- function(p, class = "plotly_polygon", ...) {
  p <- add_trace(p, ...)
  nAttrs <- length(p$x$attrs)
  p$x$attrs[[nAttrs]] <- prefix_class(p$x$attrs[[nAttrs]], class)
  p
}

# retrieve the non-plotly.js attributes for a given trace
special_attrs <- function(trace) {
  switch(
    class(trace)[[1]],
    plotly_area = c("ymax"),
    plotly_segment = c("xend", "yend"),
    plotly_ribbon = c("ymin", "ymax")
  )
}



# #' 
# #' 
# #' @export
# #' @examples
# #' 
# #' x <- rnorm(10)
# #' plot_ly(x = ~x) %>%
# #'   add_chull()
# add_chull <- function(p, ...) {
#   stop("not yet implemented")
#   ch <- chull(x, y = NULL)
#   # TODO: Should mode='markers+lines'? If so, retrace first points?
#   add_polygons(...)
# }





#' Apply function to plot, without modifying data
#' 
#' Useful when you need two or more layers that apply a summary statistic
#' to the original data.
#' 
#' @param p a plotly object.
#' @param fun a function. Should take a plotly object as input and return a 
#' modified plotly object.
#' @param ... arguments passed to \code{fun}.
#' @export
#' @examples
#' 
#' txhousing %>% 
#'   group_by(city) %>%
#'   plot_ly(x = ~date, y = ~median) %>%
#'   add_lines(alpha = 0.2, name = "Texan Cities") %>%
#'   add_fun(function(plot) {
#'     plot %>% filter(city == "Houston") %>% add_lines(name = "Houston")
#'   }) %>%
#'   add_fun(function(plot) {
#'     plot %>% filter(city == "San Antonio") %>% add_lines(name = "San Antonio")
#'   })
#'
#' plot_ly(mtcars, x = ~wt, y = ~mpg) %>%
#'   add_markers() %>%
#'   add_fun(function(p) {
#'     p %>% slice(which.max(mpg)) %>% 
#'       add_annotations("Good mileage")
#'   }) %>%
#'   add_fun(function(p) {
#'     p %>% slice(which.min(mpg)) %>% 
#'       add_annotations(text = "Bad mileage")
#'   })
#'
add_fun <- function(p, fun, ...) {
  oldDat <- p$x$cur_data
  p <- fun(p, ...)
  p$x$cur_data <- oldDat
  p$x$attrs[length(p$x$attrs)] <- setNames(
    list(p$x$attrs[[length(p$x$attrs)]]), oldDat
  )
  p
}


#' Add an annotation(s) to a plot
#' 
#' @param p a plotly object
#' @param text annotation text (required).
#' @param ... these arguments are documented at \url{https://plot.ly/r/reference/#layout-annotations}
#' @param data a data frame.
#' @param inherit inherit attributes from \code{\link{plot_ly}()}?
#' @author Carson Sievert
#' @export
#' @examples
#' 
#' # single annotation
#' plot_ly(mtcars, x = ~wt, y = ~mpg) %>%
#'   slice(which.max(mpg)) %>%
#'   add_annotations(text = "Good mileage")
#'   
#' # multiple annotations
#' plot_ly(mtcars, x = ~wt, y = ~mpg) %>%
#'   filter(gear == 5) %>%
#'   add_annotations("five cylinder", ax = 40) 
#'   

add_annotations <- function(p, text = NULL, ..., data = NULL, inherit = TRUE) {
  p <- add_data(p, data)
  attrs <- list(text = text, ...)
  # x/y/text inherit from plot_ly()
  for (i in c("x", "y", "text")) {
    attrs[[i]] <- attrs[[i]] %||% p$x$attrs[[1]][[i]]
  }
  if (is.null(attrs[["text"]])) {
    stop("Must supply text to annotation", call. = FALSE)
  }
  attrs <- list(annotations = attrs)
  # similar to layout()
  p$x$layoutAttrs <- c(
    p$x$layoutAttrs %||% list(), 
    setNames(list(attrs), p$x$cur_data)
  )
  p
}
