#' Case Counts
#'
#' @import rvest
#' @import RSelenium
#' @import xfun
#' @export
caseCounts <- function(){
    ## pjs <- run_phantomjs()
    ## ses <- Session$new(port = pjs$port)
    ## ses$go(url)
    ## Sys.sleep(10)
    ## contents <- ses$findElement("#ember6")$getText()
    ## contents <- ses$getActiveElement()$getText()
    ## contents <- ses$findElement(".dashboard-page")$getText()
    ## url <- "https://erieny.maps.arcgis.com/apps/opsdashboard/index.html#/dd7f1c0c352e4192ab162a1dfadc58e1"
    url <- "https://erieny.maps.arcgis.com/apps/dashboards/dd7f1c0c352e4192ab162a1dfadc58e1"
    rD <- RSelenium::rsDriver(browser="firefox",
                          extraCapabilities = list("moz:firefoxOptions" = list(
                                                       args = list('--headless'))),
                          port = 2345L)
    driver <- rD$client
    driver$navigate(url)
    Sys.sleep(20)
    html <- driver$getPageSource()[[1]]
    driver$close()
    rD$server$stop()
    ## dat <- strsplit(ses$findElement("#ember20")$getText()[[1]], split = "\n")[[1]]
    ##html <- system.file("tests/testthat/erie.html", package="COVID19Erie")
    contents <- read_html(html) %>% html_nodes(".widget") %>% html_text()

    dat <- strsplit(contents, split = "\n")[[1]]
    dat <- gsub("  ", "", dat)
    dat <- dat[nchar(dat)>1]

    t_active <- as.integer(gsub(",", "", dat[grep("Active Cases", dat)[1] + 1]))
    t_recovered <- as.integer(gsub(",","",dat[grep("Recovered", dat)[1] + 1]))
    t_deaths <- as.integer(gsub(",","",dat[grep("Total Deaths", dat)[1] + 1]))
    t_confirmed <- as.integer(gsub(",", "", dat[grep("Confirmed Cases", dat)[1] + 1]))
    t_tested <- as.integer(gsub(",", "", dat[grep("Total PCR", dat)[1] + 1]))
    t_anti_tested <- as.integer(gsub(",", "", dat[grep("Total Antibody", dat)[1] + 1]))
    
    ## confirmed <- dat[(grep("Total Confirmed", dat) + 3):(length(dat)-1)]
    idx1 <- grep("[0-9] Confirmed", dat)[1]
    ## idx2 <- tail(grep("[0-9] Confirmed", dat), 1) + 1
    idx2 <- grep("Confirmed Cases by Zip Code", dat) - 1
    confirmed <- dat[idx1:idx2]
    confirmed <- data.frame(
        town = sub("\\/.*", "", confirmed[seq(2, length(confirmed), 2)]),
        confirmed = as.integer(gsub(",", "", sub(" .*", "", confirmed[seq(1, length(confirmed), 2)]))),
        stringsAsFactors = FALSE)
    counts <- data.frame(confirmed, recovered = NA, deaths = NA)
    updateT <- dat[grep("updated", dat)]
    updateT <- paste0(sub("EST.*", "EST", updateT), ")")
    
    attributes(counts)$update.time <- updateT
    attributes(counts)$total.recovered <- t_recovered
    attributes(counts)$total.confirmed <- t_confirmed
    attributes(counts)$total.deaths <- t_deaths
    attributes(counts)$active.cases <- t_active
    attributes(counts)$PCR.tested <- t_tested
    attributes(counts)$Antibody.tested <- t_anti_tested

    ## zip
    dat1 <- dat[(idx2 + 2):length(dat)]
    idx3 <- grep("[0-9] Confirmed", dat1)
    zipCounts <- data.frame(zip=dat1[idx3 - 1],
                            confirmed=as.integer(gsub(",","",sub(" Confirmed", "", dat1[idx3]))),
                            stringsAsFactors = FALSE)
    return(list(counts = counts, zipCounts = zipCounts))
}
