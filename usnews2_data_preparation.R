library('data.table')

usnews2 <- rio::import("https://raw.githubusercontent.com/sborms/sentometrics/master/data-raw/US_economic_news_1951-2014.csv")
usnews2$texts <- stringi::stri_replace_all(usnews2$text, replacement = " ", regex = "</br></br>")
usnews2$texts <- stringi::stri_replace_all(usnews2$texts, replacement = "", regex = '[\\"]')
usnews2$texts <- stringi::stri_replace_all(usnews2$texts, replacement = "", regex = "[^-a-zA-Z0-9,&.' ]")
usnews2$text <- NULL

usnews2$id <- usnews2$`_unit_id`

months <- lapply(stringi::stri_split(usnews2$date, regex = "/"), "[", 1)
days <- lapply(stringi::stri_split(usnews2$date, regex = "/"), "[", 2)
years <- lapply(stringi::stri_split(usnews2$date, regex = "/"), "[", 3)
yearsLong <- lapply(years, function(x) if (as.numeric(x) > 14) return(paste0("19", x)) else return(paste0("20", x)))
datesNew <- paste0(paste0(unlist(months), "/"), paste0(unlist(days), "/"), unlist(yearsLong))
datesNew <- as.character(as.Date(datesNew, format = "%m/%d/%Y"))
usnews2$date <- datesNew


usnews2 <- subset(usnews2, date >= "1971-01-01") ### date bug 1970
usnews2 <- subset(usnews2, !is.na(positivity)) 
usnews2 <- subset(usnews2, positivity !=5 & positivity !=6) ### Remove neutral response

usnews2$s <- ifelse(usnews2$positivity >5,1,-1 )

### Delete obsolete columns
usnews2$`_last_judgment_at` <- usnews2$`_trusted_judgments` <-
  usnews2$`positivity:confidence` <- usnews2$`relevance:confidence` <- usnews2$relevance_gold <-
  usnews2$articleid <- usnews2$`_unit_state` <- usnews2$`_golden` <- usnews2$positivity_gold <-
  usnews2$relevance <- usnews2$positivity <- usnews2$headline <- usnews2$`_unit_id`<-  NULL

usnews2 <- usnews2[order(usnews2$id),]
usnews2 <- as.data.table(usnews2)
table(usnews2$s)

save(usnews2, file = "usnews2.RData")