
extract_links <- function(driver) {
  links_elems <- driver$findElements(using = "css selector", "a")
  return(unlist(purrr::map(links_elems, function(x) {
      x$getElementAttribute("href")
  })))
}

page_parse <- function(source, main_content_css = "h1 + *") {
  xml <- rvest::minimal_html(source)
  lang <- source %>% str_extract(" lang=\"(.*)\"") %>% substr(8, 9)
  title <- xml %>%
    html_nodes(xpath = '//title') %>%
    html_text()
  meta <- xml %>%
    html_nodes(xpath = '//meta[@name="description"]') %>%
    html_attr('content')
  h1 <- xml %>%
    html_nodes(xpath = '//h1') %>%
    html_text()
  h2 <- xml %>%
    html_nodes(xpath = '//h2') %>%
    html_text()
  h3 <- xml %>%
    html_nodes(xpath = '//h3') %>%
    html_text()
  h4 <- xml %>%
    html_nodes(xpath = '//h4') %>%
    html_text()
  alt <- xml %>%
    html_nodes(xpath = '//img') %>%
    html_attr('alt')
  main_content  <-  xml %>%
    html_elements(css = main_content_css) %>%
    html_text()
  tibble(
    lang = paste(lang, collapse = " "),
    title = paste(title, collapse = " "),
    meta = paste(meta, collapse = " "),
    h1 = paste(h1, collapse = " "),
    h2 = paste(h2, collapse = " "),
    h3 = paste(h3, collapse = " "),
    h4 = paste(h4, collapse = " "),
    main_content = paste(main_content, collapse = " ")
  ) %>%
  mutate(lang = na_if(lang, "NA"))
}


crawl_parse <- function(crawled, fn = page_parse) {
  crawled %>%
    mutate(parsed = map(source,  {{ fn }})) %>%
    unnest_wider(parsed) %>%
    select(-source)
}


clean_links_href <- function(df, url_path) {
  df %>%
    filter(str_detect(href, url_path)) %>%
    mutate(href = str_replace(href, "#.*", "")) %>%
    distinct(href, .keep_all = TRUE)
}

get_links_href <- function(url) {
  eCaps <- list(chromeOptions = list(args = c('--no-sandbox','--headless', '--disable-gpu', '--window-size=1280,800')))
  remDr <- remoteDriver(browserName = "chrome", port = 4567L, extraCapabilities = eCaps)
  remDr$open()
  remDr$navigate(url)
  Sys.sleep(2)
  webElems <- remDr$findElements(using = "css", "a")
  links_href <- unlist(map(webElems, function(x){x$getElementAttribute("href")}))
  remDr$close()
  return(links_href)
}


parse_cran <- function(source) {
  xml <- rvest::minimal_html(source)
  title <- xml %>%
    html_nodes(xpath = '//title') %>%
    html_text()
  meta_title <- xml %>%
    html_nodes(xpath = '//meta[@name="og:title"]') %>%
    html_attr('content')
  meta_description <- xml %>%
    html_nodes(xpath = '//meta[@name="og:description"]') %>%
    html_attr('content')
  h1 <- xml %>%
    html_nodes(xpath = '//h1') %>%
    html_text()
  h2 <- xml %>%
    html_nodes(xpath = '//h2') %>%
    html_text()
  main_content  <-  xml %>%
    html_elements(css = 'h2 + *') %>%
    html_text()
  table <- xml %>%
    html_nodes(xpath = '//table') %>%
    html_text()
  tibble(
    title = paste(title, collapse = " "),
    meta_title = paste(meta_title, collapse = " "),
    meta_description = paste(meta_description, collapse = " "),
    h1 = paste(h1, collapse = " "),
    h2 = paste(h2, collapse = " "),
    main_content = paste(main_content, collapse = " "),
    table = paste(table, collapse = " ") %>% stringr::str_trunc(32767)
  )
}
