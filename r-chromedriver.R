pacman::p_load(tidyverse, install = FALSE)
start_url <- "https://elnostreraco.com/blog/"
url_path <- "https://elnostreraco.com/blog/"
chromedriver_version <- '104.0.5112.79' # Adjust the proper chromedriver version according to your Google Chrome version (google-chrome --version)


# Adjust the proper chromedriver version according to your Google Chrome version (google-chrome --version)
source("R/rselenium.R")
gh_required <- c("ropensci/binman", "ropensci/wdman", "ropensci/RSelenium")
pacman::p_load_gh(gh_required, install = FALSE) # If it fails, install.packages("pacman") and set install = TRUE
if(exists('chrome_connection')){
  print("dins")
  chrome_connection$stop()
  rm(chrome_connection)
}
chrome_connection <- chrome(version = chromedriver_version)


internal_urls <-
  tibble(
    href = start_url,
    n = 0
  ) %>%
  bind_rows(tibble(
    href = get_links_href(start_url),
    n = 1
  )) %>%
  clean_links_href(url_path)

Sys.sleep(1)

i <- 1
step_links <-
  internal_urls %>%
  filter(n == i) %>%
  # slice_head(n = 2) %>%
  group_split(href) %>%
  map_df(function(x){
    x_url <- x$href[[1]]
    x %>% bind_rows(tibble(href = get_links_href(x_url), n = i + 1))
  }) %>%
  clean_links_href(url_path) %>%
  anti_join(internal_urls, by = "href") %>%
  bind_rows(internal_urls, .)

internal_urls <- step_links

i <- 2
step_links <-
  internal_urls %>%
  filter(n == i) %>%
  # slice_head(n = 2) %>%
  group_split(href) %>%
  map_df(function(x){
    x_url <- x$href[[1]]
    x %>% bind_rows(tibble(href = get_links_href(x_url), n = i + 1))
  }) %>%
  clean_links_href(url_path) %>%
  anti_join(internal_urls, by = "href") %>%
  bind_rows(internal_urls, .)

View(step_links)




