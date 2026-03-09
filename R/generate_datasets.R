# generate_datasets.R
# 시뮬레이션 기반 실습 데이터셋 생성
# 실행: Rscript R/generate_datasets.R

library(tidyverse)
set.seed(42)

# ============================================================
# 1. pk_methotrexate.csv
# Methotrexate 15mg SC weekly, 건선 환자 30명
# ============================================================

n_subj <- 30
doses <- 15  # mg SC

mtx_data <- map_dfr(1:n_subj, function(id) {
  # Individual PK parameters (1-compartment, first-order absorption)
  ka <- rlnorm(1, log(1.5), 0.3)    # 1/h
  ke <- rlnorm(1, log(0.15), 0.25)  # 1/h, t1/2 ~4.6h
  vd_f <- rlnorm(1, log(12), 0.3)   # L
  f <- runif(1, 0.7, 0.95)          # SC bioavailability

  wt <- rnorm(1, 70, 12)
  age <- round(rnorm(1, 45, 12))
  age <- max(20, min(age, 75))
  sex <- sample(c("M", "F"), 1)
  scr <- rlnorm(1, log(0.9), 0.15)
  bsa <- sqrt(wt * rnorm(1, 170, 8) / 3600)

  times <- c(0, 0.25, 0.5, 1, 1.5, 2, 3, 4, 6, 8, 12, 24)

  conc <- f * doses * 1000 / vd_f * ka / (ka - ke) *
    (exp(-ke * times) - exp(-ka * times))
  conc <- conc * exp(rnorm(length(times), 0, 0.1))  # residual error
  conc <- pmax(conc, 0)
  conc[1] <- 0

  tibble(
    ID = id, TIME = times, DV = round(conc, 2),
    AMT = ifelse(times == 0, doses, 0),
    EVID = ifelse(times == 0, 1, 0),
    MDV = ifelse(times == 0, 1, 0),
    CMT = 1,
    WT = round(wt, 1), AGE = age, SEX = sex,
    SCR = round(scr, 2), BSA = round(bsa, 2),
    DOSE = doses
  )
})

write_csv(mtx_data, "data/pk_methotrexate.csv")
cat("Created: data/pk_methotrexate.csv (", nrow(mtx_data), "rows)\n")

# ============================================================
# 2. pk_cyclosporine.csv
# Cyclosporine TDM 데이터, 아토피 피부염 환자 50명
# ============================================================

n_subj <- 50

csa_data <- map_dfr(1:n_subj, function(id) {
  dose_mg_kg <- sample(c(3, 4, 5), 1)
  wt <- rnorm(1, 68, 13)
  wt <- max(45, min(wt, 110))
  dose <- round(dose_mg_kg * wt / 25) * 25  # round to 25mg
  age <- round(rnorm(1, 38, 14))
  age <- max(18, min(age, 70))
  sex <- sample(c("M", "F"), 1)
  scr <- rlnorm(1, log(0.9), 0.15)

  # CYP3A4 inhibitor co-medication (0 = none, 1 = yes)
  cyp3a4_inh <- sample(0:1, 1, prob = c(0.7, 0.3))

  # PK parameters (2-compartment oral)
  cl_f <- rlnorm(1, log(25), 0.35) * (1 - 0.4 * cyp3a4_inh)  # L/h, reduced if inhibitor
  ka <- rlnorm(1, log(0.8), 0.3)
  vd_f <- rlnorm(1, log(150), 0.3)

  ke <- cl_f / vd_f

  # Multiple visits (C0 and C2 at baseline, 2wk, 4wk, 8wk)
  visits <- c(0, 2, 4, 8)  # weeks

  visit_data <- map_dfr(visits, function(v) {
    # Slight random variation between visits
    ke_v <- ke * rlnorm(1, 0, 0.1)

    # C0 (trough, 12h post-dose)
    c0 <- dose * 1000 / vd_f * ka / (ka - ke_v) *
      (exp(-ke_v * 12) - exp(-ka * 12)) *
      1 / (1 - exp(-ke_v * 12))  # steady-state
    c0 <- c0 * exp(rnorm(1, 0, 0.15))

    # C2 (2h post-dose)
    c2 <- dose * 1000 / vd_f * ka / (ka - ke_v) *
      (exp(-ke_v * 2) - exp(-ka * 2)) *
      1 / (1 - exp(-ke_v * 12))
    c2 <- c2 * exp(rnorm(1, 0, 0.15))

    tibble(
      VISIT_WEEK = v,
      C0 = round(max(c0, 10), 1),
      C2 = round(max(c2, 50), 1)
    )
  })

  visit_data %>%
    mutate(
      ID = id, DOSE = dose, DOSE_MG_KG = dose_mg_kg,
      WT = round(wt, 1), AGE = age, SEX = sex,
      SCR = round(scr, 2),
      CYP3A4_INH = cyp3a4_inh
    ) %>%
    select(ID, VISIT_WEEK, DOSE, DOSE_MG_KG, C0, C2,
           WT, AGE, SEX, SCR, CYP3A4_INH)
})

write_csv(csa_data, "data/pk_cyclosporine.csv")
cat("Created: data/pk_cyclosporine.csv (", nrow(csa_data), "rows)\n")

# ============================================================
# 3. pk_apremilast.csv
# Apremilast Phase I SAD/MAD, 건선 환자
# ============================================================

# SAD: 10mg, 20mg, 30mg, 40mg (n=6 per group)
# MAD: 20mg BID, 30mg BID (n=8 per group, 14 days)

sad_data <- map_dfr(1:4, function(grp) {
  dose <- c(10, 20, 30, 40)[grp]
  map_dfr(1:6, function(subj) {
    id <- (grp - 1) * 6 + subj

    ka <- rlnorm(1, log(2.0), 0.25)
    ke <- rlnorm(1, log(0.1), 0.2)  # t1/2 ~7h
    vd_f <- rlnorm(1, log(75), 0.25)

    wt <- rnorm(1, 72, 12)
    age <- round(rnorm(1, 42, 10))
    sex <- sample(c("M", "F"), 1)

    times <- c(0, 0.5, 1, 1.5, 2, 3, 4, 6, 8, 12, 24, 36, 48)

    conc <- dose * 1000 / vd_f * ka / (ka - ke) *
      (exp(-ke * times) - exp(-ka * times))
    conc <- conc * exp(rnorm(length(times), 0, 0.1))
    conc <- pmax(conc, 0)
    conc[1] <- 0

    tibble(
      ID = id, TIME = times, DV = round(conc, 2),
      AMT = ifelse(times == 0, dose, 0),
      EVID = ifelse(times == 0, 1, 0),
      MDV = ifelse(times == 0, 1, 0),
      DOSE = dose, STUDY = "SAD", DAY = 1,
      WT = round(wt, 1), AGE = age, SEX = sex
    )
  })
})

mad_data <- map_dfr(1:2, function(grp) {
  dose <- c(20, 30)[grp]
  map_dfr(1:8, function(subj) {
    id <- 24 + (grp - 1) * 8 + subj

    ka <- rlnorm(1, log(2.0), 0.25)
    ke <- rlnorm(1, log(0.1), 0.2)
    vd_f <- rlnorm(1, log(75), 0.25)

    wt <- rnorm(1, 72, 12)
    age <- round(rnorm(1, 42, 10))
    sex <- sample(c("M", "F"), 1)

    # Day 1 and Day 14 PK profiles
    map_dfr(c(1, 14), function(day) {
      day_times <- c(0, 0.5, 1, 1.5, 2, 3, 4, 6, 8, 12)
      abs_times <- (day - 1) * 24 + day_times

      # Steady state accumulation factor ~1.2 for BID
      acc <- ifelse(day == 14, 1.2, 1.0)

      conc <- acc * dose * 1000 / vd_f * ka / (ka - ke) *
        (exp(-ke * day_times) - exp(-ka * day_times))
      conc <- conc * exp(rnorm(length(day_times), 0, 0.1))
      conc <- pmax(conc, 0)
      conc[1] <- ifelse(day == 14, max(conc[1], runif(1, 5, 20)), 0)

      tibble(
        ID = id, TIME = abs_times, DV = round(conc, 2),
        AMT = ifelse(day_times == 0, dose, 0),
        EVID = ifelse(day_times == 0, 1, 0),
        MDV = ifelse(day_times == 0, 1, 0),
        DOSE = dose, STUDY = "MAD", DAY = day,
        WT = round(wt, 1), AGE = age, SEX = sex
      )
    })
  })
})

apremilast_data <- bind_rows(sad_data, mad_data)
write_csv(apremilast_data, "data/pk_apremilast.csv")
cat("Created: data/pk_apremilast.csv (", nrow(apremilast_data), "rows)\n")

# ============================================================
# 4. pk_adalimumab.csv
# Adalimumab 건선 Phase I, SC 투여
# ============================================================

n_per_group <- 8
doses_ada <- c(40, 80, 160)  # mg SC

ada_data <- map_dfr(seq_along(doses_ada), function(grp) {
  dose <- doses_ada[grp]
  map_dfr(1:n_per_group, function(subj) {
    id <- (grp - 1) * n_per_group + subj

    # mAb PK: 1-compartment with first-order absorption
    ka <- rlnorm(1, log(0.01), 0.3)     # 1/day, slow SC absorption
    cl <- rlnorm(1, log(0.012), 0.3)    # L/day
    vd <- rlnorm(1, log(8), 0.2)        # L
    f <- runif(1, 0.55, 0.72)           # SC bioavailability

    wt <- rnorm(1, 80, 15)
    wt <- max(50, min(wt, 130))
    age <- round(rnorm(1, 45, 12))
    sex <- sample(c("M", "F"), 1)
    # ADA status: develops over time
    ada_status <- sample(c(0, 1), 1, prob = c(0.74, 0.26))

    # Increase CL if ADA positive
    if (ada_status == 1) cl <- cl * runif(1, 1.3, 2.0)

    ke <- cl / vd

    # Sampling times for mAb (days)
    times <- c(0, 1, 2, 4, 7, 10, 14, 21, 28, 42, 56, 70, 84)

    conc <- f * dose * 1000 / vd * ka / (ka - ke) *
      (exp(-ke * times) - exp(-ka * times))
    conc <- conc * exp(rnorm(length(times), 0, 0.12))
    conc <- pmax(conc, 0)
    conc[1] <- 0

    tibble(
      ID = id, TIME_DAY = times, DV = round(conc, 2),
      AMT = ifelse(times == 0, dose, 0),
      DOSE = dose,
      WT = round(wt, 1), AGE = age, SEX = sex,
      ADA = ada_status,
      ALBUMIN = round(rnorm(1, 4.0, 0.4), 1)
    )
  })
})

write_csv(ada_data, "data/pk_adalimumab.csv")
cat("Created: data/pk_adalimumab.csv (", nrow(ada_data), "rows)\n")

# ============================================================
# 5. pkpd_dupilumab.csv
# Dupilumab PK + EASI score, 아토피 피부염
# ============================================================

n_subj <- 40  # 20 per dose group

dupi_data <- map_dfr(1:n_subj, function(id) {
  dose <- ifelse(id <= 20, 300, 600)  # 300mg vs 600mg loading then 300mg q2w

  # PK parameters
  ka <- rlnorm(1, log(0.008), 0.25)   # 1/day
  cl <- rlnorm(1, log(0.008), 0.3)    # L/day
  vd <- rlnorm(1, log(5), 0.2)        # L
  f <- runif(1, 0.55, 0.70)

  wt <- rnorm(1, 75, 14)
  wt <- max(50, min(wt, 120))
  age <- round(rnorm(1, 38, 13))
  age <- max(18, min(age, 70))
  sex <- sample(c("M", "F"), 1)
  baseline_easi <- rnorm(1, 28, 8)
  baseline_easi <- max(16, min(baseline_easi, 50))
  baseline_iga <- sample(3:4, 1, prob = c(0.4, 0.6))

  ke <- cl / vd

  # PK sampling: predose at each visit (q2w for 16 weeks)
  pk_visits <- seq(0, 112, by = 14)  # days

  # Simplified steady-state trough calculation
  pk_conc <- map_dbl(pk_visits, function(t) {
    if (t == 0) return(0)
    n_doses <- floor(t / 14)
    conc_ss <- f * dose * 1000 / vd * ka / (ka - ke) *
      (exp(-ke * 14) - exp(-ka * 14)) /
      (1 - exp(-ke * 14))
    conc_ss <- conc_ss * (1 - exp(-ke * t)) / (1 - exp(-ke * 14))
    conc_ss * exp(rnorm(1, 0, 0.15))
  })
  pk_conc <- pmax(pk_conc, 0)

  # PD: EASI score decreasing over time (indirect response)
  easi_scores <- map_dbl(pk_visits, function(t) {
    # Emax model for EASI reduction
    emax_reduction <- 0.85  # max 85% reduction
    ec50 <- 100  # mcg/mL (Ctrough)
    gamma <- 1.5

    avg_conc <- mean(pk_conc[pk_visits <= t & pk_visits > 0])
    if (is.nan(avg_conc) || t == 0) avg_conc <- 0

    reduction <- emax_reduction * avg_conc^gamma / (ec50^gamma + avg_conc^gamma)
    easi <- baseline_easi * (1 - reduction) + rnorm(1, 0, 2)
    max(0, round(easi, 1))
  })

  # IGA at each visit
  iga_scores <- map_int(seq_along(pk_visits), function(i) {
    if (i == 1) return(as.integer(baseline_iga))
    easi_ratio <- easi_scores[i] / baseline_easi
    if (easi_ratio < 0.1) return(0L)
    if (easi_ratio < 0.25) return(1L)
    if (easi_ratio < 0.5) return(2L)
    if (easi_ratio < 0.75) return(3L)
    return(4L)
  })

  tibble(
    ID = id, TIME_DAY = pk_visits, WEEK = pk_visits / 7,
    DOSE = dose,
    CTROUGH = round(pk_conc, 2),
    EASI = easi_scores,
    IGA = iga_scores,
    WT = round(wt, 1), AGE = age, SEX = sex,
    BASELINE_EASI = round(baseline_easi, 1),
    BASELINE_IGA = baseline_iga
  )
})

write_csv(dupi_data, "data/pkpd_dupilumab.csv")
cat("Created: data/pkpd_dupilumab.csv (", nrow(dupi_data), "rows)\n")

# ============================================================
# 6. pkpd_tofacitinib.csv
# Tofacitinib PK + SCORAD, 아토피 피부염
# ============================================================

n_subj <- 40  # 20 per dose group

tofa_data <- map_dfr(1:n_subj, function(id) {
  dose <- ifelse(id <= 20, 5, 10)  # 5mg vs 10mg BID

  # PK parameters
  ka <- rlnorm(1, log(3.0), 0.25)    # 1/h, rapid absorption
  cl_f <- rlnorm(1, log(30), 0.3)    # L/h
  vd_f <- rlnorm(1, log(100), 0.25)  # L

  wt <- rnorm(1, 70, 13)
  wt <- max(45, min(wt, 110))
  age <- round(rnorm(1, 35, 12))
  age <- max(18, min(age, 65))
  sex <- sample(c("M", "F"), 1)
  scr <- rlnorm(1, log(0.9), 0.12)
  baseline_scorad <- rnorm(1, 55, 12)
  baseline_scorad <- max(25, min(baseline_scorad, 83))
  baseline_lymph <- rnorm(1, 2.0, 0.5)  # x10^9/L
  baseline_lymph <- max(1.0, min(baseline_lymph, 3.5))

  ke <- cl_f / vd_f

  # Visits: baseline, 2wk, 4wk, 8wk, 12wk
  visit_weeks <- c(0, 2, 4, 8, 12)
  visit_days <- visit_weeks * 7

  # PK: Cavg at steady state
  cavg <- map_dbl(visit_weeks, function(w) {
    if (w == 0) return(0)
    # Cavg = F * Dose / (CL/F * tau), tau = 12h for BID
    cavg_ss <- dose * 1000 / (cl_f * 12)
    cavg_ss * exp(rnorm(1, 0, 0.15))
  })

  # PD: SCORAD reduction
  scorad <- map_dbl(seq_along(visit_weeks), function(i) {
    if (i == 1) return(baseline_scorad)
    emax_red <- 0.70
    ec50 <- 30  # ng/mL
    reduction <- emax_red * cavg[i] / (ec50 + cavg[i])
    s <- baseline_scorad * (1 - reduction) + rnorm(1, 0, 3)
    max(0, round(s, 1))
  })

  # Safety: Lymphocyte count (dose-dependent decrease)
  lymph <- map_dbl(seq_along(visit_weeks), function(i) {
    if (i == 1) return(baseline_lymph)
    decrease <- 0.15 * dose / 10 * (1 - exp(-0.3 * visit_weeks[i]))
    l <- baseline_lymph * (1 - decrease) + rnorm(1, 0, 0.15)
    max(0.3, round(l, 2))
  })

  tibble(
    ID = id, VISIT_WEEK = visit_weeks, TIME_DAY = visit_days,
    DOSE = dose,
    CAVG = round(cavg, 2),
    SCORAD = scorad,
    LYMPHOCYTE = lymph,
    WT = round(wt, 1), AGE = age, SEX = sex,
    SCR = round(scr, 2),
    BASELINE_SCORAD = round(baseline_scorad, 1),
    BASELINE_LYMPH = round(baseline_lymph, 2)
  )
})

write_csv(tofa_data, "data/pkpd_tofacitinib.csv")
cat("Created: data/pkpd_tofacitinib.csv (", nrow(tofa_data), "rows)\n")

cat("\nAll datasets generated successfully!\n")
