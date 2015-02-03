#
# (c) 2014 Georgios Gousios <gousiosg@gmail.com>
#
# BSD licensed, see LICENSE in top level dir
#
rm(list = ls(all = TRUE))
source('R/utils.R')
source('R/cmdline.R')

library(RMySQL)

enrich <- function(df) {
  df <- enrich.users(df)
  enrich.projects(df)
}

enrich.dataset <- function(df) {
  if(debug){printf("In enrich.projects")}
  df[,17] <- apply(df, 1, function(x){match.repo.sent.emails(x, 17, 100)})
  
  df$mean.prs.last.12.months <- apply(df, 1, function(x){mean.prs.last.12.months(x, 17)})
  df$project.size <-
    ordered(apply(df, 1, function(x){sizer(x, df, 17, 'mean.prs.last.12.months')}),
            levels=c("SMALL", "MEDIUM", "LARGE"))
  
  df$mean.integrators.last.12.months <- apply(df, 1, function(x){mean.integrators(x, 17)})
  df$project.integrator.size <-
    ordered(apply(df, 1, function(x){sizer(x, df, 17, 'mean.integrators.last.12.months')}),
            levels=c("SMALL", "MEDIUM", "LARGE"))
  
  df$has.community.prs <- 
    factor(apply(df, 1, function(x){has.community.prs.last.12.months(x, 17)}))

  df$was.in.orig.projects <- factor(apply(df, 1, function(x){was.in.orig.projects(x, 17)}))
  
  df
}

mean.integrators <- function(x, repo.field) {
  q <- "select count(distinct(prh.actor_id)) as integrators
        from pull_requests pr, pull_request_history prh, users u, projects p
        where pr.base_repo_id = p.id
        and prh.pull_request_id = pr.id
        and prh.action = 'closed'
        and prh.created_at > DATE_SUB(NOW(), INTERVAL 12 MONTH)
        and prh.created_at < DATE('2014/7/1/')
        and p.owner_id = u.id
        and u.login = '%s'
        and p.name = '%s'
        group by year(prh.created_at), month(prh.created_at);"
  results <- run.repo.query(q, owner.repo(x[repo.field]))
  if(debug){printf("num.integrators for %s: %s", x[repo.field], mean(results$integrators))}
  as.numeric(mean(results$integrators))
}

mean.prs.last.12.months <- function(x, repo.field) {
  q <- "select count(*) as num_pr
        from pull_requests pr, pull_request_history prh, users u, projects p
        where pr.base_repo_id = p.id
          and prh.pull_request_id = pr.id
          and prh.action = 'opened'
          and prh.created_at > DATE_SUB(NOW(), INTERVAL 12 MONTH)
          and prh.created_at < DATE('2014/7/1/')
          and p.owner_id = u.id
          and u.login = '%s'
          and p.name = '%s'
          group by year(prh.created_at), month(prh.created_at)"
  results <- run.repo.query(q, owner.repo(x[repo.field]))
  if(debug){printf("mean.prs.last.12.months for %s: %f", x[repo.field], mean(results$num_pr))}
  mean(results$num_pr)
}

has.community.prs.last.12.months <- function(x, repo.field) {
  q <- "select count(*) as community_prs
        from pull_requests pr, pull_request_history prh, project_members pm, 
          users u, projects p
        where prh.pull_request_id = pr.id
          and pr.base_repo_id = p.id
          and p.owner_id = u.id
          and pm.repo_id = pr.base_repo_id 
          and prh.actor_id = pm.user_id
          and prh.action = 'opened'
          and prh.created_at > pm.created_at
          and prh.created_at > DATE_SUB(NOW(), INTERVAL 12 MONTH)
          and prh.created_at < DATE('2014/7/1/')
          and u.login='%s'
          and p.name='%s'"
  
  results <- run.repo.query(q, owner.repo(x[repo.field]))
  if(debug){printf("has.community.prs.last.12.months for %s: %f", x[repo.field], 
                   results$community_prs > 0)}

  results$community_prs > 0   
}

sizer <- function(x, data, repo.field, size.field) {
  if(debug){printf("Running sizer (%s) for %s", size.field, x[repo.field])}
  mean.item <- subset(data, !is.na(data[,size.field]))[,size.field]
  divider <- floor(length(mean.item)/3)
  first.third <- sort(mean.item)[divider]
  second.third <- sort(mean.item)[divider + divider]
  mean.size.repo <- as.numeric(x[size.field])

  if(is.na(mean.size.repo)){
    NA
  } else if(mean.size.repo <= first.third) {
    "SMALL"
  } else if(mean.size.repo > first.third && mean.size.repo <= second.third) {
    "MEDIUM"
  } else {
    "LARGE"
  }
}

match.repo.sent.emails <- function(line, field.id.repo, field.id.email) {
  #if(debug){printf("Running get.repo.name for %s (%s)", line[field.id.repo], line[field.id.email])}
  if(trim(line[field.id.repo]) == "") {
    if (!exists('integrators.sent.to')) {
      printf("Reading integrator emails sent file")
      integrators.sent.to <<- read.csv(file.path(data.file.location, 'integrators-sent.csv'))
    }
  
    if (!exists('integrators.sent.to')) {
      ""
    } else {
      found <- subset(integrators.sent.to, email == line[field.id.email])
      if(nrow(found) != 0) {
        printf("Found repo %s for %s", found$repo, line[field.id.email])
        trim(found$repo)
      } else {
        ""
      }
    }
  } else {
    trim(line[field.id.repo])
  }
}

was.in.orig.projects <- function(x, repo.field) {
  nrow(subset(integrators.sent.to, repo == x[repo.field])) > 0
}

load.integrators.sent.to <- function() {
  if (!exists('integrators.sent.to')) {
    printf("Reading integrator emails sent file")
    integrators.sent.to <<- read.csv(file.path(data.file.location, 'integrators-sent.csv'))
  }
  integrators.sent.to
}

owner.repo <- function(x) {
  strsplit(trim(x), "/")
}

run.repo.query <- function(q, repo) {
  run.query(unwrap(sprintf(q, repo[[1]][1], repo[[1]][2])))
}

run.query <- function(q) {
  res <- dbSendQuery(con, unwrap(q))
  fetch(res, n = -1)
}

con <- dbConnect(dbDriver("MySQL"), user = mysql.user, password = mysql.passwd,
                 dbname = mysql.db, host = mysql.host)

integrators <- read.csv(file.path(data.file.location, "integrators.csv"), sep=",")
integrators <- enrich.dataset(integrators)

dimensions <- c('project.size', 'project.integrator.size', 'has.community.prs')

for(column in dimensions) {
  for(clevel in levels(integrators[, column])) {
    for(row in dimensions) {
      for(rlevel in levels(integrators[, row])) {
        printf("row: %s rlevel: %s and column: %s, clevel: %s -> %f", row, rlevel, column, clevel,
               (length(which(integrators[,row]== rlevel & integrators[,column] == clevel))/nrow(integrators)) * 100)
      }
    }
  }
}

write.csv(integrators, file = "integrators-enriched.csv")
