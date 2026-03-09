# PK/PD Data Wrangling

가톨릭대학교 의학과 대학원 강의 "코딩을 활용한 PK/PD 자료처리 (Mpha508)"를 위한 Quarto 기반 교재 저장소입니다. R과 Quarto를 사용해 PK/PD 데이터를 처리하고, 피부과 및 자가면역질환 치료제를 예시로 약동학/약력학 분석 흐름을 학습할 수 있도록 구성되어 있습니다.

## 개요

- 교재 제목: 코딩을 활용한 PK/PD 자료처리
- 부제: R과 Claude Code를 활용한 피부과 약물의 약동학/약력학 데이터 분석
- 출력 형식: Quarto Book
- 저장소: <https://github.com/pipetcpt/pkpd-data-wrangling>
- 책 사이트: <https://pipetcpt.github.io/pkpd-data-wrangling>
- 정적 산출물 위치: `docs/`

## 저장소 구조

```text
.
├── _quarto.yml              # Quarto Book 설정
├── index.qmd                # 책 머리말
├── chapters/                # 본문 챕터
├── R/
│   ├── common_functions.R   # PK/PD 분석용 공통 함수
│   └── generate_datasets.R  # 실습용 시뮬레이션 데이터 생성
├── data/                    # 실습 데이터셋(csv)
├── docs/                    # 렌더링된 정적 사이트
├── references.bib           # 참고문헌
└── syllabus.txt             # 강의계획 요약
```

## 다루는 내용

- Part I: R 프로그래밍 기초
- Part II: PK 데이터 분석
- Part III: PK-PD 통합 분석

주요 예시 약물은 Methotrexate, Cyclosporine, Apremilast, Adalimumab, Dupilumab, Tofacitinib입니다.

## 챕터별 주요 내용

| 챕터 | 제목 | 주요 내용 |
|------|------|-----------|
| 1 | 서론: 과정 소개 및 환경 설정 | PK/PD 자료처리의 필요성, 재현 가능한 연구 워크플로우, R·Quarto·Claude Code 활용 환경 소개 |
| 2 | R 객체의 이해 | R 기본 데이터 타입, 벡터·리스트·데이터프레임 구조, PK 데이터에 맞는 객체 선택과 타입 변환 |
| 3 | R 객체 다루기 I: 기본 조작 | 파이프 연산자, dplyr 중심의 필터링·정렬·요약·그룹화, TDM 데이터 기초 처리 |
| 4 | R 객체 다루기 II: 고급 조작 및 데이터 변환 | `pivot_longer()`/`pivot_wider()`, join, 문자열 처리, 날짜/시간 처리, 결측·BLQ 처리 |
| 5 | 약동학 분석의 핵심 정보 | Cmax, Tmax, AUC, half-life 등 핵심 PK 파라미터와 NCA 원리, TDM 해석 |
| 6 | PK 데이터의 탐색적 분석 | 기술통계, IIV/IOV, 데이터 QC, 이상값 탐지, 농도-시간 그래프와 요약 테이블 작성 |
| 7 | 원시 데이터에서 분석용 데이터셋 구축 | SDTM/NONMEM 형식, EVID/MDV, 시간 변수 처리, BLQ 전략, 원시 데이터의 분석용 변환 |
| 8 | PK 데이터에서 약동학 정보 추출 | 사다리꼴 적분, lambda_z 추정, AUC 외삽, 부분 AUC, 생물학적 동등성, mAb PK 특성 |
| 9 | PK 데이터 분석 종합 실습 | QC-EDA-NCA-보고서 작성까지의 end-to-end 워크플로우, Quarto와 Git 기반 실전 분석 |
| 10 | PK-PD 분석의 핵심 개념과 관심사 | 직접/간접 효과, Emax와 Hill 모델, hysteresis, effect compartment, 피부과 PK-PD 사례 |
| 11 | 약력학 데이터 분석의 고려사항 | baseline 보정, placebo 효과, 결측 처리, PASI/EASI/IGA 등 PD endpoint 분석 전략 |
| 12 | PK-PD 통합 데이터셋 구축 | PK와 PD를 통합한 데이터 구조, CMT/DVID 설계, 시간 정렬, 통합 분석용 데이터셋 작성 |
| 13 | PK-PD 통합 정보 도출 | exposure-response 분석, sequential vs simultaneous 접근, 노출 지표와 임상 반응의 연결 |
| 14 | 공변량 탐색과 모델 반영 | 체중, 신기능, 면역원성 등 공변량 탐색, 시각화, 변수 선택, 모델 반영 전략 |
| 15 | PK-PD 데이터 시각화 | 규제 제출 수준의 PK/PD 그래프 설계, ggplot2 심화, colorblind-friendly 시각화, 보고용 figure 구성 |

## 강의 운영 및 일정

- 강의 시작: 2026년 3월 9일 월요일 18:00
- 진행 방식: Zoom 실시간 강의
- Zoom 링크: <https://us02web.zoom.us/j/9633893796?pwd=T3NxV3MzNjNOOTVYL3k1VUdialIxUT09>
- 회의 ID: `963 389 3796`
- 암호: `cmccpt`
- 녹화본: 각 강의 녹화 영상을 YouTube 재생목록에 업로드
- YouTube 재생목록: <https://youtube.com/playlist?list=PL0dzGMS9NqXVuoSEEN_FVqHYcM7PhgB7U&si=jIIPKp2FVBuWYtoL>
- 평가 방법: 과제 100%
- 과제 제출: 매 시간 배부되는 실습 과제의 결과를 다음 주 강의 시작 전까지 GitHub Discussion에 업로드
- 제출 저장소: <https://github.com/pipetcpt/pkpd-data-wrangling/discussions>
- 휴강: 2026년 4월 20일 월요일 18:00 (7주차, 학회 기간)
- 진행 원칙: 총 16주 운영, 휴강 1주 포함

| 주차 | 일시 | 내용 | 비고 |
|------|------|------|------|
| 1주차 | 2026-03-09 18:00 | Chapter 1. 서론: 과정 소개 및 환경 설정 | Zoom 실시간 |
| 2주차 | 2026-03-16 18:00 | Chapter 2. R 객체의 이해 | Zoom 실시간 |
| 3주차 | 2026-03-23 18:00 | Chapter 3. R 객체 다루기 I: 기본 조작 | Zoom 실시간 |
| 4주차 | 2026-03-30 18:00 | Chapter 4. R 객체 다루기 II: 고급 조작 및 데이터 변환 | Zoom 실시간 |
| 5주차 | 2026-04-06 18:00 | Chapter 5. 약동학 분석의 핵심 정보 | Zoom 실시간 |
| 6주차 | 2026-04-13 18:00 | Chapter 6. PK 데이터의 탐색적 분석 | Zoom 실시간 |
| 7주차 | 2026-04-20 18:00 | 휴강 | 학회 기간 |
| 8주차 | 2026-04-27 18:00 | Chapter 7. 원시 데이터에서 분석용 데이터셋 구축 | Zoom 실시간 |
| 9주차 | 2026-05-04 18:00 | Chapter 8. PK 데이터에서 약동학 정보 추출 | Zoom 실시간 |
| 10주차 | 2026-05-11 18:00 | Chapter 9. PK 데이터 분석 종합 실습 | Zoom 실시간 |
| 11주차 | 2026-05-18 18:00 | Chapter 10. PK-PD 분석의 핵심 개념과 관심사 | Zoom 실시간 |
| 12주차 | 2026-05-25 18:00 | Chapter 11. 약력학 데이터 분석의 고려사항 | Zoom 실시간 |
| 13주차 | 2026-06-01 18:00 | Chapter 12. PK-PD 통합 데이터셋 구축 | Zoom 실시간 |
| 14주차 | 2026-06-08 18:00 | Chapter 13. PK-PD 통합 정보 도출 | Zoom 실시간 |
| 15주차 | 2026-06-15 18:00 | Chapter 14. 공변량 탐색과 모델 반영 | Zoom 실시간 |
| 16주차 | 2026-06-22 18:00 | Chapter 15. PK-PD 데이터 시각화 | Zoom 실시간 |

## 요구 사항

- R
- Quarto
- R 패키지: `tidyverse`

## 사용 방법

### 1. 실습 데이터 생성

```bash
Rscript R/generate_datasets.R
```

### 2. 책 렌더링

```bash
quarto render
```

렌더링 결과는 `docs/` 디렉터리에 생성됩니다.

### 3. 로컬 미리보기

```bash
quarto preview
```

## 참고

- 메인 문서 진입점은 `index.qmd`입니다.
- 공통 분석 함수는 `R/common_functions.R`에 정리되어 있습니다.
- `docs/`는 GitHub Pages 등 정적 호스팅용 산출물로 사용할 수 있습니다.
