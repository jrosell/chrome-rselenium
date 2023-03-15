# chrome-rselenium

### Use Google Chrome from your R scripts using WebDriver for navigating to web pages, user input, JavaScript execution, and more.

## Examples

### Use RSelenium to construct your dataset (newest example)

You can crawl available CRAN packages using Selenium on Ubuntu (should work also in other Linux/Windows/Mac) with R by following this steps:

1.  Clone the project (change myproject to whatever your want)

```{=html}
    git clone https://github.com/jrosell/chrome-rselenium myproject
    cd myproject
```
2.  Install Rstudio for R from <https://rstudio.com/products/rstudio/>

3.  Run crawler-cran.R (\~5h)

4.  Check the results in the data folder (You can check 2023-03-15 results [here](https://github.com/jrosell/chrome-rselenium/blob/master/data/crawled_cran_parsed.csv))

### Use RSelenium as a website crawler (older example)

You can crawl a website using selenium on Ubuntu (should work also in other Linux/Windows/Mac) with R by following this steps:

1.  Clone the project (change myproject to whatever your want)

```{=html}
    git clone https://github.com/jrosell/chrome-rselenium myproject
    cd myproject
```
2.  Install Rstudio for R from <https://rstudio.com/products/rstudio/>

3.  Edit crawler.R. Change next_url, include_path, exclude_path and max_crawls, chrome_version, save_intermediate_results and sleep_sample as required.

4.  Run it and check the results in the data folder.

### Use RSelenium to get information of a single URL (older example)

You can use selenium on Ubuntu (should work also in other Linux/Windows/Mac) with R by following this steps:

1.  Clone the project (change myproject to whatever your want)

```{=html}
    git clone https://github.com/jrosell/chrome-rselenium myproject
    cd myproject
```
2.  Install Rstudio for R from <https://rstudio.com/products/rstudio/>

3.  Place chromedriver file in your "User/Documents/R" folder If you need to update current chromedriver, download it from <https://sites.google.com/a/chromium.org/chromedriver/downloads> and extract it there.

4.  Install devtools and RSelenium for Rstudio using r-crhomedriver.R

5.  Run it

6.  Have fun!

Copy r-crhomedriver.R script and edit your new scripts.

## Open for collaborations

You can do pull resquests or open issues if you want to help.
