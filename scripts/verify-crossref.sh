#!/usr/bin/env bash
# verify-crossref.sh — 驗證 references.bib 中每條 DOI 是否在 CrossRef 存在
# 用法：bash scripts/verify-crossref.sh [references.bib] [report.md]

set -u
BIB="${1:-references.bib}"
REPORT="${2:-verification-report.md}"
UA="bestseller-verify/1.0 (mailto:ppoiu87@gmail.com)"

if [[ ! -f "$BIB" ]]; then
  echo "找不到 $BIB" >&2
  exit 1
fi

# 用 Python 解析 .bib，輸出 citekey|doi 行
entries=$(python3 - "$BIB" <<'PY'
import re, sys
src = open(sys.argv[1]).read()
# 比對每個 @type{citekey, ... }
pattern = re.compile(r'@\w+\{\s*([^,\s]+)\s*,(.*?)(?=\n@|\Z)', re.DOTALL)
doi_re = re.compile(r'doi\s*=\s*\{([^}]+)\}', re.IGNORECASE)
for m in pattern.finditer(src):
    key = m.group(1).strip()
    body = m.group(2)
    d = doi_re.search(body)
    if d:
        print(f"{key}|{d.group(1).strip()}")
PY
)

if [[ -z "$entries" ]]; then
  echo "$BIB 沒有找到任何含 DOI 的條目" >&2
  exit 2
fi

pass=0
fail=0
total=0
failed_list=""

{
  echo "# CrossRef 驗證報告"
  echo ""
  echo "生成時間：$(date '+%Y-%m-%d %H:%M:%S')"
  echo ""
  echo "| 狀態 | citekey | DOI | 訊息 |"
  echo "|------|---------|-----|------|"
} > "$REPORT"

while IFS='|' read -r key doi; do
  [[ -z "$key" || -z "$doi" ]] && continue

  url="https://api.crossref.org/works/${doi}"
  response=$(curl -s -w "\nHTTP_CODE:%{http_code}" -H "User-Agent: $UA" "$url" < /dev/null)
  http_code=$(echo "$response" | tail -n1 | sed 's/HTTP_CODE://')
  body=$(echo "$response" | sed '$d')

  if [[ "$http_code" == "200" ]]; then
    info=$(echo "$body" | python3 -c "
import json, sys
d = json.load(sys.stdin)['message']
author = d.get('author', [{}])[0].get('family', '?')
year = (d.get('issued', {}).get('date-parts', [[None]])[0][0]) or '?'
title = (d.get('title', ['?'])[0] or '?')[:60]
print(f'{year} | {author} | {title}')
" 2>/dev/null || echo "parse error")
    echo "✓ $key  $info"
    # 跳脫 | 避免破壞表格
    info_md=$(echo "$info" | sed 's/|/\\|/g')
    echo "| ✓ | $key | $doi | $info_md |" >> "$REPORT"
    pass=$((pass + 1))
  else
    msg="HTTP $http_code"
    echo "✗ $key  $doi  $msg"
    echo "| ✗ | $key | $doi | $msg |" >> "$REPORT"
    fail=$((fail + 1))
    failed_list="${failed_list}${key} "
  fi
done <<< "$entries"

total=$((pass + fail))
{
  echo ""
  echo "## 統計"
  echo ""
  echo "- 總條目：${total}"
  echo "- 通過：${pass}"
  echo "- 失敗：${fail}"
  if [[ -n "$failed_list" ]]; then
    echo ""
    echo "## 失敗條目"
    echo ""
    echo "$failed_list" | tr ' ' '\n' | sed '/^$/d;s/^/- /'
  fi
} >> "$REPORT"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "總計 ${total}，通過 ${pass}，失敗 ${fail}"
echo "報告：${REPORT}"

[[ "${fail}" -eq 0 ]]
