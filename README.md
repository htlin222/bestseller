# bestseller — 非虛構書籍模板（Quarto + Typst）

A5、明體（源流明體）、APA 引用、CrossRef 驗證、奇偶頁碼分側、跑動頁首的非虛構書籍生產線。受《Atomic Habits》排版語言啟發。

## 結構

```
cover.qmd           封面（獨立 PDF）
book.qmd            內頁主檔，include 章節
toc.qmd             目次（獨立 PDF，頁碼由 build-toc.py 從 book.pdf outline 抽取）
index.qmd           前言
01.qmd .. 15.qmd    各章
theme.typ           Typst 排版規則（字級、標題節奏、清單、引用塊）
_quarto.yml         Quarto 設定 + 字型 + 引用（bib + csl）
references.bib      BibTeX 文獻
apa.csl             APA 7th（已客製化移除 zh-TW locale 造成的多餘 (作者) 標籤）
chapters.yml        全書 15 章主清單（TOC 結構來源）
scripts/
  verify-crossref.sh   掃 references.bib 的 DOI 逐條打 CrossRef API 驗證
  build-toc.py         從 book.pdf outline + chapters.yml 生成 _toc-data.typ
```

## 快速上手

### 先備

```bash
brew install quarto typst
```

字型：下載 [源流明體 TW](https://github.com/ButTaiwan/genryu-font) 的 R / SB / B 三個字重到 `~/Library/Fonts/`，然後 `fc-cache -f`。

### 渲染

```bash
quarto render cover.qmd --to typst        # 封面 → _book/cover.pdf
quarto render book.qmd  --to typst        # 內頁 → _book/book.pdf
python3 scripts/build-toc.py              # 從 book.pdf outline 抽頁碼，寫 _toc-data.typ
quarto render toc.qmd   --to typst        # 目次 → _book/toc.pdf（頁碼保證和內頁一致）
```

TOC 一定要在 `book.pdf` render 之後跑。腳本會稽核對上幾章、對不上幾章，並輸出每章的實際頁碼。

### 驗證引用

```bash
bash scripts/verify-crossref.sh references.bib verification-report.md
```

所有條目都會打 CrossRef API 對照作者、年份、期刊、標題。輸出 Markdown 報告。

## 設計特徵

- **A5、9pt**、源流明體 R / SB / B，每頁約 27-30 行
- **奇偶頁碼分左右下角**（裝訂語法）
- **跑動頁首**：章名靠外側、章首頁隱藏
- **引用塊**左側細線、APA 參考文獻懸掛縮排、DOI 不硬斷行
- **分工原則**：排版全交 `theme.typ`、頁面全交 `book.qmd` 的 raw typst 區塊、章節檔只寫內容

## 寫作工作流（建議）

1. 寫章節 `.qmd`，引用用 `[@citekey]` 標記
2. 把 BibTeX 加到 `references.bib`
3. `quarto render book.qmd --to typst` 預覽
4. 章節寫完後 `bash scripts/verify-crossref.sh` 驗證所有 DOI
5. 失敗條目回頭修正 → 重渲染

## 客製化 CSL 註記

`apa.csl` 是 CSL 官方 APA 7th 的修改版：移除兩處會在 zh-TW locale 下渲染成「(作者)」的 `<label>` 元素。若要回到原版，去 [citation-style-language/styles](https://github.com/citation-style-language/styles) 下載 `apa.csl`。

## 授權

模板程式碼（`theme.typ`、`scripts/`、`_quarto.yml` 等）以 MIT 授權。文獻（`references.bib`）僅供示範用途。章節範例內容屬於《分子習慣》項目，若要用於其他書請替換。
