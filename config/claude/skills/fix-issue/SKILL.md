---
name: fix-issue
description: Triage and resolve PR review comments one by one - fetch all unresolved comments from a GitHub pull request, recommend how to handle each, apply fixes in focused commits, and reply to each thread with the commit SHA or a rationale for declining. Use this whenever the user wants to "address PR comments", "respond to review feedback", "fix review comments", "handle PR feedback", "go through PR comments", or mentions resolving unresolved threads on a specific PR (by number, URL, or "current branch"). Also use when the user pastes a PR URL and asks to process its feedback, or says things like "check my PR and deal with the comments".
---

# fix-issue

Walk through the unresolved comments on a pull request and either implement the suggested change or reply with a reason for not doing so. Each accepted change is committed separately (or grouped with clearly related ones) and the bot replies to the original comment thread with the resulting SHA so the reviewer can verify the fix.

## When to run this

The user says things like:
- "Fix the comments on this PR" / "Address the review feedback"
- "Go through the PR comments on #123"
- "Deal with the review on my current branch"
- Shares a PR URL and asks to process the feedback

## High-level workflow

1. **Identify the PR** (current branch or explicit argument).
2. **Fetch comments** (review comments + issue comments), filter out the user's own, filter out already-resolved threads.
3. **Triage each comment with a recommendation** — Claude proposes "address / decline / ask for clarification" with reasoning, user confirms.
4. **For each approved fix**: implement → test/lint where it makes sense → commit → reply to the thread with the SHA.
5. **For each decline**: reply with a polite, specific rationale.
6. **Summarize** at the end: what was committed, what was declined, what is still open.

Keep the user in control. Never push commits, never mark threads resolved without asking, never reply on the user's behalf without confirming the wording.

## Step 1: Identify the PR

```bash
# Default: PR for the current branch
gh pr view --json number,url,headRefName,baseRefName,author
```

If the user passed a PR number or URL, use that instead:
```bash
gh pr view <number-or-url> --json number,url,headRefName,baseRefName,author
```

Confirm briefly: "Working on PR #123 (branch `feature/x` → `main`). Proceeding to fetch comments." — then move on; no need to ask for approval for the PR identification itself.

If there is no PR for the current branch and no argument was given, stop and ask the user which PR to target.

## Step 2: Fetch comments

There are two comment surfaces on a PR:

**A. Review comments** (attached to code lines, part of a review thread)
```bash
gh api "repos/{owner}/{repo}/pulls/<PR_NUMBER>/comments" --paginate
```

**B. Issue comments** (general PR-level conversation)
```bash
gh api "repos/{owner}/{repo}/issues/<PR_NUMBER>/comments" --paginate
```

For **resolved-thread detection** on review comments, use GraphQL — REST doesn't expose `isResolved`:
```bash
gh api graphql -f query='
query($owner:String!, $repo:String!, $number:Int!) {
  repository(owner:$owner, name:$repo) {
    pullRequest(number:$number) {
      reviewThreads(first:100) {
        nodes {
          id
          isResolved
          isOutdated
          comments(first:50) {
            nodes { id databaseId author{login} body path line diffHunk createdAt }
          }
        }
      }
    }
  }
}' -F owner=<owner> -F repo=<repo> -F number=<PR_NUMBER>
```

### Filtering rules

Drop a comment if any of these apply:
- Author login equals the PR author / current user (get via `gh api user --jq .login`). The user explicitly does not want to process their own comments.
- The thread's `isResolved` is true.
- The comment is from a bot and contains no actionable request (CI status posts, Dependabot notifications, etc.) — but keep bot code-review comments (CodeRabbit, Copilot, etc.) since those are the whole point.

After filtering, present a short numbered list to the user:
```
Found 4 unresolved comments to address:
  1. [review] app/api/src/foo.ts:42 — @reviewer: "This should handle null"
  2. [review] app/api/src/foo.ts:88 — @reviewer: "Extract this into a helper"
  3. [issue] @reviewer: "Can we add a test for the error path?"
  4. [review] app/web/src/bar.tsx:15 — @bot: "Unused import"
```

## Step 3: Triage each comment

Go through them one at a time. For each, **read the surrounding code first** so the recommendation is grounded, then present to the user:

```
[2/4] app/api/src/foo.ts:88 — @reviewer
> "This block is getting long — extract into a helper?"

Recommendation: ADDRESS. The function is 40+ lines and the extracted
logic has a clear name (`normalizeInput`). Low risk, improves readability.

Plan: pull lines 88-112 into `normalizeInput()` in the same file.

Proceed? (y / n / skip / explain more)
```

Recommendation categories:
- **ADDRESS** — worth doing, plan included
- **DECLINE** — disagree with the suggestion; propose a reply explaining why
- **CLARIFY** — ambiguous; propose a reply asking the reviewer for more detail
- **DEFER** — valid but out of scope for this PR; propose a reply suggesting a follow-up issue

Be honest in recommendations. If a reviewer is wrong, say so and draft a respectful rebuttal — don't default to agreeing.

### Grouping related comments

If comments 2 and 5 are essentially the same request, or the fix for one naturally includes the other, say so at the triage step: "I recommend handling 2 and 5 together in one commit because they're both about the same validation path." The user decides.

## Step 4: Apply fixes

For each approved ADDRESS:

1. **Make the change.** Read the file(s), edit, and re-read to confirm.
2. **Run relevant checks** where quick and obvious — type check, lint, or the narrowest test file touching the change. Don't run the full test suite for every comment; use judgment. If a change has no test coverage and adding one is trivial, offer.
3. **Stage only the files that belong to this fix** (`git add <specific files>`, not `git add -A`).
4. **Commit with a focused message.** Reference the comment thread in the body, not the subject. Follow the repo's existing style (check `git log --oneline -20`). Example body line: `Addresses review comment from @reviewer on PR #123.`
5. **Capture the SHA**: `COMMIT_SHA=$(git rev-parse HEAD)`.

Do NOT push. The user pushes when they're ready.

## Step 5: Reply to the thread

Replies default to English (the user's preference) unless the original comment thread is clearly in another language — in that case, match it.

### Reply templates

**Address** (with SHA):
```
Addressed in <SHORT_SHA>. <One sentence explaining what changed.>
```

**Decline**:
```
Thanks for the suggestion — I'd like to keep this as is. <Specific reason, 1-2 sentences. Acknowledge the tradeoff.>
```

**Clarify**:
```
Could you clarify — <specific question>? I want to make sure I understand before changing this.
```

**Defer**:
```
Good point, but I'd prefer to handle this in a follow-up to keep this PR focused. I'll open an issue to track it.
```

Always show the user the drafted reply before sending. Offer a quick edit pass.

### Posting the reply

**Review comment (threaded reply)** — use the `replies` endpoint on the root comment of the thread:
```bash
gh api "repos/{owner}/{repo}/pulls/<PR_NUMBER>/comments/<ROOT_COMMENT_ID>/replies" \
  -f body="<reply text>"
```
`ROOT_COMMENT_ID` is the `databaseId` of the first comment in the thread (from the GraphQL response above).

**Issue comment (non-threaded)** — just post a new issue comment referencing the original:
```bash
gh api "repos/{owner}/{repo}/issues/<PR_NUMBER>/comments" \
  -f body="@<reviewer> <reply text>"
```

## Step 6: Final summary

Print a recap so the user can sanity-check before pushing:

```
PR #123 — fix pass complete

Committed (3):
  - abc1234  Handle null input in foo.ts           (comments 1, 5)
  - def5678  Extract normalizeInput helper          (comment 2)
  - 9012abc  Add test for error path                (comment 3)

Declined (1):
  - comment 4 (@bot) — replied explaining the import is required

Still open (0)

Next: review the commits, then `git push` when ready.
```

## Guardrails

- **Never push.** The user decides when to push.
- **Never resolve threads automatically.** GitHub's "Resolve conversation" is a reviewer signal — let the reviewer close it after they see the reply.
- **Never mark a conversation resolved on the user's behalf** (no `resolveReviewThread` GraphQL mutation).
- **Never reply without showing the draft first.**
- **Never bundle unrelated changes into one commit** just to reduce commit count. If in doubt, split.
- **Never use `git commit --amend`** to roll a comment fix into an earlier commit — each addressed comment should be its own commit (or a clearly-scoped group), so the reviewer can map reply → commit 1:1.

## Edge cases

- **Reviewer comment on code that no longer exists** (outdated thread): mention this in the triage — usually safe to reply briefly noting the code was removed/moved and link to the relevant commit.
- **Long threads with back-and-forth**: read the entire thread before recommending. The reviewer may have already softened or withdrawn the request later in the thread.
- **Suggestion blocks** (the GitHub ```suggestion syntax): these are the easiest to address — apply the diff exactly, commit, reply with the SHA.
- **Comment asks for a rename across the codebase**: one commit is fine if the change is mechanical (search/replace). Still run the lint/type checks before committing.
- **No write access to post comments**: gh will return a 403. Surface this to the user clearly rather than silently failing.
