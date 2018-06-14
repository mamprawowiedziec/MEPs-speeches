


data <- data.frame(
  
  MEP = cleanLink(data$name),
  Country = data$nationality,
  language_code = data$language_code
  
)



deputies <- data[,c("Country", "MEP",
                   "language_code")]
deputies$MEP <- cleanLink(deputies$MEP)

temp$Freq <- 1
colnames(temp) <- c("language_code", "Country", 'Freq')

# totals <- temp %>%
#   group_by(Country) %>%
#   summarize(total = n())
# 
# totals <- totals[order(-totals$total),]

temp <- deputies %>% 
  group_by(language_full_name) %>% 
  count()

lim <- c(0, max(temp$n) + 500)
p <- ggplot(temp,aes(x =reorder(temp$language_full_name, temp$n), y = temp$n)) +   geom_bar(stat = "identity", fill = 'dodgerblue3') +
  geom_text(aes(language_full_name, n + 150, label = n), data = temp) +
  scale_y_continuous(expand = c(0, 0),limits = lim) + 
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"),
        axis.text.x = element_text(angle = 0, hjust = 1 ),
        axis.text.y = element_text(size=10)) + 
  ylab("Number of statements") +
  xlab("Language") +
  coord_flip() + 


