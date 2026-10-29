# GRN Agent Kit

Personal Codex skills and the small scripts needed to back them up or restore them.

## Included Skills

- `grn-commit-squash`
- `grn-header-first-review`
- `grn-implementation-thinning`
- `grn-locality-first-review`
- `grn-project-checkpoints`

Skills live in `skills/`. Each directory is copied as a complete Agent Skill bundle, including `SKILL.md`, UI metadata, references, and scripts when present.

## Review Sequence

The three review skills intentionally operate at different levels:

1. `grn-locality-first-review` reviews large-scale ownership, boundaries, dependencies, and abstraction choices, while reporting directly evidenced functional defects in a separate result.
2. `grn-header-first-review` reviews each header as an API contract before reading its implementation.
3. `grn-implementation-thinning` removes unnecessary implementation machinery after the structure and API are accepted.

Do not combine all three passes into one cleanup. A finding that changes ownership returns to the structural pass, and a finding that changes a public contract returns to the header-first pass.

The structural pass does not equate locality with short-term minimalism. It models concepts precisely, keeps reusable capabilities independent of their first caller, includes confirmed future requirements in the current foundation, and applies YAGNI only to hypothetical futures.

The underlying design philosophy is:

> 정확하게 객체화하고, 완전히 분리하고, 재사용 가능하게 추상화하며, 확정된 미래까지 포함해 처음부터 오래 버틸 기반을 만든다.

This means accurate object boundaries; implementation split first into the smallest meaningful functional units; convenient public abstractions composed from those units second; reuse independent of the first call site; and treating confirmed future requirements as present scope while applying YAGNI to hypothetical futures. Internal decomposition must not leak orchestration responsibility to callers, and public convenience must not justify a monolithic implementation.

## Back Up Local Skills

Copy every local `grn-*` skill from the active Codex home into this repository:

```powershell
.\scripts\backup.ps1
git diff
```

The script merges current files into the corresponding repository directory. Review the diff before committing so deleted or renamed files can be handled deliberately.

## Restore Skills

Copy every skill from this repository into the active Codex home:

```powershell
.\scripts\install.ps1
```

Both scripts use `$env:CODEX_HOME` when it is set. Otherwise they use `$HOME\.codex`.

## Scope

This repository intentionally excludes Codex authentication, configuration, logs, conversation history, caches, and memories. Do not copy the entire `.codex` directory into this repository.
