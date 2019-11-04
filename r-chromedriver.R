cran_packages <- c("devtools") 
if (length(setdiff(cran_packages, rownames(installed.packages()))) > 0) {
  install.packages(setdiff(cran_packages, rownames(installed.packages())), dependencies=TRUE, repos='http://cran.rstudio.com/')  
}
if(!require(binman)) devtools::install_github("ropensci/binman")
if(!require(wdman)) devtools::install_github("ropensci/wdman")
if(!require(RSelenium)) devtools::install_github("ropensci/RSelenium")
library(binman)
library(wdman)
library(RSelenium)
# Place chromedriver in your "User/Documents/R" folder
cDrv <- chrome(version = '78.0.3904.70')
eCaps <- list(chromeOptions = list(args = c('--no-sandbox','--headless', '--disable-gpu', '--window-size=1280,800')))
remDr<- remoteDriver(browserName = "chrome", port = 4567L, extraCapabilities = eCaps)
remDr$open()
remDr$navigate("http://www.google.com/")
webElem <- remDr$findElement(using = "css", "[name = 'q']")
webElem$sendKeysToElement(list("ChromeDriver", key = "enter"))
remDr$getCurrentUrl()
Sys.sleep(5)
remDr$close()


