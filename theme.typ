// theme.typ — 內文與標題樣式
// A5 目標：每頁約 24 行（leading 0.80em）

#set text(lang: "zh", region: "tw")

#set par(
  first-line-indent: (amount: 2em, all: true),
  justify: true,
  leading: 0.80em,
  spacing: 1.0em,
)

#set heading(numbering: none)
#show heading: set block(sticky: true)

// 章（第一級）
#show heading.where(level: 1): it => {
  pagebreak(weak: true)
  v(3.5em)
  block(
    above: 0em,
    below: 1.8em,
    text(font: "GenRyuMin2 TW B", size: 22pt, it.body),
  )
}

// 節（第二級）
#show heading.where(level: 2): it => block(
  above: 1.8em,
  below: 1.0em,
  text(font: "GenRyuMin2 TW SB", size: 14pt, it.body),
)

// 小節（第三級）
#show heading.where(level: 3): it => block(
  above: 1.4em,
  below: 0.8em,
  text(font: "GenRyuMin2 TW SB", size: 12pt, it.body),
)

// 引文塊：左側細線
#show quote: it => block(
  inset: (left: 1em, rest: 0.4em),
  stroke: (left: 1.5pt + luma(60%)),
  text(style: "italic", it.body),
)

// 粗體映射到 B 字型
#show strong: it => text(font: "GenRyuMin2 TW B", it.body)

// 清單：短清單不跨頁
#set list(indent: 0.6em, body-indent: 0.5em, spacing: 0.7em, marker: ([•], [–]))
#set enum(indent: 0.6em, body-indent: 0.5em, spacing: 0.7em)
#show list: set block(breakable: false)
#show enum: set block(breakable: false)

// 參考文獻：APA 懸掛縮排 + 不 justify（避免 DOI/URL 硬斷字）
#show <refs>: it => {
  set par(first-line-indent: 0em, hanging-indent: 2em, justify: false)
  set block(spacing: 1em)
  it
}
