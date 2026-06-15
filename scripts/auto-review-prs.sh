#!/usr/bin/env bash
# Auto PR Review: launchd から 45 分ごとに起動され、自分にレビュー依頼が来ている
# Open PR を claude -p でレビューし、レポートを各リポジトリの docs/pr-reviews/ に保存、
# Slack DM に通知する。
#
# 設計方針:
#   - レビューの中身だけを Claude に任せ、通知・冪等性・後片付けはシェルで決定的に制御する
#   - Slack 通知は Webhook ではなく、通知専用の claude -p (Slack MCP) 経由で行う
#   - レビュー済み判定は「本日分レポートファイルの有無」(日付が変わると再レビューされる仕様)
set -uo pipefail

# launchd はシェル rc を読まないため PATH を明示 (claude / gh / caffeinate)
export PATH="$HOME/.local/bin:/etc/profiles/per-user/shohei.ueda/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

REPOS=(meets-revent)
ORG="sansaninc"
WORKSPACE="$HOME/develop"
GITHUB_USER="shohei-ueda_sansan"
SLACK_CHANNEL="C0BA5AA7UMS"  # #times-uesho-private
REVIEW_MODEL="opus"
NOTIFY_MODEL="sonnet"
CLAUDE_BIN="$HOME/.local/bin/claude"

STATE_DIR="$HOME/.local/state/auto-review-prs"
LOG_DIR="$STATE_DIR/logs"
NOTIFIED_FILE="$STATE_DIR/notified.txt"
LOCK_DIR="$STATE_DIR/run.lock"
TODAY=$(date +%Y-%m-%d)
LOG_FILE="$LOG_DIR/auto_review_${TODAY}.log"

mkdir -p "$LOG_DIR"
touch "$NOTIFIED_FILE"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"; }

# --- 平日 7〜19 時のみ実行 ---
dow=$(date +%u)
hour=$((10#$(date +%H)))
if (( dow > 5 )) || (( hour < 7 )) || (( hour >= 19 )); then
  exit 0
fi

# --- 排他制御 (強制終了でロックが残ったら: rmdir "$LOCK_DIR") ---
if ! mkdir "$LOCK_DIR" 2>/dev/null; then
  log "Already running, skipping."
  exit 0
fi
trap 'rmdir "$LOCK_DIR"' EXIT

log "=== Auto Review start ==="

# Slack 通知: 通知専用の claude -p に「投稿だけ」させる
notify_slack() {
  local message="$1"
  "$CLAUDE_BIN" -p --permission-mode bypassPermissions --model "$NOTIFY_MODEL" >> "$LOG_FILE" 2>&1 <<EOF
ToolSearch ツールで 'slack send message' を検索して Slack 送信ツールをロードしてください。
MCP サーバーが接続中の場合は ToolSearch が接続を待ちます。見つからなければ数回リトライしてください。
その後、チャンネル $SLACK_CHANNEL に以下の <message> の内容をそのまま投稿してください。
投稿以外のツールは一切使わず、投稿できたら SENT、失敗したら FAILED: 理由 とだけ出力して終了してください。
<message>
$message
</message>
EOF
}

# macOS 通知: Slack MCP は「自分として」投稿するため Slack 通知が鳴らない。気づく手段はこちら。
# terminal-notifier を専用アプリ名義で発火させ、システム設定 > 通知 > terminal-notifier を
# 「通知方法: 通知パネル(Alert)」にしておくと、手動で閉じるまで消えずに残る。
notify_macos() {
  local title="$1" body="$2"
  if command -v terminal-notifier >/dev/null 2>&1; then
    terminal-notifier -title "$title" -message "$body" -sound Glass \
      -group "auto-review-prs" 2>>"$LOG_FILE"
  else
    # フォールバック: terminal-notifier 未導入時 (Alert 化は効かない)
    osascript -e "display notification \"${body//\"/\\\"}\" with title \"${title//\"/\\\"}\" sound name \"Glass\"" 2>>"$LOG_FILE"
  fi
}

completed=()   # 今回レビューが完了した PR (初回のみ通知)
reminders=()   # レポートが生成できていない未レビュー PR (毎回リマインド)

for repo in "${REPOS[@]}"; do
  repo_dir="$WORKSPACE/$repo"
  if [ ! -d "$repo_dir/.git" ]; then
    log "[$repo] clone が見つからないためスキップ: $repo_dir"
    continue
  fi
  report_dir="$repo_dir/docs/pr-reviews"
  mkdir -p "$report_dir"

  prs=$(gh pr list --repo "$ORG/$repo" --search "review-requested:$GITHUB_USER" --state open \
        --json number,title,url,labels \
        --jq '.[] | [(.number|tostring), .url, (if (.labels|length) == 0 then "-" else (.labels|map(.name)|join("|")) end), .title] | @tsv' 2>>"$LOG_FILE")

  if [ -z "$prs" ]; then
    log "[$repo] レビュー依頼中の PR なし"
  fi

  while IFS=$'\t' read -r num url labels title; do
    [ -z "${num:-}" ] && continue

    # チーム運用ルール: Feature ラベル (feature/* → main の集約 PR) はレビュー対象外
    if [[ "|${labels}|" == *"|Feature|"* ]]; then
      log "[$repo] PR #$num は Feature ラベルのためスキップ"
      continue
    fi

    # 自分が approve 済みならスキップ
    approved=$(gh pr view "$num" --repo "$ORG/$repo" --json reviews \
      --jq "[.reviews[] | select(.author.login == \"$GITHUB_USER\" and .state == \"APPROVED\")] | length" 2>>"$LOG_FILE")
    if [ "${approved:-0}" -gt 0 ]; then
      log "[$repo] PR #$num は approve 済みのためスキップ"
      continue
    fi

    report_file="$report_dir/pr-${num}-review-${TODAY}.md"

    if [ ! -f "$report_file" ]; then
      log "[$repo] PR #$num レビュー開始: $title"
      (
        cd "$repo_dir" && \
        caffeinate -i "$CLAUDE_BIN" -p --permission-mode bypassPermissions --model "$REVIEW_MODEL" <<EOF
Skill ツールで review_revent_pr スキルを実行し、そこに定義されたレビュー観点・手順・出力フォーマットに従って PR #$num をレビューしてください。
制約 (スキル定義と重複するが厳守):
- PR の内容と差分は gh pr view $num / gh pr diff $num で取得し、git checkout でブランチを切り替えないこと
- レビューレポートは必ずファイル docs/pr-reviews/pr-${num}-review-${TODAY}.md に保存すること (標準出力に表示するだけで終わらないこと)
- GitHub にコメントやレビューを投稿しないこと
- Slack などの通知ツールを一切呼ばないこと
EOF
      ) >> "$LOG_FILE" 2>&1
      if [ -f "$report_file" ]; then
        log "[$repo] PR #$num レビュー完了: $report_file"
      else
        log "[$repo] PR #$num レポート未生成 (次回再試行)"
      fi
    fi

    if [ -f "$report_file" ]; then
      if ! grep -qxF "${repo}#${num}" "$NOTIFIED_FILE"; then
        completed+=("✅ ${repo} #${num} ${title}
[PR を開く](${url}) / [レポートを Cursor で開く](cursor://file${report_file})")
        echo "${repo}#${num}" >> "$NOTIFIED_FILE"
      fi
    else
      reminders+=("⏳ ${repo} #${num} ${title}
[PR を開く](${url})")
    fi
  done <<< "$prs"

  # --- 後片付け: マージ/クローズ済み・approve 済み PR のレポートを削除 ---
  for f in "$report_dir"/pr-*-review-*.md; do
    [ -e "$f" ] || continue
    n=$(basename "$f" | sed -E 's/^pr-([0-9]+)-review-.*$/\1/')
    [[ "$n" =~ ^[0-9]+$ ]] || continue
    state=$(gh pr view "$n" --repo "$ORG/$repo" --json state --jq .state 2>/dev/null)
    [ -z "$state" ] && continue  # API 失敗時は消さない
    if [ "$state" != "OPEN" ]; then
      log "[$repo] PR #$n は $state のためレポート削除: $(basename "$f")"
      rm -f "$f"
      continue
    fi
    approved=$(gh pr view "$n" --repo "$ORG/$repo" --json reviews \
      --jq "[.reviews[] | select(.author.login == \"$GITHUB_USER\" and .state == \"APPROVED\")] | length" 2>/dev/null)
    if [ "${approved:-0}" -gt 0 ]; then
      log "[$repo] PR #$n は approve 済みのためレポート削除: $(basename "$f")"
      rm -f "$f"
    fi
  done
done

# --- Slack 通知 (通知する内容がある時だけ) ---
if [ ${#completed[@]} -gt 0 ] || [ ${#reminders[@]} -gt 0 ]; then
  msg="🤖 Auto PR Review ($(date '+%m/%d %H:%M'))"
  if [ ${#completed[@]} -gt 0 ]; then
    msg+=$'\n\n'"【レビュー完了】"
    for c in "${completed[@]}"; do msg+=$'\n'"$c"; done
  fi
  if [ ${#reminders[@]} -gt 0 ]; then
    msg+=$'\n\n'"【未レビュー (レポート未生成)】"
    for r in "${reminders[@]}"; do msg+=$'\n'"$r"; done
  fi
  notify_slack "$msg"
  notify_macos "Auto PR Review" "レビュー完了 ${#completed[@]} 件 / 未レビュー ${#reminders[@]} 件。詳細は #times-uesho-private へ"
  log "Slack + macOS 通知送信"
fi

log "=== Auto Review end ==="
