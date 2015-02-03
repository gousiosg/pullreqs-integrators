#
# (c) 2014 -- onwards Georgios Gousios <gousiosg@gmail.com>
#
# BSD licensed, see LICENSE in top level dir
#

#
# Loads the integrators.csv file, renames columns to abbreviated names
# Stores results in the `integrators` workspace variable
#

require(plyr)

integrators <- read.csv(file.path(data.file.location, "integrators-enriched.csv"))

column.mappings <- c(
"Which.of.the.following.best.describes.your.role." = "Q1",
"Which.of.the.following.best.describes.your.role....Other..please.specify." = "Q1.other",
"How.many.years.have.you.been.programming" = "Q2",
"How.many.years.have.you.worked.on.projects.that.are.developed.in.a.geographically.distributed.manner." = "Q3",
"How.many.years.have.you.worked.on.projects.that.are.developed.in.a.geographically.distributed.manner....Other..please.specify." = "Q3.other",
"How.many.years.have.you.been.working.in.Open.Source.projects" = "Q4",
"You.work.for" = "Q5",
"Which.project.repository.do.you.mainly.handle.pull.requests.for..e.g..rails.rails.....Open.Ended.Response" = "Q6",
"Is.working.on.this.repository.your.day.job." = "Q7",
"How.many.pull.requests.have.you.handled.during.the.last.month.for.your.repository." = "Q8",
"In.my.project..developers.use.pull.requests.for...Soliciting.contributions.from.external.parties" = "Q9.A1",
"In.my.project..developers.use.pull.requests.for...Reviewing.code" = "Q9.A2",
"In.my.project..developers.use.pull.requests.for...Discussing.new.features.before.those.are.implemented" = "Q9.A3",
"In.my.project..developers.use.pull.requests.for...Distributing.work.and.tracking.progress" = "Q9.A4",
"In.my.project..developers.use.pull.requests.for...Issue.fixes" = "Q9.A5",
"In.my.project..developers.use.pull.requests.for...Other..please.specify."= "Q9.other",
"In.my.project..developers.use.pull.requests.between.branches.in.the.central.repo" = "Q10",
"How.often.do.the.following.types.of.pull.requests.occur.in.your.project....New.features" = "Q11.A1",
"How.often.do.the.following.types.of.pull.requests.occur.in.your.project....Bug.fixes" = "Q11.A2",
"How.often.do.the.following.types.of.pull.requests.occur.in.your.project....Refactorings..excluding.changes.required.for.the.above." = "Q11.A3",
"To.merge.pull.requests.I....Use.Github.facilities..the.merge.button." = "Q12.A1",
"To.merge.pull.requests.I....Pull.the.proposed.branch.locally..merge.it.with.a.project.branch.and.then.push" = "Q12.A2",
"To.merge.pull.requests.I....Squash.the.commits.of.the.proposed.branch..merge.it.with.a.project.branch.and.then.push" = "Q12.A3",
"To.merge.pull.requests.I....Create.a.textual.patch.from.the.remote.branch..apply.this.to.a.project.branch.and.then.push" = "Q12.A4",
"To.merge.pull.requests.I....Other..please.specify." = "Q12.other",
"Please.rate.the.importance.that.the.following.factors.play.in.the.DECISION.TO.ACCEPT.OR.REJECT.a.pull.request.....Existence.of.tests..in.the.pull.request." = "Q13.A1",
"Please.rate.the.importance.that.the.following.factors.play.in.the.DECISION.TO.ACCEPT.OR.REJECT.a.pull.request.....Number.of.commits" = "Q13.A2",
"Please.rate.the.importance.that.the.following.factors.play.in.the.DECISION.TO.ACCEPT.OR.REJECT.a.pull.request.....Number.of.changed.lines" = "Q13.A3",
"Please.rate.the.importance.that.the.following.factors.play.in.the.DECISION.TO.ACCEPT.OR.REJECT.a.pull.request.....Number.of.discussion.comments" = "Q13.A4",
"Please.rate.the.importance.that.the.following.factors.play.in.the.DECISION.TO.ACCEPT.OR.REJECT.a.pull.request.....Pull.requester.track.record" = "Q13.A5",
"Please.rate.the.importance.that.the.following.factors.play.in.the.DECISION.TO.ACCEPT.OR.REJECT.a.pull.request.....Pull.request.affects.hot.project.area" = "Q13.A6",
"In.your.experience..what.other.factors.affect.the.decision.to.accept.or.reject.a.pull.request....Open.Ended.Response" = "Q14",
"Please.rate.the.importance.of.the.following.factors.to.the.TIME.TO.MERGE.a.pull.request...Existence.of.tests..in.the.pull.request." = "Q15.A1",
"Please.rate.the.importance.of.the.following.factors.to.the.TIME.TO.MERGE.a.pull.request...Existence.of.tests..in.the.project." = "Q15.A2",
"Please.rate.the.importance.of.the.following.factors.to.the.TIME.TO.MERGE.a.pull.request...Number.of.commits" = "Q15.A3",
"Please.rate.the.importance.of.the.following.factors.to.the.TIME.TO.MERGE.a.pull.request...Number.of.changed.lines" = "Q15.A4",
"Please.rate.the.importance.of.the.following.factors.to.the.TIME.TO.MERGE.a.pull.request...Number.of.discussion.comments" = "Q15.A5",
"Please.rate.the.importance.of.the.following.factors.to.the.TIME.TO.MERGE.a.pull.request...Pull.requester.track.record" = "Q15.A6",
"Please.rate.the.importance.of.the.following.factors.to.the.TIME.TO.MERGE.a.pull.request...Pull.request.affects.hot.project.area" = "Q15.A7",
"In.your.experience..what.other.factors.affect.the.time.to.merge.a.pull.request....Open.Ended.Response" = "Q16",
"In.your.experience..what.are.the.3.most.common.reasons.for.REJECTING.a.pull.request....The.pull.request.conflicts.with.another.pull.request.or.branch" = "Q17.A1",
"In.your.experience..what.are.the.3.most.common.reasons.for.REJECTING.a.pull.request....A.new.pull.request.solves.the.problem.better" = "Q17.A2",
"In.your.experience..what.are.the.3.most.common.reasons.for.REJECTING.a.pull.request....The.pull.request.implements.functionality.that.already.exists.in.the.project" = "Q17.A3",
"In.your.experience..what.are.the.3.most.common.reasons.for.REJECTING.a.pull.request....Examination.of.the.proposed.feature.bug.fix.has.been.deferred" = "Q17.A4",
"In.your.experience..what.are.the.3.most.common.reasons.for.REJECTING.a.pull.request....Tests.failed.to.run.on.the.pull.request" = "Q17.A5",
"In.your.experience..what.are.the.3.most.common.reasons.for.REJECTING.a.pull.request....The.implemented.feature.contains.technical.errors.or.is.of.low.quality" = "Q17.A6",
"In.your.experience..what.are.the.3.most.common.reasons.for.REJECTING.a.pull.request....The.pull.request.does.not.follow.project.conventions..style." = "Q17.A7",
"In.your.experience..what.are.the.3.most.common.reasons.for.REJECTING.a.pull.request....Other..please.specify." = "Q17.other",
"Rejection.of.pull.requests.might.lead.to.problems.with.the.project.community..Have.you.ever.experienced.such.problems.and.if.yes.how.did.you.deal.with.them....Open.Ended.Response" = "Q18",
"What.heuristics.do.you.use.when.prioritizing.pull.requests.for.merging....Open.Ended.Response" = "Q19",
"Imagine.you.frequently.have.more.than.50.pull.requests.in.your.inbox..How.do.you.triage.them....I.delegate.to.devs.more.experienced.with.the.specific.subsystem" = "Q20.A1",
"Imagine.you.frequently.have.more.than.50.pull.requests.in.your.inbox..How.do.you.triage.them....I.process.them.serially" = "Q20.A2",
"Imagine.you.frequently.have.more.than.50.pull.requests.in.your.inbox..How.do.you.triage.them....I.just.discard.very.old.pull.requests" = "Q20.A3",
"Imagine.you.frequently.have.more.than.50.pull.requests.in.your.inbox..How.do.you.triage.them....I.discard.too.discussed...controversial.pull.requests" = "Q20.A4",
"Imagine.you.frequently.have.more.than.50.pull.requests.in.your.inbox..How.do.you.triage.them....I.trust.pull.requests.from.reputed.pull.requesters" = "Q20.A5",
"Imagine.you.frequently.have.more.than.50.pull.requests.in.your.inbox..How.do.you.triage.them....I.assess.the.technical.quality.of.the.pull.request" = "Q20.A6",
"Imagine.you.frequently.have.more.than.50.pull.requests.in.your.inbox..How.do.you.triage.them....Other..please.specify."  = "Q20.other",
"How.do.you.do.code.reviews....I.review.code.in.all.pull.requests" = "Q21.A1",
"How.do.you.do.code.reviews....I.delegate.reviewing.to.more.suitable.code.reviewers"  = "Q21.A2",
"How.do.you.do.code.reviews....I.use.inline.code.comments.in.pull.requests"  = "Q21.A3",
"How.do.you.do.code.reviews....I.only.review.code.in.commits"  = "Q21.A4",
"How.do.you.do.code.reviews....Code.review.is.obligatory.for.a.pull.request.to.be.merged"  = "Q21.A5",
"How.do.you.do.code.reviews....The.community.participates.in.code.reviews"  = "Q21.A5",
"How.do.you.do.code.reviews....Other..please.specify."  = "Q21.other",
"What.heuristics.do.you.use.for.assessing.the.quality.of.pull.requests....Open.Ended.Response" = "Q22",
"What.tools.do.you.use.to.assess.the.quality.of.pull.requests....Continuous.integration..i.e...via.Travis..Jenkins..Cloudbees." = "Q23.A1",
"What.tools.do.you.use.to.assess.the.quality.of.pull.requests....Manual.test.execution" = "Q23.A2",
"What.tools.do.you.use.to.assess.the.quality.of.pull.requests....Code.quality.metrics..i.e..via.Code.Climate.or.Sonar." = "Q23.A3",
"What.tools.do.you.use.to.assess.the.quality.of.pull.requests....Coverage.metrics" = "Q23.A4",
"What.tools.do.you.use.to.assess.the.quality.of.pull.requests....Formal.code.inspections.from.specialized.testers" = "Q23.A5",
"What.tools.do.you.use.to.assess.the.quality.of.pull.requests....Other..please.specify." = "Q23.other",
"What.is.your.work.style.when.dealing.with.pull.requests....I.insist.on.pull.requests.being.split.per.feature" = "Q24.A1",
"What.is.your.work.style.when.dealing.with.pull.requests....I.merge.pull.requests.fast.to.ensure.project.flow" = "Q24.A2",
"What.is.your.work.style.when.dealing.with.pull.requests....I.prefer.pull.requests.to.be.tied.to.an.open.issue" = "Q24.A3",
"What.is.your.work.style.when.dealing.with.pull.requests....I.am.pedantic.when.enforcing.code.and.documentation.style" = "Q24.A4",
"What.is.your.work.style.when.dealing.with.pull.requests....I.ask.for.more.work.as.a.result.of.a.discussion" = "Q24.A5",
"What.is.your.work.style.when.dealing.with.pull.requests....I.close.pull.requests.fast.in.case.of.unresponsive.developers" = "Q24.A6",
"What.is.your.work.style.when.dealing.with.pull.requests....I.try.to.restrict.discussion.to.a.few.comments" = "Q24.A7",
"What.is.your.work.style.when.dealing.with.pull.requests....I.try.to.avoid.discussion" = "Q24.A8",
"How.do.you.communicate.with.the.project.s.contributors.on.potential.contributions....Email" = "Q25.A1",
"How.do.you.communicate.with.the.project.s.contributors.on.potential.contributions....Issue.tracking..I.expect.contributors.to.open.an.issue.describing.the.problem.and.the.potential.fix" = "Q25.A2",
"How.do.you.communicate.with.the.project.s.contributors.on.potential.contributions....Pull.request..I.expect.contributors.to.open.a.minimal.pull.request.describing.the.problem.and.the.potential.fix"  = "Q25.A3",
"How.do.you.communicate.with.the.project.s.contributors.on.potential.contributions....IRC" = "Q25.A4",
"How.do.you.communicate.with.the.project.s.contributors.on.potential.contributions....Twitter" = "Q25.A5",
"How.do.you.communicate.with.the.project.s.contributors.on.potential.contributions....Skype.Hangouts.Other.form.of.synchronous.communication" = "Q25.A6",
"How.do.you.communicate.with.the.project.s.contributors.on.potential.contributions....I.prefer.not.to.communicate"  = "Q25.A7",
"How.do.you.communicate.with.the.project.s.contributors.on.potential.contributions....Other..please.specify."  = "Q25.other",
"What.is.the.biggest.challenge..if.any..you.face.while.managing.contributions.through.pull.requests....Open.Ended.Response" = "Q26",
"What.kind.of.tools.would.you.expect.research.to.provide.you.with.in.order.to.assist.you.with.handling.pull.requests.for.you.project....Open.Ended.Response" = "Q27",
"Your.Github.Id..This.will.help.us.cross.check.your.replies.with.our.dataset..This.will.not.be.part.of.the.public.dataset.we.will.release....Open.Ended.Response" = "githubid",
"Would.you.like.to.be.notified.when.the.questionnaire.results.have.been.processed..If.yes..please.fill.in.your.email.below....Open.Ended.Response" = "email",
"Would.you.be.available.for.a.30.min.interview.over.Skype.or.Google.Hangouts..We..ll.use.the.email.you.filled.in.above.to.contact.you..We.are.offering.a..20.gift.certificate.on.Amazon.to.every.person.we.interview." = "Q30"
)

integrators <- rename(integrators, column.mappings)
integrators <- subset(integrators, Q6 != '')
integrators <<- subset(integrators, !is.na(project.size))
