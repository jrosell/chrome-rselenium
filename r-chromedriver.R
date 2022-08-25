start_url <- "https://elnostreraco.com/blog/"
url_path <- "https://elnostreraco.com/blog/"
gh_required <- c("ropensci/binman", "ropensci/wdman", "ropensci/RSelenium")
pacman::p_load_gh(gh_required, install = FALSE) # If it fails, install.packages("pacman") and set install = TRUE
pacman::p_load(tidyverse)
# Adjust the proper chromedriver version according to your Google Chrome version (google-chrome --version)
cDrv <- chrome(version = '104.0.5112.79')
eCaps <- list(chromeOptions = list(args = c('--no-sandbox','--headless', '--disable-gpu', '--window-size=1280,800')))
remDr <- remoteDriver(browserName = "chrome", port = 4567L, extraCapabilities = eCaps)
remDr$open()
remDr$navigate(start_url)
webElems <- remDr$findElements(using = "css", "a")
internal_urls <-
  tibble(
    href = c(start_url, unlist(map(webElems, function(x){x$getElementAttribute("href")}))),
    n = 1
  ) %>%
  filter(str_detect(href, url_path)) %>%
  mutate(href = str_replace(href, "#.*", "")) %>%
  unique()
internal_urls
Sys.sleep(5)
remDr$close()


