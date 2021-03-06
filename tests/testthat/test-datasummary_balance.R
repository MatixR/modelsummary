library(modelsummary)
library(estimatr)

context('datasummary_balance')

test_that('only numeric', {
  tab <- datasummary_balance(~vs, mtcars, output = 'dataframe')
  truth <- c(" ", "0 (N=18) Mean", "0 (N=18) Std. Dev.", "1 (N=14) Mean",
    "1 (N=14) Std. Dev.", "Diff. in Means", "Std. Error")
  expect_s3_class(tab, 'data.frame')
  expect_equal(dim(tab), c(10, 7))
  expect_equal(colnames(tab), truth)
})

test_that('only factors', {
  tmp <- mtcars
  tmp$cyl <- factor(tmp$cyl)
  tmp$gear <- factor(tmp$gear)
  tmp$vs <- as.logical(tmp$vs)
  tmp <- tmp[, c('am', 'vs', 'cyl', 'gear')]
  tab <- datasummary_balance(~am, tmp, output = 'dataframe')
  truth <- c(" ", "  ", "0 (N=19) N", "0 (N=19) %", "1 (N=13) N",
    "1 (N=13) %")
  expect_s3_class(tab, 'data.frame')
  expect_equal(dim(tab), c(8, 6))
  expect_equal(colnames(tab), truth)
})

test_that('both factors and numerics', {
  tmp <- mtcars
  tmp$cyl <- factor(tmp$cyl)
  tmp$gear <- factor(tmp$gear)
  tmp$vs <- as.logical(tmp$vs)
  tab <- datasummary_balance(~am, tmp, output = 'dataframe')
  truth <- c(" ", "  ", "0 (N=19) Mean", "0 (N=19) Std. Dev.", "1 (N=13) Mean",
    "1 (N=13) Std. Dev.", "Diff. in Means", "Std. Error")
  expect_s3_class(tab, 'data.frame')
  expect_equal(dim(tab), c(16, 8))
  expect_equal(colnames(tab), truth)
})

test_that('more than two conditions', {
  tmp <- mtcars
  tmp$cyl <- factor(tmp$cyl)
  tmp$vs <- as.logical(tmp$vs)
  tab <- datasummary_balance(~gear, tmp, output = 'dataframe', dinm = FALSE)
  expect_s3_class(tab, 'data.frame')
  expect_equal(dim(tab), c(14, 8))
})

test_that('output formats do not produce errors', {
  tmp <- mtcars
  tmp$cyl <- as.character(tmp$cyl)
  tmp$vs <- as.logical(tmp$vs)
  expect_error(datasummary_balance(~am, tmp, output = 'huxtable'), NA)
  expect_error(datasummary_balance(~am, tmp, output = 'flextable'), NA)
  expect_error(datasummary_balance(~am, tmp, output = 'kableExtra'), NA)
  expect_error(datasummary_balance(~am, tmp, output = 'huxtable'), NA)
  expect_error(datasummary_balance(~am, tmp, output = 'dataframe'), NA)
  expect_error(datasummary_balance(~am, tmp, output = 'markdown'), NA)
  expect_error(datasummary_balance(~am, tmp, output = 'latex'), NA)
  expect_error(datasummary_balance(~am, tmp, output = 'html'), NA)
})

test_that('single numeric', {
  tmp <- mtcars[, c('am', 'mpg')]
  tab <- datasummary_balance(~am, data = tmp, output = 'dataframe')
  expect_s3_class(tab, 'data.frame')
  expect_equal(dim(tab), c(1, 7))
  expect_equal(tab[[1]], 'mpg')
})

test_that('single factor', {
  tmp <- mtcars[, c('am', 'gear')]
  tmp$gear <- factor(tmp$gear)
  tab <- datasummary_balance(~am, data = tmp, output = 'dataframe')
  expect_s3_class(tab, 'data.frame')
  expect_equal(dim(tab), c(3, 5))
  expect_equal(tab[[1]][1], '3')
})

test_that('dinm=FALSE', {
  tab <- datasummary_balance(~vs, mtcars, dinm = FALSE, output = 'dataframe')
  expect_s3_class(tab, 'data.frame')
  expect_equal(dim(tab), c(10, 5))
  expect_equal(tab[[1]][1], 'mpg')
})

test_that('dinm_statistic = "p.value"', {
  tab <- datasummary_balance(~vs, mtcars, dinm_statistic = 'p.value',
    output = 'dataframe')
  expect_s3_class(tab, 'data.frame')
  expect_equal(dim(tab), c(10, 7))
  expect_equal(tab[[1]][1], 'mpg')
  expect_equal(colnames(tab)[ncol(tab)], 'p')
})

test_that('fmt', {
  tmp <- mtcars[, c('am', 'mpg', 'gear')]
  tmp$gear <- factor(tmp$gear)
  truth <- c("17.15", "N", "15", "4", "0")
  tab <- datasummary_balance(~am, tmp, fmt = "%.2f", output = 'dataframe')
  expect_equal(tab[[2]], truth)
})


test_that('too many factor levels', {

  dat <- data.frame(ID = as.character(1:100),
    Y = rnorm(100),
    Z_comp = sample(0:1, 100, replace = TRUE))
  expect_error(datasummary_balance(~Z_comp, dat))
})

test_that('estimatr: clusters, blocks, weights', {

  set.seed(286342)
  # clusters
  dat <- data.frame(ID = as.character(1:100),
    Y = rnorm(100),
    Z_comp = sample(0:1, 100, replace = TRUE))
  dat$clusters <- sample(20, size = nrow(dat), replace = TRUE)
  idx <- sample(unique(dat$clusters), 12)
  dat$Z_clust <- as.numeric(dat$clusters %in% idx)
  dat$ID <- NULL

  truth <- difference_in_means(Y ~ Z_clust, clusters = clusters, data = dat)
  truth <- estimatr::tidy(truth)

  tab <- datasummary_balance(~Z_clust, dat, fmt = "%.6f", output = 'dataframe')
  expect_equal(tab[1, ncol(tab)], sprintf("%.6f", truth$std.error))

  # blocks
  dat$block <- rep(1:5, each = 20) # hardcoded name in estimatr
  dat <- dat %>%
    dplyr::group_by(block) %>%
    dplyr::mutate(Z_block = rbinom(dplyr::n(), 1, .5))
  dat$blocks <- dat$block # hardcoded name in datasummary_balance
  dat$clusters <- NULL

  truth <- difference_in_means(Y ~ Z_block, blocks = block, data = dat)
  truth <- sprintf("%.6f", tidy(truth)$std.error)

  tab <- datasummary_balance(~Z_block, dat, fmt = "%.6f", output = 'dataframe')
  expect_equal(tab[1, ncol(tab)], truth)

})


test_that('words with tibbles', {
  res <- dplyr::starwars %>%
    dplyr::filter(species == 'Human') %>%
    dplyr::select(height:gender) %>%
    datasummary_balance(~gender, data = ., output = "data.frame")
  expect_equal(dim(res), c(28, 8))
})


##################
#  save to file  #
##################
tmp <- mtcars
tmp$cyl <- as.factor(tmp$cyl)
tmp$vs <- as.logical(tmp$vs)
tmp$am <- as.character(tmp$am)
save_to_file <- function(ext) {
  msg <- paste('save to', ext)
  test_that(msg, {
    random <- stringi::stri_rand_strings(1, 30)
    filename <- paste0(random, ext)
    expect_error(datasummary_balance(~am, data = tmp, output = filename), NA)
    unlink(filename)
  })
}
for (ext in c('.html', '.tex', '.rtf', '.docx', '.pptx', '.jpg', '.png')) {
  save_to_file(ext)
}

#####################################
#  add_columns output formats work  #
#####################################
tmp <- mtcars
tmp$cyl <- as.character(tmp$cyl)
tmp$vs <- as.logical(tmp$vs)
custom <- data.frame('a' = 1:2, 'b' = 1:2)
output_formats <- c('gt', 'kableExtra', 'flextable', 'huxtable', 'latex',
  'markdown', 'html')
for (o in output_formats) {
  testname <- paste('add_columns with', o)
  test_that(testname, {
    expect_warning(datasummary_balance(~am, tmp, add_columns = custom, output = o), NA)
  })
}

######################
#  various datasets  #
######################
test_that('datasummary_balance: various datasets', {
  data(PlantGrowth)
  tab <- datasummary_balance(~group, PlantGrowth, output = 'dataframe', dinm = FALSE)
  expect_equal(tab[1, 2], '5.0')
  expect_equal(tab[1, 3], '0.6')
  expect_equal(tab[1, 4], '4.7')
  expect_equal(tab[1, 5], '0.8')
  expect_equal(tab[1, 6], '5.5')
  expect_equal(tab[1, 7], '0.4')
})
