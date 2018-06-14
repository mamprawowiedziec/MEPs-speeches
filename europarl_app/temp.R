db <- dbConnect(MySQL(),dbname = 'epdebate_dev',
                user = 'epdebate',
                password = 'slB8EBtmRsuiRbo6',
                host = '10.1.93.2',
                encoding = 'utf-8')


dbSendQuery(db,"SET NAMES 'utf8';")

country <- c('Poland', 'Austria')


sql <- "SELECT id , name, nationality, link FROM deputies
LEFT JOIN term_of_office 
ON deputies.id = term_of_office.deputies_id 
WHERE term_of_office.term = 8 
AND deputies.nationality IN ('"

sql2 <- paste0("SELECT stm_all.*, eu_party_code.id as eu_party_code FROM
(SELECT statements.*, mep.name, mep.nationality, mep.link as mep_link  FROM 
(SELECT id , name, nationality, link FROM deputies
LEFT JOIN term_of_office 
ON deputies.id = term_of_office.deputies_id 
WHERE term_of_office.term = ?term AND deputies.nationality IN ('",paste(country, collapse = "','") ,"')) mep
INNER JOIN statements 
ON statements.deputies_id = mep.id) stm_dep")

query <- paste0(sql, paste(country, collapse = "','"), "');") 

query <- sqlInterpolate(db, sql2, term = 8)

tmp <- dbGetQuery(db, query)
unique(tmp$nationality)



sql_full <- paste0("SELECT stm.*, national_party.full_name as national_party_full_name FROM (
	SELECT stm_all.*, eu_party_code.id as eu_party_code FROM
(SELECT stm_dep.*, eu_group.full_name as eu_group_full_name FROM
(SELECT statements.*, mep.name, mep.nationality, mep.link as mep_link  FROM 
(SELECT id , name, nationality, link FROM deputies
LEFT JOIN term_of_office 
ON deputies.id = term_of_office.deputies_id 
WHERE term_of_office.term = ?term AND deputies.nationality IN ('", paste(country, collapse = "','") , "')
AND deputies.name IN ('", paste(mep_names, collapse = "','") , "')) mep
RIGHT JOIN statements 
ON statements.deputies_id = mep.id) stm_dep
LEFT JOIN 
(SELECT `date_beginning`, IF(`date_end` IS NULL, '2100-01-01', `date_end`) as data_end, 
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
WHERE national_party.date_beginning <= stm.date AND national_party.data_end >= stm.date")



country <- 'Sweden'
mep_names <- sort(dbGetQuery(db, "SELECT name FROM deputies  LEFT JOIN term_of_office 
    ON deputies.id = term_of_office.deputies_id 
    WHERE term_of_office.term = 8")$name)
mep_names <- str_replace_all(mep_names, "'", "''")

eu_group <- sort(dbGetQuery(db, "SELECT id FROM eu_party_code;")$id)

national_party <- start_options$national_party
national_party <- str_replace_all(national_party, "'", "''")
titles <- start_options$stm_title
titles <- str_replace_all(titles, "'", "''")

date_start <- start_options$date$date_min
date_end <- start_options$date$date_max

language_code <- lang$id

term = 8
sql <- paste0("SELECT stm.*, national_party.full_name as national_party_full_name FROM (
SELECT stm_dep.*, eu_group.full_name as eu_group_full_name,  eu_group.id as eu_group_id FROM
(SELECT statements.*, mep.name, mep.nationality, mep.link as mep_link  FROM 
  (SELECT id , name, nationality, link FROM deputies
    LEFT JOIN term_of_office 
    ON deputies.id = term_of_office.deputies_id 
    WHERE term_of_office.term = ", term , "
    AND (deputies.nationality IN ('", paste(country, collapse = "','") , "'))
    AND (deputies.name IN ('", paste(mep_names, collapse = "','") , "')) ) mep
  INNER JOIN statements 
  ON statements.deputies_id = mep.id) stm_dep
LEFT JOIN 
(SELECT `date_beginning`, IF(`date_end` IS NULL, '2100-01-01', `date_end`) as date_end, 
`deputies_id`, eu_party_code.*
FROM `eu_party` 
LEFT JOIN eu_party_code
ON eu_party.full_name = eu_party_code.full_name 
WHERE eu_party_code.id IN ('", paste(eu_group, collapse = "','") , " ')) eu_group 
ON eu_group.deputies_id = stm_dep.deputies_id 
WHERE eu_group.date_beginning <= stm_dep.date AND eu_group.date_end >= stm_dep.date) stm
LEFT JOIN 
(SELECT `date_beginning`,  IF(`date_end` IS NULL, '2100-01-01', `date_end`) as data_end, 
`deputies_id`, `full_name`
FROM `national_party` 
WHERE national_party.full_name IN ('", paste(national_party, collapse = "','") , " ') ) national_party 
ON national_party.deputies_id = stm.deputies_id 
WHERE national_party.date_beginning <= stm.date AND national_party.data_end >= stm.date 
              AND stm.title IN ('", paste(titles, collapse = "','") , " ')
              AND stm.language_code IN ('", paste(language_code, collapse = "','") , " ') 
              AND stm.date >='", date_start, "' AND stm.date <= '", date_end, "' ;")




t <- dbGetQuery(db, 'SELECT * FROM eu_party_code;')


tmp <- dbGetQuery(db, sql)


sql2 <- paste0("
  SELECT stm_dep.*, eu_group.full_name as eu_group_full_name,  eu_group.id as eu_group_id FROM
  (SELECT statements.*, mep.name, mep.nationality, mep.link as mep_link  FROM 
    (SELECT id , name, nationality, link FROM deputies
      LEFT JOIN term_of_office 
      ON deputies.id = term_of_office.deputies_id 
      WHERE term_of_office.term = ", term , "
      AND (deputies.nationality IN ('", paste(country, collapse = "','") , "'))
      AND (deputies.name IN ('", paste(mep_names, collapse = "','") , "')) ) mep
    INNER JOIN statements 
    ON statements.deputies_id = mep.id) stm_dep
  LEFT JOIN 
  (SELECT `date_beginning`, IF(`date_end` IS NULL, '2100-01-01', `date_end`) as date_end, 
    `deputies_id`, eu_party_code.*
      FROM `eu_party` 
    LEFT JOIN eu_party_code
    ON eu_party.full_name = eu_party_code.full_name 
    WHERE eu_party_code.id IN ('", paste(eu_group, collapse = "','") , " ')) eu_group 
  ON eu_group.deputies_id = stm_dep.deputies_id 
  WHERE eu_group.date_beginning <= stm_dep.date AND eu_group.date_end >= stm_dep.date;")

tmp <- dbGetQuery(db, sql2)

statements_table_2 <- statements_table_2 %>% 
  mutate(id = paste(`Deputy id`, Date, Debate, sep='_'))
colnames(statements_table_3)[5] <- 'id'

error <- anti_join( tmp, statements_table_3, by="id")



