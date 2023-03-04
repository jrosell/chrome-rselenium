# Introduction ----
# Goal: Crawl a website folder following internal links on the pages.
# Done:
# - Crawl using rSelenium.
# - Get all links from the crawled page.
# - Queque them if not already creawled
# - Process the queque up to the defined limit number of crawls.
# - Save the results.
# Pending:
# - Use purrr safely or posible
# - Read robots nofollow in order to control the crawling process.


# Settings ----

next_url = "https://jrosell.github.io/AdventOfCode/2022/01.html"
include_path = "https://jrosell.github.io/AdventOfCode/"
exclude_path = "(error|--)"
max_crawls <- 5000
chrome_version <- '110.0.5481.77'
save_intermediate_results <- FALSE
sleep_sample <- sample(seq(0.01, 0.5, 0.01), 1)


# Requirements  ----

rlang::check_required("tidyverse") # install.packages("tidyverse")
rlang::check_required("RSelenium") # install.packages("RSelenium")
rlang::check_required("wdman") # install.packages("wdman")
rlang::check_required("rvest") # install.packages("rvest")
rlang::check_required("xml2") # install.packages("xml2")
library(tidyverse)
library(RSelenium)
library(rvest)
library(xml2)


# Execution ----

source("R/rselenium.R")
pending_internal_urls <- tibble(href = character(0))
crawled <- tibble(href = character(0), source = list())
pending <- 1
if (exists("cDrv")) { cDrv$stop() }
if (!dir.exists("data")) dir.create("data")
cDrv <- wdman::chrome(version = chrome_version)
eCaps <- list(chromeOptions = list(args = c('--no-sandbox','--headless', '--disable-gpu', '--window-size=1280,800')))
remDr <- remoteDriver(browserName = "chrome", port = 4567L, extraCapabilities = eCaps)
remDr$open()

for (i in 1:max_crawls) {
  print(paste0("Crawling ", i, "/", max_crawls, " | ", next_url, " | Queque: ", pending))

  remDr$navigate(next_url)
  crawled <- bind_rows(crawled, tibble(
    href = next_url,
    source = list(remDr$getPageSource()[[1]])
  ))

  if (save_intermediate_results) crawled %>% write_rds(here::here("data/crawled.rds"))

  new_internal_urls <-
    tibble(
      href = c(next_url, parse_links(remDr))
    ) %>%
    filter(str_detect(href, include_path)) %>%
    mutate(href = str_replace(href, "#.*", ""))

  pending_internal_urls <- bind_rows(pending_internal_urls, new_internal_urls) %>%
    unique() %>%
    filter(!str_detect(href, exclude_path)) %>%
    anti_join(crawled, by = "href") %>%
    arrange(str_length(href))

  pending <- nrow(pending_internal_urls)
  if (pending == 0) break

  next_url <- pending_internal_urls[[1]][[1]]

  Sys.sleep(sleep_sample)
}

if (exists("remDr")) { remDr$close() }
if (exists("cDrv")) { cDrv$stop() }


# Results ----
crawled %>% write_rds(here::here("data/crawled.rds"))
parsed <- crawl_parse(crawled)
write_csv(parsed, "data/crawled_parsed.csv")
read_csv("data/crawled_parsed.csv", show_col_types = FALSE) %>%
  glimpse()

# Example ----

# Rows: 12
# Columns: 9
# $ href         <chr> "https://jrosell.github.io/AdventOfCode/2022/01.html", "https://jro…
# $ lang         <chr> "en", "en", "en", "en", "en", "en", "en", "en", "en", "en", "en", "…
# $ title        <chr> "Day 1", "AdventOfCode R code", "Day 2", "Day 3", "Day 4", "Day 5",…
# $ meta         <chr> NA, "Author: Jordi Rosell", NA, NA, NA, NA, NA, NA, NA, NA, NA, NA
# $ h1           <chr> "Day 1", "AdventOfCode", "Day 2", "Day 3", "Day 4", "Day 5", "Day 6…
# $ h2           <chr> "Part 1: How many Calories are being carried by the Elf carrying th…
# $ h3           <chr> NA, "R code: All the code", NA, NA, NA, NA, NA, NA, NA, NA, NA, NA
# $ h4           <chr> NA, "Disclaimer", NA, NA, NA, NA, NA, NA, NA, NA, NA, NA
# $ main_content <chr> NA, "Advent of Code is an Advent calendar of small programming puzz…



