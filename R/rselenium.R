
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

clean_links_href <- function(df, url_path) {
  df %>%
    filter(str_detect(href, url_path)) %>%
    mutate(href = str_replace(href, "#.*", "")) %>%
    distinct(href, .keep_all = TRUE)
}

page_parse <- function(source, main_content_css = "h1 + *") {
  xml <- rvest::minimal_html(source)
  lang <- xml %>%
    html_nodes(xpath = '//html[@lang]') %>%
    html_text()
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
  list(
    lang = paste(lang, collapse = " "),
    title = paste(title, collapse = " "),
    meta = paste(meta, collapse = " "),
    h1 = paste(h1, collapse = " "),
    h2 = paste(h2, collapse = " "),
    h3 = paste(h3, collapse = " "),
    h4 = paste(h4, collapse = " "),
    main_content = paste(main_content, collapse = " ")
  )
}


parse_links <- function(driver){
  linksElems <- driver$findElements(using = "css selector", "a")
  unlist(map(linksElems, function(x){x$getElementAttribute("href")}))
}
