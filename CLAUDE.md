# PK/PD Data Wrangling Textbook

## Project Overview
- Quarto book project: "코딩을 활용한 PK/PD 자료처리"
- Author: 한성필
- Focus: 피부과 약물의 PK/PD 데이터 분석 (R + Claude Code)
- Language: Korean (lang: ko)

## Structure
- **Part I** (Ch01-04): R 프로그래밍 기초
- **Part II** (Ch05-09): PK 데이터 분석
- **Part III** (Ch10-15): PK-PD 통합 분석
- Output: `docs/` directory (HTML book, theme: cosmo)

## Key Files
- `_quarto.yml` - Book configuration
- `chapters/01-introduction.qmd` ~ `chapters/15-pkpd-plotting.qmd` - Chapter files
- `images/` - Generated figures (ch01_fig1.png ~ ch15_fig3.png, 45 total)
- `references.bib` - Bibliography

## Figures
- 45 PNG figures total (3 per chapter, ch01-ch15)
- Naming: `ch{NN}_fig{N}.png`
- Style: Educational infographic, teal/blue color scheme, "Key Concepts" box at bottom
- Generated via Gemini (nanobanana-mcp)

## Build
```bash
quarto render   # Build full book to docs/
quarto preview  # Live preview
```

## Conventions
- All chapter files in `chapters/` directory
- Figure references: `![caption](../images/chNN_figN.png)`
- Korean content with English technical terms
- Code blocks use R with tidyverse style
