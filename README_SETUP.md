# Flutter PR Compliance Review Agent Setup

This setup runs two review layers:

1. **Qodo PR-Agent** for normal PR review/description.
2. **Flutter Compliance Review Agent** for strict standards enforcement against your team checklist.

The compliance review agent uses these files as the source of truth:

```text
best_practices.md
pr_compliance_checklist.yaml
```

## Files to add

Copy these files to your Flutter project:

```text
.github/workflows/flutter_pr_agent.yaml
.pr_agent.toml
best_practices.md
pr_compliance_checklist.yaml
scripts/flutter_pr_review.js
```

## GitHub secret required

Add this secret in GitHub:

```text
Repository → Settings → Secrets and variables → Actions → New repository secret

Name: OPENAI_KEY
Value: your OpenAI API key
```

Do not commit API keys into the repo.

## How the compliance review works

The agent operates in **strict compliance mode**. It evaluates every section in `pr_compliance_checklist.yaml` against the PR diff and `best_practices.md`.

The review runs in two phases:

1. **Phase 1 (priority):** `pr_compliance_checklist.yaml` — all 17 checklist sections
2. **Phase 2:** `best_practices.md` — General Product Engineering Practices (Sections A–E)

The posted PR comment starts with an **Evaluation Summary** table:

| Sr. | Section ID | Violations |
| ---: | --- | ---: |
| 1 | `title_description` | 0 |
| 2 | `state_management` | 2 |
| ... | ... | ... |

Then detailed per-section output includes:

1. **Violations Found** — every deviation from standards, with file names and line numbers when possible
2. **Suggested Fixes** — clear, actionable recommendations aligned with project standards
3. **Violation Count** — total violations detected in that section

Sections that do not apply to the PR changes show `N/A` in the summary table.

There is **no scoring**, grading, percentage-based evaluation, pass/fail rating, or weighted compliance score.

The compliance review is posted as a separate PR comment titled:

```text
Flutter PR Compliance Review
```

This review is independent from Qodo's native review output.

## Change control

The agent does **not** automatically modify code, generate commits, or apply fixes. It only reviews the PR, identifies violations, and provides recommendations.

## Important branch note

For PRs like:

```text
feature/my-branch → dev
```

The workflow file must be available in the base branch (`dev`) for GitHub Actions to run reliably.

Recommended:

1. Add this setup to `dev`.
2. Merge/rebase your feature branch from `dev`.
3. Push a new commit to the PR branch to re-run the checks.

## Manual re-run

After replacing the files on an already opened PR:

1. Push a small commit to the PR branch, or
2. Go to GitHub PR → Checks → Re-run all jobs.
