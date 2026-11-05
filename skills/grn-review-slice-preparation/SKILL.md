---
name: grn-review-slice-preparation
description: Prepare an implementation that already passed structural, header, and implementation-thinning reviews for stepwise user inspection and commits. Preserve the complete reviewed state in a fixed-hash stash and expose one coherent review slice at a time; do not use this skill to perform the upstream reviews or redesign the implementation.
---

# GRN 4 Review Slice Preparation

Turn one fully reviewed implementation into an ordered sequence of small changes that the user can understand, inspect, adjust, validate, and commit one at a time.

This is a review-handoff and change-isolation workflow. It does not decide whether the architecture, API, or implementation is good. Those decisions belong to the completed GRN 1 locality-first, GRN 2 header-first, and GRN 3 implementation-thinning reviews.

## Entry Gate

Use this skill only when the complete implementation has passed the relevant GRN 1, 2, and 3 reviews.

Before slicing:

1. Verify the absolute repository and worktree path, branch, HEAD, and complete working-tree status.
2. Reconstruct and inspect the complete final implementation. A partial checkout or selectively restored stash is not evidence that the whole implementation was reviewed.
3. Record the exact in-scope tracked, deleted, renamed, and untracked files, plus explicit exclusions.
4. Confirm that no unresolved structural finding, header finding, implementation finding, or contract question remains in the implementation being sliced.
5. Keep source, asset, editor, build, and runtime evidence distinct. Prior build success does not prove the isolated slices or runtime behavior.

If the full implementation was not reviewed, stop and return it to the appropriate upstream GRN review. Do not use slicing to make an unreviewed change appear complete.

## Slice Standard

Choose slices for user comprehension, not for equal size, file count, or agent convenience. Default to the finest safe granularity: recursively split a candidate while both resulting slices still satisfy the safety gate below. Do not choose a slice count in advance or stop at convenient file boundaries.

Each slice should express one coherent claim, such as:

- one ownership move;
- one public-contract change;
- one independently understandable presentation change;
- one complete implementation reduction;
- the assets, configuration, redirects, and callers required by that change.

A slice should include every declaration, definition, caller, serialized reference, asset, configuration value, and redirect needed to understand and validate that claim. Do not separate mechanical fallout from the semantic change that requires it.

Prefer an order in which prerequisites precede consumers and each committed slice builds when practical. If two changes cannot be understood or compiled independently, keep them in one slice and explain why. A file may contribute different hunks to different slices. Binary assets are indivisible and belong to the slice whose behavior they realize.

### Finest-Safe Decomposition

Build the slice plan from dependency evidence rather than filenames:

1. Identify each independently reviewable behavioral, ownership, contract, or presentation claim.
2. Trace the declaration, definition, direct callers, serialized types, assets, configuration, redirects, and removals required by each claim.
3. Split shared text files by hunk when their changes serve different claims.
4. Recursively try to split every candidate again.
5. Merge only the pieces that fail the safety gate, and record the concrete dependency that forces the merge.

Do not add compatibility wrappers, duplicate state, temporary ownership, speculative guards, or dead transition code merely to make a smaller slice compile. If independent slices require such scaffolding, the safe result is the larger atomic slice.

### Slice Safety Gate

A proposed slice is safe only when all applicable conditions hold:

- **Single claim:** the slice has one independently explainable purpose.
- **Contract completeness:** declarations, definitions, required callers, and removals agree; no unresolved symbol or temporarily stale API remains.
- **Ownership completeness:** an ownership move does not leave duplicate owners, ownerless state, or a temporary mixed model.
- **Serialized completeness:** Blueprint parents, reflected types, redirects, configuration, and indivisible binary assets remain loadable and refer to the intended implementation.
- **Behavioral completeness:** the slice does not temporarily disable, invert, or reroute behavior merely because a later slice has not arrived.
- **Validation feasibility:** the slice can undergo its relevant source, build, editor, or runtime check without relying on unexposed later work. A full build is preferred where practical; if it is not practical, state the narrower proof and the residual risk.
- **Reconciliation safety:** removing or committing the slice still leaves every remaining snapshot change recoverable and attributable.

If any condition fails, merge the slice with the smallest dependency set that makes it pass. "Same file," "related area," and "easier to extract" are not valid merge reasons by themselves.

Binary assets are indivisible, but their presence does not automatically make all nearby source changes atomic. Include only the source and configuration required to interpret and load that asset safely.

### Plan Evidence

For every planned slice, report before extraction:

- its single claim;
- expected text review size as added plus deleted lines, counting a new text file by its full line count;
- binary asset count separately;
- prerequisite slices;
- the concrete reason it cannot be split further safely.

Line estimates are planning aids, not balancing targets. Prefer a smaller safe slice even when the resulting slice sizes are uneven. After extraction, replace the estimate with the actual text line count and exact asset count.

Present the complete ordered slice plan before extracting the first slice. Then discuss and expose only one slice at a time unless the user asks for a broader view.

## Full-State Preservation

Use a named stash as the default preservation mechanism. Do not create a new worktree or temporary branch unless the user requests one.

Before creating the stash, show the user:

- absolute worktree path;
- branch and HEAD;
- exact snapshot manifest;
- excluded unrelated changes;
- proposed stash name.

Preserve only the reviewed implementation. Do not absorb unrelated dirty work merely because it shares the worktree. If in-scope and out-of-scope changes occupy the same indivisible file or hunk, report the collision before mutating Git state.

Create the snapshot with untracked in-scope files included. Immediately record:

- the stash commit hash;
- its base commit;
- the tracked-change manifest;
- the untracked-file manifest;
- the stash message.

Treat the commit hash as the stable identity. Ordinal names such as `stash@{2}` may be shown for convenience but must not be the durable reference because other worktrees share the repository's stash stack.

Do not `pop`, drop, or overwrite the full snapshot during slicing. Apply or restore from the recorded hash. Retain it until final reconciliation is complete and the user explicitly approves deletion.

Follow repository-specific tracking rules. In PROJECT-MA, never stage, commit, push, or include `docs/` changes in the stash snapshot; preserve local documentation separately.

## Extracting One Slice

For each slice:

1. Start from the current accepted HEAD and preserve unrelated dirty changes.
2. Recompute the remaining difference against the fixed snapshot instead of relying on a remembered file list.
3. Restore only the selected paths or hunks. Whole-file restoration is allowed only when every snapshot change in that file belongs to the current slice.
4. Restore untracked snapshot files explicitly from the stash's untracked parent when they belong to the slice.
5. Verify that no later slice leaked into the working tree.
6. Re-run the slice safety gate against the extracted diff. Planning-time classification alone is not proof that the extraction is safe.
7. Show the user the slice purpose, exact manifest, actual text line count, binary asset count, important dependency path, forced-merge reason if any, and expected validation before asking them to review it.

Do not commit automatically. Preparing or approving a slice does not authorize staging, committing, rewriting history, pushing, dropping the stash, or touching another worktree. Treat each as a separate action requiring the user's request under repository rules.

If the user changes the implementation while reviewing a slice, classify the change:

- A mechanical correction that preserves the accepted contract remains in the slice.
- A changed owner returns to GRN 1.
- A changed public contract returns to GRN 2.
- A changed implementation premise or newly added machinery returns to GRN 3.

After the required upstream review, record the accepted deviation from the original snapshot instead of silently forcing the old snapshot state back.

## Slice Completion

A slice is ready for the user's commit decision only when:

- its semantic purpose can be explained independently;
- its exact diff contains no later-slice work;
- required callers, assets, configuration, and redirects are present;
- the extracted diff passes every applicable slice safety gate;
- `git diff --check` passes for source changes;
- applicable source, build, editor, and runtime checks are reported separately;
- remaining full-snapshot changes are still recoverable from the fixed hash.

After the user commits a slice, verify the actual commit and recompute the remaining snapshot difference before preparing the next slice. Do not trust a remembered status or assume that the committed manifest matches the prepared one.

## Slice Handoff Format

Every response that exposes a slice for user review must begin with a compact progress block. Do not make the user infer progress from prior messages.

Use this information in this order:

1. `Progress: current/total` and the current slice title.
2. The number of previously committed slices, the current review-pending slice, and the number of remaining slices.
3. Actual added plus deleted text lines and binary asset count for the current slice.
4. Completed validation and validation still pending.
5. The title of the next planned slice.

Translate the labels to the conversation language and use a compact form such as:

```text
Progress: 7/21 - Inventory occupancy and same-size swaps
Committed 6 | Review pending 1 | Remaining 14
Size: +106/-123 lines | Binary assets 0
Validation: diff-check passed, build passed, runtime not tested
Next: Skill-slot drag-source contract cleanup
```

Distinguish a prepared slice from a committed slice. Do not count the current slice as completed until its actual commit has been verified.

If extraction reveals a forced merge, split, exclusion, or approved deviation, update the total immediately and state the old-to-new plan change once. Keep subsequent progress numbers based on the revised plan. When the total is stable, do not repeatedly explain the calculation.

After the progress block, report the slice purpose, exact manifest, dependency or forced-merge reason, and validation details. Keep the handoff concise enough that the diff remains the main review object.

## Final Reconciliation

At the end, account for every change preserved in the full snapshot as exactly one of:

- committed unchanged;
- replaced by a user-approved and appropriately re-reviewed correction;
- intentionally excluded by the user;
- unresolved.

Completion requires zero unresolved changes. Compare tracked snapshot paths against the final HEAD and separately verify files stored in the stash's untracked parent. Report any additional in-scope final changes that did not originate in the snapshot.

Run the agreed integrated validation after all slices are committed. Report source review, build, editor, and runtime proof separately.

Only after reconciliation and integrated validation should the stash be considered removable. Show its fixed hash and ask for explicit approval before dropping it.

## Reporting Ledger

Maintain a compact ledger throughout the workflow:

- worktree, branch, base HEAD;
- full snapshot hash and stash message;
- ordered slice list;
- estimated and actual text lines plus binary asset count for each slice;
- prerequisites and forced-merge reasons;
- current slice and exact manifest;
- committed or rejected slices;
- approved deviations;
- remaining paths or hunks;
- validation completed and validation still required.

Do not create tracked workflow metadata. Keep the ledger in the conversation, or in an ignored local file only when a long-running handoff requires persistence and the user approves it.
