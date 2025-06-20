test_that("polar distance is calculated correctly", {
  dat <- data_frame(
    theta = c(0, 2*pi,   2,   6, 6, 1,    1,  0),
    r     = c(0,    0, 0.5, 0.5, 1, 1, 0.75, 0.5))

  scales <- list(
    x = scale_x_continuous(limits = c(0, 2*pi)),
    y = scale_y_continuous(limits = c(0, 1))
  )
  coord <- coord_polar()
  panel_params <- coord$setup_panel_params(scales$x, scales$y)
  dists <- coord$distance(dat$theta, dat$r, panel_params, boost = 1)

  # dists is normalized by dividing by this value, so we'll add it back
  # The maximum length of a spiral arc, from (t,r) = (0,0) to (2*pi,1)
  maxlen <- spiral_arc_length(1 / (2 * pi), 0, 2 * pi)

  # These are the expected lengths. I think they're correct...
  expect_equal(dists,
    c(0, -1.225737494, -2, -0.5, -5, -0.25, -0.6736885011) / maxlen)

  # The picture can be visualized with:
  # ggplot(dat, aes(x=theta, y=r)) + geom_path() +
  #   geom_point(alpha=0.3) + coord_polar()
})

test_that("polar distance calculation ignores NA's", {

  # These are r and theta values; we'll swap them around for testing
  x1 <- c(0, 0.5, 0.5, NA, 1)
  x2 <- c(0,   1,   2, 0,  1)

  dists <- dist_polar(x1, x2)
  expect_equal(is.na(dists), c(FALSE, FALSE, TRUE, TRUE))
  dists <- dist_polar(x2, x1)
  expect_equal(is.na(dists), c(FALSE, FALSE, TRUE, TRUE))

  # NA on the end
  x1 <- c(0, 0.5, 0.5, 1, NA)
  x2 <- c(0,   1,   2, 0,  1)
  dists <- dist_polar(x1, x2)
  expect_equal(is.na(dists), c(FALSE, FALSE, FALSE, TRUE))
  dists <- dist_polar(x2, x1)
  expect_equal(is.na(dists), c(FALSE, FALSE, FALSE, TRUE))

  # NAs in each vector - also have NaN
  x1 <- c(0, 0.5, 0.5,  1, NA)
  x2 <- c(NaN,   1,   2, NA,  1)
  dists <- dist_polar(x1, x2)
  expect_equal(is.na(dists), c(TRUE, FALSE, TRUE, TRUE))
  dists <- dist_polar(x2, x1)
  expect_equal(is.na(dists), c(TRUE, FALSE, TRUE, TRUE))
})

test_that("clipping can be turned off and on", {
  # clip can be turned on and off
  p <- ggplot() + coord_polar()
  coord <- ggplot_build(p)@layout$coord
  expect_equal(coord$clip, "on")

  p <- ggplot() + coord_polar(clip = "off")
  coord <- ggplot_build(p)@layout$coord
  expect_equal(coord$clip, "off")
})

test_that("Inf is squished to range", {
  d <- cdata(
    ggplot(data_frame(x = "a", y = 1), aes(x, y)) +
      geom_col() +
      coord_polar() +
      annotate("text", Inf, Inf, label = "Top-Center") +
      annotate("text", -Inf, -Inf, label = "Center-Center")
  )

  # 0.4 is the upper limit of radius hardcoded in r_rescale()
  expect_equal(d[[2]]$r, 0.4)
  expect_equal(d[[2]]$theta, mapped_discrete(0))
  expect_equal(d[[3]]$r, 0)
  expect_equal(d[[3]]$theta, mapped_discrete(0))
})

test_that("coord_polar can have free scales in facets", {

  p <- ggplot(data_frame0(x = c(1, 2)), aes(1, x)) +
    geom_col() +
    coord_polar(theta = "y")

  sc <- get_panel_scales(p + facet_wrap(~ x), 1, 1)
  expect_equal(sc$y$get_limits(), c(0, 2))

  sc <- get_panel_scales(p + facet_wrap(~ x, scales = "free"), 1, 1)
  expect_equal(sc$y$get_limits(), c(0, 1))

  sc <- get_panel_scales(p + facet_grid(x ~ .), 1, 1)
  expect_equal(sc$y$get_limits(), c(0, 2))

  sc <- get_panel_scales(p + facet_grid(x ~ ., scales = "free"), 1, 1)
  expect_equal(sc$y$get_limits(), c(0, 1))
})

test_that("coord_polar throws informative warning about guides", {
  expect_snapshot_warning(
    ggplot_build(ggplot() + coord_polar() + guides(theta = guide_axis()))
  )
})

test_that("coord_radial warns about axes", {

  p <- ggplot(mtcars, aes(disp, mpg)) +
    geom_point()

  # Cannot use regular axis for theta position
  expect_snapshot_warning(ggplotGrob(
    p + coord_radial() + guides(theta = "axis")
  ))

  # If arc doesn't contain the top/bottom/left/right of a circle,
  # axis placement cannot be outside panel
  expect_snapshot_warning(ggplotGrob(
    p + coord_radial(start = 0.1 * pi, end = 0.4 * pi, r.axis.inside = FALSE)
  ))

})

test_that("bounding box calculations are sensible", {

  # Full cirle
  expect_equal(
    polar_bbox(arc = c(0, 2 * pi)),
    list(x = c(0, 1), y = c(0, 1))
  )

  # Full offset cirle
  expect_equal(
    polar_bbox(arc = c(2 * pi, 4 * pi)),
    list(x = c(0, 1), y = c(0, 1))
  )

  # Right half of circle
  expect_equal(
    polar_bbox(arc = c(0, pi)),
    list(x = c(0.45, 1), y = c(0, 1))
  )

  # Right quarter of circle
  expect_equal(
    polar_bbox(arc = c(0.25 * pi, 0.75 * pi)),
    list(x = c(0.45, 1), y = c(0.146446609, 0.853553391))
  )

  # Top quarter of circle with inner radius
  expect_equal(
    polar_bbox(arc = c(-0.25 * pi, 0.25 * pi), inner_radius = c(0.2, 0.4)),
    list(x = c(0.146446609, 0.853553391), y = c(0.59142136, 1))
  )
})

test_that("when both x and y are AsIs, they are not transformed", {

  p <- ggplot() +
    annotate("text", x = I(0.75), y = I(0.25), label = "foo") +
    scale_x_continuous(limits = c(0, 10)) +
    scale_y_continuous(limits = c(0, 10))

  grob <- get_layer_grob(p + coord_polar())[[1]]
  location <- c(as.numeric(grob$x), as.numeric(grob$y))
  expect_equal(location, c(0.75, 0.25))

  grob <- get_layer_grob(p + coord_radial())[[1]]
  location <- c(as.numeric(grob$x), as.numeric(grob$y))
  expect_equal(location, c(0.75, 0.25))

  # Check warning is thrown if only one is AsIs
  p <- ggplot() +
    annotate("text", x = I(0.75), y = 2.5, label = "foo") +
    scale_x_continuous(limits = c(0, 10)) +
    scale_y_continuous(limits = c(0, 10)) +
    coord_radial()

  expect_snapshot_warning(ggplotGrob(p))

})

test_that("radial coords can be reversed", {
  p <- ggplot(data_frame0(x = c(0, 2), y = c(0, 2))) +
    aes(x = x, y = y) +
    geom_point() +
    scale_x_continuous(limits = c(-1, 3), expand = c(0, 0)) +
    scale_y_continuous(limits = c(-1, 3), expand = c(0, 0)) +
    theme_test() +
    theme(axis.line = element_line())
  fwd <- coord_radial(start = 0.5 * pi, end = 1.5 * pi, reverse = "none")
  rev <- coord_radial(start = 0.5 * pi, end = 1.5 * pi, reverse = "thetar")

  expect_doppelganger("reversed polar coords", p + rev)

  fwd <- layer_grob(p + fwd)[[1]]
  rev <- layer_grob(p + rev)[[1]]

  expect_equal(as.numeric(fwd$x), rev(as.numeric(rev$x)))
  expect_equal(as.numeric(fwd$y), rev(as.numeric(rev$y)))
})

test_that("coord_radial can deal with empty breaks (#6271)", {
  p <- ggplot_build(
    ggplot(mtcars, aes(mpg, disp)) +
      geom_point() +
      coord_radial() +
      scale_x_continuous(breaks = numeric()) +
      scale_y_continuous(breaks = numeric())
  )
  guides <- p@layout$panel_params[[1]]$guides$guides
  is_none <- vapply(guides, inherits, logical(1), what = "GuideNone")
  expect_true(all(is_none))
})

# Visual tests ------------------------------------------------------------

#TODO: Once {vdiffr} supports non-rectangular clipping paths, we should add a
# test for `coord_radial(clip = "on")`'s ability to clip to the sector

test_that("polar coordinates draw correctly", {
  theme <- theme_test() +
    theme(
      axis.text.y = element_blank(),
      axis.title = element_blank(),
      panel.grid.major = element_line(colour = "grey90")
    )
  dat <- data_frame(x = rep(0:1, 4), y = rep(c(1, 10, 40, 80), each = 2))

  expect_doppelganger("three-concentric-circles",
    ggplot(dat, aes(x, y, group = factor(y))) +
      geom_path() +
      coord_polar() +
      theme
  )

  dat <- data_frame(
    theta = c(0, 2*pi,   2,   6, 6, 1,    1,  0),
    r     = c(0,    0, 0.5, 0.5, 1, 1, 0.75, 0.5),
    g     = 1:8
  )
  expect_doppelganger("Rays, circular arcs, and spiral arcs",
    ggplot(dat, aes(theta, r, colour = g)) +
      geom_path(show.legend = FALSE) +
      geom_point(colour = "black") +
      coord_polar() +
      theme
  )

  dat <- data_frame(x = LETTERS[1:3], y = 1:3)
  expect_doppelganger("rose plot with has equal spacing",
    ggplot(dat, aes(x, y)) +
      geom_bar(stat = "identity") +
      coord_polar() +
      theme
  )
  expect_doppelganger("racetrack plot: closed and no center hole",
    ggplot(dat, aes(x, y)) +
      geom_bar(stat = "identity") +
      coord_polar(theta = "y") +
      theme
  )
  expect_doppelganger("racetrack plot: closed and has center hole",
    ggplot(dat, aes(x, y)) +
      geom_bar(stat = "identity") +
      coord_polar(theta = "y") +
      scale_x_discrete(expand = c(0, 0.6)) +
      theme
  )
  expect_doppelganger("secondary axis ticks and labels",
    ggplot(dat, aes(x, y, group = factor(y))) +
      geom_blank() +
      scale_y_continuous(sec.axis = sec_axis(~. * 0.1, name = "sec y")) +
      coord_polar() +
      theme_test() +
      theme(axis.text.x = element_blank())
  )
})

test_that("coord_radial() draws correctly", {

  # Theme to test for axis placement
  theme <- theme(
    axis.line.theta = element_line(colour = "tomato"),
    axis.line.r   = element_line(colour = "dodgerblue"),
  )

  sec_guides <- guides(
    r.sec = guide_axis(
      theme = theme(axis.line.r = element_line(colour = "orchid"))
    ),
    theta.sec = guide_axis_theta(
      theme = theme(axis.line.theta = element_line(colour = "limegreen"))
    )
  )

  p <- ggplot(mtcars, aes(disp, mpg)) +
    geom_point() +
    theme

  expect_doppelganger("inner.radius with all axes", {
    p + coord_radial(inner.radius = 0.3, r.axis.inside = FALSE) +
      sec_guides
  })

  expect_doppelganger("partial with all axes", {
    p + coord_radial(start = 0.25 * pi, end = 0.75 * pi, inner.radius = 0.3,
                     r.axis.inside = TRUE, theta = "y") +
      sec_guides
  })

  df <- data_frame0(
    x = 1:5, lab = c("cat", "strawberry\ncake", "coffee", "window", "fluid")
  )

  ggplot(df, aes(x, label = lab)) +
    geom_text(aes(y = "0 degrees"),  angle = 0) +
    geom_text(aes(y = "90 degrees"), angle = 90) +
    coord_radial(start = 0.5 * pi, end = 1.5 * pi,
                 rotate.angle = TRUE) +
    theme

  expect_doppelganger(
    "bottom half circle with rotated text",
    ggplot(df, aes(x, label = lab)) +
      geom_text(aes(y = "0 degrees"),  angle = 0) +
      geom_text(aes(y = "90 degrees"), angle = 90) +
      coord_radial(start = 0.5 * pi, end = 1.5 * pi,
                   rotate.angle = TRUE, r.axis.inside = FALSE) +
      theme
  )
})

test_that("coord_radial()'s axis internal placement works", {

  df <- data.frame(x = c(0, 360), y = c(1, 14))

  expect_doppelganger(
    "full circle with axes placed at 90 and 225 degrees",
    ggplot(df, aes(x, y)) +
      geom_point() +
      coord_radial(
        expand = FALSE,
        r.axis.inside = c(90, 225)
      ) +
      guides(r.sec = "axis") +
      theme(axis.line = element_line())
  )
})
