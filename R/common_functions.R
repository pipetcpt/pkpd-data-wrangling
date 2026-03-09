# common_functions.R
# PK/PD 자료처리 공통 함수 모음

# --- AUC 계산 ---

#' Linear trapezoidal AUC 계산
calc_auc_linear <- function(time, conc) {
  n <- length(time)
  if (n < 2) return(0)
  auc <- 0
  for (i in 2:n) {
    auc <- auc + (time[i] - time[i - 1]) * (conc[i] + conc[i - 1]) / 2
  }
  return(auc)
}

#' Log-linear trapezoidal AUC 계산
calc_auc_loglinear <- function(time, conc) {
  n <- length(time)
  if (n < 2) return(0)
  auc <- 0
  for (i in 2:n) {
    if (conc[i] == conc[i - 1] || conc[i] <= 0 || conc[i - 1] <= 0) {
      auc <- auc + (time[i] - time[i - 1]) * (conc[i] + conc[i - 1]) / 2
    } else {
      auc <- auc + (time[i] - time[i - 1]) * (conc[i] - conc[i - 1]) /
        (log(conc[i]) - log(conc[i - 1]))
    }
  }
  return(auc)
}

#' Linear-up/Log-down trapezoidal AUC 계산
calc_auc_linuplogdown <- function(time, conc) {
  n <- length(time)
  if (n < 2) return(0)
  auc <- 0
  for (i in 2:n) {
    dt <- time[i] - time[i - 1]
    if (conc[i] >= conc[i - 1] || conc[i] <= 0 || conc[i - 1] <= 0) {
      auc <- auc + dt * (conc[i] + conc[i - 1]) / 2
    } else {
      auc <- auc + dt * (conc[i] - conc[i - 1]) /
        (log(conc[i]) - log(conc[i - 1]))
    }
  }
  return(auc)
}

# --- 기술통계 ---

#' 기하평균 계산
geomean <- function(x, na.rm = TRUE) {
  if (na.rm) x <- x[!is.na(x)]
  x <- x[x > 0]
  exp(mean(log(x)))
}

#' 기하 CV% 계산
geocv <- function(x, na.rm = TRUE) {
  if (na.rm) x <- x[!is.na(x)]
  x <- x[x > 0]
  sqrt(exp(var(log(x))) - 1) * 100
}

# --- 신기능 ---

#' CKD-EPI eGFR 계산 (2021 공식)
calc_egfr <- function(scr, age, sex) {
  # sex: "M" or "F"
  kappa <- ifelse(sex == "F", 0.7, 0.9)
  alpha <- ifelse(sex == "F", -0.241, -0.302)
  female_factor <- ifelse(sex == "F", 1.012, 1.0)

  egfr <- 142 * pmin(scr / kappa, 1)^alpha *
    pmax(scr / kappa, 1)^(-1.200) *
    0.9938^age * female_factor

  return(egfr)
}

# --- BLQ 처리 ---

#' BLQ 데이터 처리
handle_blq <- function(conc, lloq, method = "M1") {
  switch(method,
    "M1" = ifelse(conc < lloq & !is.na(conc), 0, conc),
    "M3" = ifelse(conc < lloq & !is.na(conc), NA_real_, conc),
    "M5" = ifelse(conc < lloq & !is.na(conc), lloq / 2, conc),
    stop("Unknown BLQ method: ", method)
  )
}

# --- Baseline 보정 ---

#' Baseline 보정
correct_baseline <- function(value, baseline, method = "absolute") {
  switch(method,
    "absolute" = value - baseline,
    "percent"  = (value - baseline) / baseline * 100,
    "ratio"    = value / baseline,
    stop("Unknown correction method: ", method)
  )
}

# --- Emax 모델 ---

#' Emax 모델
emax_model <- function(conc, emax, ec50, gamma = 1, e0 = 0) {
  e0 + emax * conc^gamma / (ec50^gamma + conc^gamma)
}

# --- 단위 변환 ---

#' 농도 단위 변환
convert_conc <- function(conc, from, to, mw = NULL) {
  if (from == "ng/mL" && to == "mcg/L") return(conc)
  if (from == "mcg/mL" && to == "ng/mL") return(conc * 1000)
  if (from == "ng/mL" && to == "mcg/mL") return(conc / 1000)
  if (from == "mg/L" && to == "ng/mL") return(conc * 1000)
  if (!is.null(mw) && from == "ng/mL" && to == "nmol/L") return(conc / mw * 1000)
  stop("Unsupported conversion: ", from, " -> ", to)
}
