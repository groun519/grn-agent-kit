---
name: grn-implementation-thinning
description: Review and compact implementation code after structural ownership and header contracts are settled. Remove redundant wrappers, speculative guards, dead state, duplicated decisions, and unnecessary helpers while preserving current behavior and real boundary validation. Use for implementation thinning, not architecture redesign or API-contract review.
---

# Implementation Thinning

Make the accepted design as small and direct as it can be without weakening its real behavior, invariants, or external boundaries.

"Compact" does not mean minimizing line count mechanically. It means that each remaining field, branch, helper, cache, dependency, and state transition has a current reason to exist, and the implementation path is easy to follow from the accepted API to its effect.

## Review Boundary

Use this skill only after the feature owner and public API contract are sufficiently settled.

- A structural review decides which object owns the feature and which major types or layers should exist.
- A header-first review decides whether each declared API accurately exposes that ownership and behavior.
- This review decides whether the implementation contains more machinery than those accepted contracts require.

If implementation inspection reveals a misplaced owner or an inaccurate public API, report it as an upstream structural or header finding. Do not silently redesign the architecture while claiming to thin the implementation.

## Review Premise Gate

Do not assume that an accepted owner or public contract remains valid merely because an earlier review named it. Before thinning the implementation, compare the target with its direct callers and collaborators closely enough to verify that the target is not duplicating their policy, interpreting data solely for their presentation, or implementing a responsibility that already has another concrete owner.

A narrow requested file scope limits edits, not this prerequisite evidence. Read directly collaborating implementations when ownership cannot be verified from headers alone. Keep the check shallow: it validates the accepted boundary and does not reopen unrelated architecture.

If the evidence contradicts the accepted owner, stop thinning the affected path and report a structural premise failure for locality-first review. If the owner is sound but the declared contract is inaccurate, return it to header-first review. Do not delete code, add a wrapper, or move policy while pretending the change is implementation compaction. Continue thinning only the paths whose structural and header premises remain valid.

## Review Order

1. Read repository instructions and relevant architecture documents.
2. Establish the exact files, accepted owner, public contract, and behavior that must remain unchanged.
3. Apply the Review Premise Gate to the target, its direct callers, and its direct collaborators.
4. Read the implementation, then trace every current caller, existing test, serialization path, engine callback, and external boundary that can reach it.
5. Write down the required effects and invariants before deleting code.
6. Identify the smallest meaningful functional units in the implementation, then classify each non-trivial helper, field, cache, branch, guard, dependency, and intermediate representation as required, boundary-required, duplicated, dead, or speculative.
7. Remove or inline only the duplicated, dead, and speculative parts.
8. Re-read the complete call path after edits and verify that it is shorter without hiding policy or merging unrelated responsibilities.
9. Prefer direct source, build, editor, and runtime validation. Run an existing automated test only when it protects a relevant stable contract; add a new test only when the test gate below is satisfied.

## Removal Candidates

Look for:

- forwarding functions that add no contract, policy, ownership, or adaptation;
- one-use helpers that do not name or isolate a meaningful functional unit and make a short local flow harder to read;
- state that is cheaply and unambiguously derived from existing state;
- caches without a demonstrated lifecycle or cost justification;
- repeated validation or normalization after an authoritative owner has already completed it;
- defensive branches for states made impossible by current construction and ownership;
- future flags, extension hooks, compatibility paths, and fallback objects with no current caller or confirmed requirement;
- duplicate representations that must be kept synchronized;
- optional-feature bindings, ticking, allocation, or state that remain active when the feature is absent;
- includes, dependencies, parameters, temporaries, and conversions left behind by earlier designs.

Do not preserve code merely because its guarded condition or future use is imaginable. Require a current call path, a confirmed future requirement already included in the accepted design, an external uncertainty boundary, a serialized compatibility contract, or an explicit supported state.

## Keep Real Mechanics

Retain code when it owns or protects a real requirement, including:

- user, network, file, serialized-data, weak-lifetime, asynchronous, replication, or engine-callback boundaries;
- atomic transaction, rollback, ordering, or observable failure behavior;
- validation that belongs to the authoritative owner rather than its callers;
- private mechanics that make one semantic public operation complete;
- a private function that isolates one meaningful functional unit and makes the owner's orchestration readable, even when it has only one caller;
- a helper whose name and boundary make a complex algorithm materially easier to verify;
- a cache with a real invalidation owner and demonstrated need.

Do not replace explicit code with a vague utility merely to reduce visible lines. Do not collapse unrelated behavior into a large function. Do not move policy back into callers to make the owner look smaller.

## Decompose Before Abstracting

Implementation thinning must not turn a readable owner into one large function. Preserve or introduce a private function when it expresses one independently understandable operation and lets the owning flow read as a composition of concrete steps.

Functional decomposition comes before functional abstraction:

1. identify coherent minimum operations;
2. give those operations concrete names and boundaries;
3. let the owner compose them into the convenient public capability;
4. inline only units whose separation adds no semantic or verification value.

Do not expose private units publicly just to demonstrate decomposition. The public surface should remain convenient for callers, while internal orchestration stays with the owner.

## Guard Reality Check

Classify every non-trivial guard:

- `reachable`: a current internal call path can produce the condition;
- `boundary-required`: an external or nullable contract permits the condition;
- `speculative`: no current path or supported contract permits the condition.

Keep the first two. Remove speculative guards together with branches, fields, helpers, and cached state that exist only to support them. For impossible programmer states where detection remains useful and repository conventions allow it, prefer an explicit assertion over silent fake recovery.

## Automated Test Gate

Default to not adding an automated test. Tests are justified only when all of the following are true:

- they protect stable, externally meaningful behavior or a domain invariant with real regression risk;
- source review, compilation, editor inspection, or direct runtime validation cannot protect that contract reliably enough on their own;
- the expected failure can be expressed without freezing private implementation structure;
- the long-term maintenance cost is lower than repeatedly validating the behavior manually.

Do not create or retain tests merely to prove that a class exists, a dependency was removed, a private helper or branch is used, an internal call order remains unchanged, generated metadata has a temporary value, or a checkpoint scaffold has its current shape. Do not use automated tests as a substitute for structural, API, build, editor, visual, or runtime validation.

Treat an existing test as a thinning candidate when it constrains implementation but protects no observable contract. Do not remove it mechanically: first confirm that no supported behavior, serialization contract, engine boundary, or known regression depends on it.

Before adding a test, state the exact regression it catches and why the other available validation boundaries are insufficient. If that case cannot be made, do not add the test.

## Editing

When the user requests changes:

- preserve accepted behavior unless the user explicitly approves a change;
- make the smallest coherent deletion or consolidation rather than layering another abstraction over the excess;
- update callers and tests when removed indirection changes their mechanical path;
- preserve unrelated dirty work;
- do not commit, push, or broaden the scope without authorization.

## Report

Present concrete thinning findings before edits. For each finding, state:

- the implementation element;
- why it is duplicated, dead, speculative, or unnecessarily indirect;
- the current caller or invariant evidence;
- the proposed deletion, inlining, or consolidation;
- the behavior that must remain unchanged.

After edits, report removed fields, functions, branches, dependencies, and layers separately rather than calling everything "cleanup." Name important candidates that were intentionally kept and the boundary or invariant that justifies them.

Report source review, build validation, editor validation, and runtime validation separately. A successful compile is not runtime proof.
