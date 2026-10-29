---
name: grn-commit-squash
description: Curate PROJECT-MA WIP commits into reviewed final commits when the user asks to squash, reword, reorder, assign title dates, or clean up commit history. Preserve user intent and require approval of exact commit messages before rewriting history.
---

# GRN Commit Squash

Turn reviewed PROJECT-MA work into a readable commit history without silently deciding chronology, intent, or commit boundaries.

## Establish The Range

1. Read the repository instructions and current branch status.
2. Inspect the commits, diffs, reflog, stashes, and relevant conversation needed to identify the requested work.
3. Preserve unrelated working-tree, index, stash, and commit changes.
4. Treat title dates as project chronology. They do not need to match author dates, committer dates, current dates, or the dates when implementation happened.
5. Use a date label supplied by the user exactly. When none was supplied, recommend a date label during discussion using the workload guidance below, but do not treat the recommendation as approved.
6. Do not silently assign a date, sequence suffix, series number, category, verb such as `Add` or `Refactor`, or squash boundary. Every proposed value and boundary remains a draft until the user approves the final manifest.

## Recommend Title Dates

When the user has not supplied title dates, propose them instead of requiring the user to calculate them unaided.

1. Inspect the neighboring approved dated commits to find the current project chronology and the work already assigned to its latest date.
2. Estimate the workload from the final C++ diff, not the number of WIP commits or saves. Count authored additions and substantive modifications in `.cpp`, `.h`, `.hpp`, and `.inl` files after intermediate churn is removed. Consider deletions qualitatively rather than subtracting them into a misleading negative workload.
3. Do not count JSON, config, generated files, imported assets, or binary assets toward the line-based daily workload. They still determine functional boundaries and commit contents, but they do not advance the date by line count.
4. Use about 300 lines of final C++ work as the center of one project day. Treat roughly 200-400 C++ lines as the ordinary range. This is a planning heuristic, not a quota.
5. Work above 400 C++ lines may remain on one date when it is one coherent feature and splitting it would create misleading or broken intermediate contracts. Prefer a new date when independent functional boundaries already exist and the combined C++ work would materially exceed the ordinary range.
6. Multiple final commits may share one date and receive ordered suffixes such as `(1)`, `(2)`, and `(3)`. Estimate the date's total C++ workload across those commits rather than granting each commit a separate daily allowance. Data-only and asset-only commits normally stay on the current project date with the next suffix unless the user establishes different chronology.
7. Undated maintenance, merge, removal, and small isolated commits normally do not consume a dated work slot. Include them in the estimate only when they actually contain substantial feature work that should have used the dated form.
8. Show the estimated C++ workload and the reason for each recommended label during discussion. If the evidence supports more than one reasonable chronology, present the alternatives rather than pretending one is exact.
9. A recommended date becomes final only when the user approves it as part of the complete manifest. Never rewrite history merely because the recommendation was shown.

## Draft Before Rewriting

Present a manifest for every proposed final commit before changing history:

- source commit or commits;
- final title date, or explicitly no title date;
- exact final title;
- exact commit body;
- files or functional scope included;
- commits that remain separate.

After inspecting the range, immediately present a complete draft manifest. Fill in recommended dates, boundaries, titles, bodies, and ordering when the user has not supplied them. Do not stop at a scope summary or ask the user to calculate dates first. Mark recommendations as draft decisions that the user may revise.

Ask a clarifying question before producing the first manifest only when missing evidence makes it impossible to identify the safe commit range or preserve unrelated work. Otherwise, resolve ordinary ambiguity with a concrete recommendation in the manifest and explain the tradeoff briefly.

Entering this skill never authorizes an immediate rewrite. Treat requests such as "스쿼시 보자", "커밋 정리하자", "어떻게 묶을까", "검토해봐", and "어때?" as requests for the complete draft manifest, not execution approval.

Use three explicit phases:

1. **Initial manifest:** inspect scope and immediately show the complete proposed commit sequence with exact messages and recommended dates and boundaries. Do not create commits or move refs.
2. **Manifest revision:** revise dates, boundaries, titles, intent, and implementation summaries with the user. After every correction, show the complete corrected manifest again rather than only the changed fragment.
3. **Apply:** apply the settled manifest after clear execution approval, including a short affirmative reply to a direct question about applying the complete current manifest.

When the complete current manifest has been shown and you ask whether to execute it, accept natural affirmative replies such as "응", "좋아", "그래", "ㅇㅇ", "yes", or "OK" as approval for that exact manifest. Do not require specific wording such as "이대로 커밋해" or ask again solely because the reply is short.

Approval of only one title or date, a request to inspect the next commit, or a response to a discussion question does not by itself approve applying the entire manifest. If it is unclear which action an affirmative refers to, ask one concise execution question; a short affirmative answer to that question is sufficient.

## PROJECT-MA Commit Message Contract

Write commit bodies in Korean unless the user explicitly requests another language. English API names, type names, asset names, and other project identifiers may remain inline. Titles may follow the repository's established English naming style, but an English title never authorizes an English body. Do not preserve an existing English body merely because its wording is otherwise accurate.

PROJECT-MA uses exactly two final commit message forms. Do not blend them into a third hybrid form.

### Dated Work Form

For dated final work commits, use this shape:

```text
<user-approved date label> <approved title>

DONE
- <user intent>
- <reason for the feature or change>
- <important desired behavior, constraint, decision, or confirmed trial and error>

- <implemented behavior>
- <technical structure and responsibility boundary>
- <important implementation resolution or preserved contract>
```

The two bullet groups have different sources and must not be collapsed.

### Intent Group

The first group records the user's intent. Recover it from the conversation and user-authored design records, not merely from the final diff. Preserve why the work exists, the intended gameplay or workflow, constraints, decisions, and meaningful failed or rejected approaches when the user actually discussed them.

Intent is more important than producing a generic feature list. Do not replace it with stock prose such as "previously there was no presentation" unless the user established that as the reason. Do not infer motives from code. If the available record does not establish intent, mark the missing point in the draft and ask for it before rewriting.

### Implementation Group

The second group summarizes the verified implementation. Derive it from the final diff, code, assets, tests, and build or runtime evidence. Record the main data flow, ownership and responsibility boundaries, preserved behavior contracts, and the technical resolution of relevant problems.

Do not claim build or runtime verification that did not occur. Do not present an abandoned intermediate implementation as part of the final behavior, but include a discarded approach when it explains an important design decision and is confirmed by the conversation.

### Conventional Undated Form

Use an ordinary undated commit message for work that does not need the dated work-log form. This form is commonly appropriate for:

- a small isolated change;
- a removal or cleanup with almost no added implementation;
- merge or integration history.

Write an appropriate concise title and body for the actual change. Do not require `DONE`, the intent/implementation two-group layout, or any substitute fixed template. The body still follows the Korean-language rule. Preserve a good existing message only when its language and content already satisfy this contract.

The criteria above guide proposals; they do not authorize Codex to override a date form or date label supplied by the user. When the intended form is unclear, discuss it in the manifest before rewriting.

## Rewrite Safely

After manifest approval:

1. Record the original HEAD, branch, status, commit trees, author and committer metadata, and target remote state.
2. Rebuild only the approved commits. Preserve author and committer dates unless the user explicitly requests metadata changes; title dates alone never authorize metadata changes.
3. Prefer commit-object or temporary-index operations that leave the working tree untouched.
4. Verify final tree equality, per-commit patch or content equivalence, commit order, metadata, and unchanged worktree status before moving the branch reference.
5. Report old-to-new commit mappings and the exact final messages.
6. Never push or force-push unless the user explicitly requests publication. Fetch first and use an explicit lease for any approved force-push.

Stop before moving the branch when the date label, title, intent, implementation summary, boundary, or publication scope remains ambiguous.
