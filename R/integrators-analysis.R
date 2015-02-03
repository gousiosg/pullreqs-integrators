#
# (c) 2014 Georgios Gousios <gousiosg@gmail.com>
#
# BSD licensed, see LICENSE in top level dir
#

rm(list = ls(all = TRUE))
source('R/utils.R')
source('R/cmdline.R')

source('R/integrators-loader.R')
source('R/survey-analysis.R')

### Demographics
library(klaR)

store.pdf(plot.pie(integrators, "Q1", 'Developer Roles', 
                   levels = c("Project owner or co-owner",
                              "Source code contributor", 
                              "Translator",
                              "Documentation contributor",
                              "Other (please specify)")), 
          "q1.pdf")

store.pdf(plot.pie(integrators, "Q2", 'Developer Experience \n(years)',
                   levels = c("< 1", "1 - 2", "3 - 6", "7 - 10", "10+")),
          "q2.pdf")

store.pdf(plot.pie(integrators, "Q3", 'Developer Experience \n(distributed software development, years)',
                   levels = c("< 1", "1 - 2", "3 - 6", "7 - 10", "10+")),
          "q3.pdf")

store.pdf(plot.pie(integrators, "Q4", 'Developer Experience \n(open source software, years)',
                   levels = c("Never", "< 1", "1 - 2", "3 - 6", "7 - 10", "10+")),
          "q4.pdf")

store.pdf(plot.pie(integrators, "Q5", 'Developers work for',
                   levels = c("The industry", "The academia", 
                              "The government", "Open Source Software")
),
"q5.pdf")

store.pdf(plot.pie(integrators, "Q7", 'Working exclusively on repository',
                   levels = c("No", "Yes")), "q7.pdf")

cl <- kmodes(integrators[, c('Q1', 'Q2', 'Q5')], 3)
print(cl$modes)

nrow(subset(integrators, Q1 == "Project owner or co-owner" & Q5 == "The industry" & (Q2 == "10+" | Q2 == "7 - 10")))
nrow(subset(integrators, Q1 == "Project owner or co-owner" & Q5 == "The industry" & (Q2 == "10+" | Q2 == "7 - 10") & Q7 == "Yes"))
nrow(subset(integrators, Q1 == "Source code contributor" & Q5 == "The academia" ))

#
printf("%f of respondents not in original project list", 
       nrow(subset(integrators, was.in.orig.projects == F))/nrow(integrators))



### RQ1
# RQ1.1
store.pdf(plot.multi.choice(integrators, "Q9", 
                            "Why do you use pull requests for in your project?"),
          "q9.pdf")

store.pdf(plot.likert.data(integrators, "Q11", 
                           c("Non existent", "Once per month", 
                             "Once per week", "Daily"),
                           "How often do the following types of pull requests occur in your project?"), 
          "q11.pdf")

store.pdf(plot.likert.data(data = integrators, 
                           question = "Q11", 
                           order = c("Non existent", "Once per month", 
                                     "Once per week", "Daily"),
                           title = "How often do the following types of pull requests occur in your project?",
                           group.by = "project.size"), 
          "q11-per-pr-size.pdf")

store.pdf(plot.likert.data(integrators, "Q24", 
                           c("Never", "Occasionally", "Often", "Always"),
                           "Q24: What is your work style when dealing with pull requests?"), 
          "q24.pdf")

store.pdf(plot.likert.data(integrators, "Q24", 
                           c("Never", "Occasionally", "Often", "Always"),
                           "Q24: What is your work style when dealing with pull requests?",
                           group.by = "project.size"), 
          "q24-per-pr-size.pdf")

store.pdf(plot.likert.data(integrators, "Q24", 
                           c("Never", "Occasionally", "Often", "Always"),
                           "Q24: What is your work style when dealing with pull requests?",
                           group.by = "project.integrator.size"), 
          "q24-per-int-team-size.pdf")

# RQ1.2 Merging habbits

store.pdf(plot.likert.data(integrators, 
                           question = "Q12", 
                           order = c("Never", "Occasionally", "Often", "Always"),
                           title = "To merge pull requests integrators:"),
          "q12.pdf")

store.pdf(plot.likert.data(integrators, 
                           question = "Q12", 
                           order = c("Never", "Occasionally", "Often", "Always"),
                           title = "To merge pull requests integrators:",
                           group.by = "project.size"),
          "q12-per-pr-size.pdf")

store.pdf(plot.likert.data(integrators, 
                           question = "Q12", 
                           order = c("Never", "Occasionally", "Often", "Always"),
                           title = "To merge pull requests integrators:",
                           group.by = "project.integrator.size"),
          "q12-per-int-team-size.pdf")

# RQ1.3 Code reviews
store.pdf(plot.multi.choice(integrators, "Q21", 
                            "Q21: How do you do code reviews?"), "q21.pdf")

### Analysis: Q9
printf("Projects with no community pull requests and saying that they have recieved no PR: %f",
       nrow(subset(integrators, Q9.A1 == '' & has.community.prs == F)) / nrow(subset(integrators, Q9.A1 == '')))

printf("Projects with no community pull requests and believing that they have recieved a PR: %f",
       nrow(subset(integrators, Q9.A1 != '' & has.community.prs == F)) / nrow(subset(integrators, Q9.A1 != '')))

### Analysis: Q9

### Analysis: Q21

unique(subset(integrators, Q21.A1 == "" & Q21.A5 == "" & Q21.other == "")$Q6)
unique(subset(integrators, Q21.A4 != "" )$Q6)
subset(integrators, Q21.other == "We use a weekly google hangout that is open to the public to discuss the open pull requests.")$X
subset(integrators, Q21.other == "we use the 'pirate rule'. At least one other contributor needs to back the PR by stating it's 'ok for him.")$X
subset(integrators, Q21.other == "gihub does not have good sign off. garret systems seem to work better.")$X
subset(integrators, Q21.other == "4 eye principle for non trivial code")$X
subset(integrators, Q21.other == "The more eyes that see the code, the better.")$X

### RQ2
# 1. Produce list of common projects in the ICSE 2014 and this study
# The repos used in the ICSE 2014 study
projects.icse2014 <- read.csv(file.path(data.file.location, 'projects-icse2014.csv'))
pnames.icse2014 <- apply(projects.icse2014, 1, function(x){sprintf("%s/%s", x[1],x[2])})

# Common repos between the ICSE 2014 study and the survey results
common.projects <- intersect(as.vector(subset(integrators, Q6 != "")$Q6),
                             as.vector(pnames.icse2014))

printf("%f of the projects in the previous study answered to this survey",
       length(common.projects) / nrow(projects.icse2014))

#to.save <- data.frame(owner=unlist(Map(function(x){owner.repo(x)[1]}, common.projects)),
#                      repo=unlist(Map(function(x){owner.repo(x)[2]}, common.projects)))

#write.table(to.save, row.names = F, col.names = F, quote = F,
#            file=file.path(data.file.location, 'common-icse-survey.txt'))

# 2. Load the results of Q13, Q14, Q15 and Q16
store.pdf(plot.likert.data(integrators,
                           question = "Q13",
                           order    = c("Not Important", "Mildly Important",
                                        "Quite Important", "Very Important"),
                           title    = "Importance of factors to the decision to accept a pull request"),
          "q13.pdf")

store.pdf(plot.likert.data(integrators,
                           question = "Q15",
                           order    = c("Not Important", "Mildly Important",
                                        "Relatively Important", "Very Important"),
                           title    = "Importance of factors to the time to make the decision to accept a pull request"),
          "q15.pdf")

store.pdf(plot.multi.choice(integrators, "Q17",
                            "Top reasons for rejecting a pull request"),
          "q17.pdf")

q14 <- load.data.file('int-q14-coded.csv')
q16 <- load.data.file('int-q16-coded.csv')

store.pdf(plot.tag.freq(data = q14,
                        filter = c("", "none", "accept all",
                                   "contributor origin", "automated testing",
                                   "open issue"),
                        title = "factors affecting pull request acceptance"), 'q14-tag-freq.pdf')
store.pdf(plot.tag.freq(data = q16,
                        filter = c("", "none", "intent", "tz", "age"),
                        title = "factors affecting the time to decide on a pull request"),
          'q16-tag-freq.pdf')

# 3. Analysis
printf("Answers to Q14: %d (%f)", nrow(subset(integrators, Q14 != "" )), (nrow(subset(integrators, Q14 != "" )) / nrow(integrators)))

q16.merge.q7 <- merge(integrators, q16, by.x = 'X', by.y = 'id')[,c('X','Q7','tag1', 'tag2', 'tag3')]

store.pdf(plot.tag.freq(data = q16.merge.q7,
                        filter = c("", "none", "intent", "tz", "age"),
                        title = "factors affecting pull request acceptance",
                        group.by = "Q7"),
          'q16-tag-freq-no-full-time.pdf')



printf("Answers to Q16: %d (%f)", nrow(subset(integrators, Q16 != "" )), (nrow(subset(integrators, Q16 != "" )) / nrow(integrators)))

### RQ3

q22 <- load.data.file('int-q22-coded.csv')

store.pdf(plot.tag.freq(data = q22, 
                        filter = c("", "none", "accept all", 
                                   "ticket", "distance to HEAD", "security"),
                        title = "factors developers examine when assessing quality"), 'q22-tag-freq.pdf')

store.pdf(plot.multi.choice(integrators, "Q23", 
                            "Tools used for assising pull request quality"), "q23.pdf")

nrow(subset(integrators, Q23.A4 == ""))

### RQ4

q19 <- load.data.file('int-q19-coded.csv')

store.pdf(plot.tag.freq(data = q19, 
                        filter = c("", "none", "accept all", "no prioritization",
                                   "contributor responsiveness" , "adherence to process",
                                   "backward compatibility", "easy ones first"),
                        title = "factors developers examine when prioritizing"), 'q19-tag-freq.pdf')

store.pdf(plot.likert.data(integrators, 
                           question = "Q20",
                           order    = c("Never", "Occasionally", "Often", "Always"),
                           title    = "How do you triage pull requests?"),
          "q20.pdf")

store.pdf(plot.alluvial(q19), "q19-alluvial.pdf")

### RQ5
q26 <- load.data.file('int-q26-coded.csv')

store.pdf(plot.tag.freq(data = q26, 
                        filter = c("", "none","love"),
                        title = "biggest challenge with pull requests"), 'q26-tag-freq.pdf')
