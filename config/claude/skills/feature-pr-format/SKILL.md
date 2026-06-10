---
name: feature-pr-format
description: Standardize a Feature PR (feature/* → main) so it stands out from development PRs in the PR list. Adds an English `[Feature]` prefix, rewrites the title in English, and replaces the body with a list of merged child PRs. Use when the user invokes /feature-pr-format, asks to "format a feature PR", "add [Feature] prefix", or complains that feature vs development PRs are hard to distinguish.
argument-hint: <PR_NUMBER or PR_URL>
---

# feature-pr-format

## What this skill does

Formats a GitHub Feature PR to a standardized shape so it stands out from development PRs:

- **Title**: prefixed with `[Feature]` and written entirely in English
- **Description**: replaced with a list of PRs that were merged into the feature branch, in `- #123` form (GitHub auto-expands these)

This addresses a specific pain point: Feature PRs (`feature/*` → `main`) and development PRs (`task-*` / other → `feature/*`) are hard to distinguish at a glance in the PR list.

## When to invoke

Trigger on any of:
- `/feature-pr-format <PR_NUMBER>`
- `/feature-pr-format <PR_URL>`
- The user asks to "format a feature PR", "add [Feature] prefix", or similar

The PR number is required. If the user didn't provide one, ask for it before proceeding.

## Workflow

Follow these steps in order. Do not skip the confirmation step — the user wants to see a diff before anything is pushed.

### 1. Fetch the PR

```bash
gh pr view <PR_NUMBER> --json number,title,body,headRefName,baseRefName,url
```

Capture:
- `headRefName` — the source branch
- `baseRefName` — the target branch
- `title` — current title
- `body` — current description (will be discarded)

### 2. Verify it's a Feature PR

A Feature PR satisfies **both**:
- `headRefName` starts with `feature/`
- `baseRefName` is `main`

If either condition fails, **ask the user to confirm** before proceeding. Show them what you found:

> This PR has head=`<branch>` and base=`<branch>`, which doesn't match the Feature PR pattern (`feature/*` → `main`). Do you still want to format it as a Feature PR?

Only proceed if they say yes.

### 3. Collect merged child PRs

Find PRs that were merged into this feature branch. The feature branch name is `headRefName` from step 1.

```bash
gh pr list --state merged --base <headRefName> --limit 200 --json number --jq 'sort_by(.number) | .[].number'
```

This returns PR numbers that targeted the feature branch and were merged. Sort ascending so the description reads chronologically.

If the list is empty, that's fine — the description just becomes empty or a short note. Ask the user if they want to proceed with an empty description or cancel.

### 4. Build the new title

Rules:
1. If the current title already starts with `[Feature]` (case-sensitive, exact), keep the prefix — only translate the rest if it contains non-English text.
2. Otherwise, add `[Feature] ` at the front.
3. The entire title (the part after `[Feature]`) must be in English. If the current title is in Japanese or any non-English language, translate it to natural, concise English that preserves the intent.

Examples:
- `ユーザー認証機能を追加` → `[Feature] Add user authentication`
- `Add user authentication` → `[Feature] Add user authentication`
- `[Feature] ユーザー認証機能を追加` → `[Feature] Add user authentication`
- `[Feature] Add user authentication` → `[Feature] Add user authentication` (no change)

Keep the translation faithful to the original. Don't invent scope that isn't there.

### 5. Build the new description

The description is exclusively a bulleted list of merged child PR numbers, one per line:

```
- #123
- #124
- #125
```

Do not add headings, preamble, or any other content. GitHub auto-expands `#NUMBER` into a link with the PR title, which is all the context needed.

If there are no merged child PRs, the description is an empty string (or a single line noting none — ask the user which they prefer when this happens).

### 6. Show the diff and ask for confirmation

Before calling `gh pr edit`, print a clear before/after so the user can review:

```
Title:
  - Before: <old title>
  - After:  <new title>

Description:
  - Before:
    <old body, indented — truncate if very long>
  - After:
    - #123
    - #124
```

Then ask explicitly: "Apply these changes to PR #<NUMBER>?" Wait for an affirmative response. If the user says no or requests edits, adjust and show the diff again.

### 7. Apply the changes

Once confirmed:

```bash
gh pr edit <PR_NUMBER> --title "<new_title>" --body "<new_body>"
```

For the body, use a heredoc to preserve newlines exactly:

```bash
gh pr edit <PR_NUMBER> --title "[Feature] Add user authentication" --body "$(cat <<'EOF'
- #123
- #124
- #125
EOF
)"
```

Confirm success by printing the PR URL from step 1.

## Edge cases

- **PR is closed/merged already**: Warn the user and ask whether to proceed. Editing a merged PR is allowed but usually not useful.
- **User is not authenticated with `gh`**: The first `gh` call will fail with an auth error — surface it and point the user at `gh auth login`.
- **Non-English title that's already prefixed**: Treat `[Feature]` as the prefix and translate only the remainder.
- **Title contains backticks, quotes, or shell metacharacters**: Always pass the title via `--title "..."` with proper quoting; prefer heredoc for the body.
- **Multiple merged PRs with the same number** (shouldn't happen, but): dedupe before emitting.

## Why each rule exists

- **English-only titles**: the team mixes Japanese and English in PR titles; standardizing to English for Feature PRs makes them scannable and consistent in the PR list.
- **`[Feature]` prefix**: a visual marker that survives truncation in GitHub's UI, so Feature PRs are obvious at a glance.
- **Description = just `- #N`**: GitHub auto-expands these into rich links. Any extra prose becomes stale as child PRs merge; the list is the only thing worth keeping.
- **Confirmation before edit**: `gh pr edit` is effectively irreversible for the body (the old text is gone). A diff step costs almost nothing and prevents lost context.
