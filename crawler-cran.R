# Introduction ----
# Goal: Crawl a website folder following internal links on the pages.
# Done:
# - Crawl using RSelenium.
# - Extract all links from the crawled page.
# - Queque them if not already creawled
# - Process the queque up to the defined limit number of crawls.
# - Save the results.
# Pending:
# - Use purrr safely or possibly
# - Read robots meta and follow its instructions in the crawling process.

# Requirements  ----

rlang::check_installed("tidyverse") # install.packages("tidyverse")
rlang::check_installed("RSelenium") # install.packages("RSelenium")
rlang::check_installed("wdman") # install.packages("wdman")
rlang::check_installed("rvest") # install.packages("rvest")
rlang::check_installed("xml2") # install.packages("xml2")
library(tidyverse)
library(RSelenium)
library(rvest)
library(xml2)
source("R/rselenium.R")


# Settings ----

crawl_name <- "crawl_cran"
next_url <- "https://cran.r-project.org/web/packages/available_packages_by_date.html"
include_path <- "https://cran.r-project.org/web/packages/.+index\\.html"
internal_urls_queque <- tibble(href = character(0))
crawl_internal_links <- TRUE
exclude_path <- "(error|--)"
# exclude_path <- "(error|--|.pdf|LICENSE|ChangeLog|NEWS|README|INSTALL|news.html|citation.html|policies.html)"
max_crawls <- 5e4
chrome_version <- "110.0.5481.77"
save_intermediate_results <- FALSE
sleep_sample <- seq(0.01, 0.5, 0.01)
parse_fn <- parse_cran


# Execution ----

tictoc::tic()
print(date())
crawled <- tibble(href = character(0), source = list())
pending <- 1
if (exists("chrome_driver")) chrome_driver$stop()
if (!dir.exists("data")) dir.create("data")
chrome_driver <- wdman::chrome(version = chrome_version)
extra_capabilities <- list(chromeOptions = list(args = c(
  "--no-sandbox",
  "--headless",
  "--disable-gpu",
  "--window-size=1280,800"
)))
remote_driver <- remoteDriver(
    browserName = "chrome",
    port = 4567L,
    extraCapabilities = extra_capabilities
)
remote_driver$open()

for (i in 1:max_crawls) {

  print(paste0(
      "Crawling ", i, "/", max_crawls, " | ", next_url, " | Queque: ", pending
  ))

  remote_driver$navigate(next_url)
  crawled <- bind_rows(crawled, tibble(
    href = next_url,
    source = list(remote_driver$getPageSource()[[1]])
  ))

  if (save_intermediate_results) {
    crawled %>% write_rds(here::here("data", paste0(crawl_name, ".rds")))
  }

  if (crawl_internal_links) {
    new_internal_urls <-
      tibble(
        href = c(next_url, extract_links(remote_driver))
      ) %>%
      filter(str_detect(href, include_path)) %>%
      mutate(href = str_replace(href, "#.*", ""))
  } else {
    new_internal_urls <- tibble(href = character(0))
  }

  internal_urls_queque <-
    bind_rows(internal_urls_queque, new_internal_urls) %>%
    unique() %>%
    filter(!str_detect(href, exclude_path)) %>%
    anti_join(crawled, by = "href") %>%
    arrange(str_length(href))

  pending <- nrow(internal_urls_queque)
  if (pending == 0) break

  next_url <- internal_urls_queque[[1]][[1]]

  Sys.sleep(sample(sleep_sample, 1))
}

if (exists("remote_driver")) remote_driver$close()
if (exists("chrome_driver")) chrome_driver$stop()


# Results ----

crawled %>% write_rds(here::here("data", paste0(crawl_name, ".rds")))
parsed <- crawl_parse(crawled, parse_fn)
parsed %>% write_csv(here::here("data", paste0(crawl_name, "_parsed.csv")))
here::here("data", paste0(crawl_name, "_parsed.csv")) %>%
  read_csv(show_col_types = FALSE) %>%
  print(n = Inf)

tictoc::toc()
print(date())
