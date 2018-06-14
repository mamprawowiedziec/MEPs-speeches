
library(tidyverse)

query <- "SELECT stm.*, national_party.full_name as national_party_full_name FROM (
	SELECT stm_all.*, eu_party_code.id as eu_party_code FROM
(SELECT stm_dep.*, eu_group.full_name as eu_group_full_name FROM
(SELECT statements.*, mep.name, mep.nationality, mep.link as mep_link  FROM 
(SELECT id , name, nationality, link FROM deputies
LEFT JOIN term_of_office 
ON deputies.id = term_of_office.deputies_id 
WHERE term_of_office.term = 8) mep
RIGHT JOIN statements 
ON statements.deputies_id = mep.id) stm_dep
LEFT JOIN 
(SELECT `date_beginning`, IFNULL(`date_end`, '2100-01-01') as data_end, 
`deputies_id`, `full_name`
FROM `eu_party`) eu_group 
ON eu_group.deputies_id = stm_dep.deputies_id 
WHERE eu_group.date_beginning <= stm_dep.date AND eu_group.data_end >= stm_dep.date
) stm_all
LEFT JOIN eu_party_code
ON stm_all.eu_group_full_name = eu_party_code.full_name
) stm
LEFT JOIN 
(SELECT `date_beginning`, IFNULL(`date_end`, '2100-01-01') as data_end, 
`deputies_id`, `full_name`
FROM `national_party`) national_party 
ON national_party.deputies_id = stm.deputies_id 
WHERE national_party.date_beginning <= stm.date AND national_party.data_end >= stm.date 
AND term ='8'"

config <- read_config()

conn <- dbConnect(
  MySQL(),
  dbname = config$value[1],
  host = config$value[2],
  username = config$value[3],
  password = config$value[4]
)
dbSendQuery(conn, "SET NAMES 'utf8';")


data <- dbGetQuery(conn, query)

data <- data %>% 
  select(date, language_code, nationality, title,
         name, eu_party_code, national_party_full_name )

lang <- dbGetQuery(conn, 'SELECT * FROM languages')
lang$id <- str_sub(lang$id, 1, 2)
lang$full_name <- str_sub(lang$full_name,2, length(lang$full_name) - 1)


data <- left_join(data, lang, by = c('language_code' = "id"))



dbDisconnect(conn)

i <- 1
filtered_data <- list()
max <- length(unique(data$nationality)) * length(unique(data$language_code)) * length(unique(data$eu_party_code))

for (country in unique(data$nationality)) {
  for(lang_code in unique(data$language_code)) {
    for(eu_group in unique(data$eu_party_code)) {
      
      cat(sprintf('%s %0.2f%%  \n',i, i/max*100))
      cat(country, " ", lang_code, " ", eu_group, " ", "\n")
      
      id <- paste(country, lang_code, eu_group, sep = "_")     
      filtered_data[[i]] <- id
      
      titles <- data %>% 
        filter(nationality == country & language_code == lang_code & eu_party_code == eu_group) %>% 
        select(title)
      
      mep_name <- data %>% 
        filter(nationality == country & language_code == lang_code & eu_party_code == eu_group) %>% 
        select(name)
      
      national_party <- data %>% 
        filter(nationality == country & language_code == lang_code & eu_party_code == eu_group) %>% 
        select(national_party_full_name)
      
      date <- data %>% 
        filter(nationality == country & language_code == lang_code & eu_party_code == eu_group) %>% 
        select(date)
      
      filtered_data[[i]] <- list(title=unique(titles), name = unique(mep_name),
                                 national_party_full_name = unique(national_party), date = unique(date))
      names(filtered_data)[i] <- id
      i <- i + 1
    }
  }
}

save(filtered_data, file="./data/filter_options.Rda")

# options in filters:

start_options <- list(
  national_party = sort(unique(data$national_party_full_name)),
  eu_group = unique(data$eu_party_code),
  lang = lang,
  mep = sort(unique(data$name)),
  stm_title = sort(unique(data$title)),
  country = unique(data$nationality),
  date = list(
      date_min = min(data$date),
      date_max = max(data$date)
  )
)
save(start_options,file="./data/start_options.Rda")





