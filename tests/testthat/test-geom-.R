test_that("aesthetic checking in geom throws correct errors", {
  p <- ggplot(mtcars) + geom_point(aes(disp, mpg, colour = after_scale(data)))
  expect_snapshot_error(ggplotGrob(p))

  aes <- list(a = 1:4, b = letters[1:4], c = TRUE, d = 1:2, e = 1:5)
  expect_snapshot_error(check_aesthetics(aes, 4))
})

test_that("get_geom_defaults can use various sources", {

  test <- get_geom_defaults(geom_point)
  expect_equal(test$colour, "black")

  test <- get_geom_defaults(geom_point(colour = "red"))
  expect_equal(test$colour, "red")

  test <- get_geom_defaults("point")
  expect_equal(test$colour, "black")

  test <- get_geom_defaults(GeomPoint, theme(geom = element_geom("red")))
  expect_equal(test$colour, "red")
})

test_that("geom defaults can be set and reset", {
  l <- geom_point()
  orig <- l$geom$default_aes$colour
  test <- get_geom_defaults(l)
  expect_equal(test$colour, "black")

  inv <- update_geom_defaults("point", list(colour = "red"))
  test <- get_geom_defaults(l)
  expect_equal(test$colour, "red")
  expect_equal(inv$colour, orig)

  inv <- update_geom_defaults("point", NULL)
  test <- get_geom_defaults(l)
  expect_equal(test$colour, "black")
  expect_equal(inv$colour, "red")

  inv <- update_geom_defaults("line", list(colour = "blue"))
  reset <- reset_geom_defaults()

  expect_equal(reset$geom_line$colour, "blue")
  expect_equal(reset$geom_point$colour, GeomPoint$default_aes$colour)
  expect_equal(GeomLine$default_aes$colour, inv$colour)
})

test_that("updating geom aesthetic defaults preserves class and order", {

  original_defaults <- GeomPoint$default_aes

  update_geom_defaults("point", aes(color = "red"))

  updated_defaults <- GeomPoint$default_aes

  expect_s7_class(updated_defaults, class_mapping)

  intended_defaults <- original_defaults
  intended_defaults[["colour"]] <- "red"

  expect_equal(updated_defaults, intended_defaults)

  update_geom_defaults("point", NULL)

})




test_that("updating stat aesthetic defaults preserves class and order", {

  original_defaults <- StatBin$default_aes

  update_stat_defaults("bin", aes(y = after_stat(density)))

  updated_defaults <- StatBin$default_aes

  expect_s7_class(updated_defaults, class_mapping)

  intended_defaults <- original_defaults
  intended_defaults[["y"]] <- expr(after_stat(density))
  attr(intended_defaults[["y"]], ".Environment") <- attr(updated_defaults[["y"]], ".Environment")

  expect_equal(updated_defaults, intended_defaults)

  update_stat_defaults("bin", NULL)

})
