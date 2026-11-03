---
name: grn-header-first-review
description: Review C++ and Unreal object APIs one header at a time before implementations, checking whether names expose behavior, ownership, side effects, scope, and bundled operations. Use after structural ownership is settled and before implementation thinning; do not use for broad architecture or implementation cleanup.
---

# Header First Review

Review an API as a first-time maintainer would encounter it. The class and member names should let that maintainer predict what changes without reading the implementation.

This skill reviews the declared contract. It may inspect implementations and callers only to verify that contract. Do not turn the pass into broad architecture redesign or line-level implementation cleanup.

## Review Premise Gate

Header-first review assumes that a structural owner has been selected, but it must not blindly certify that premise. Before judging names and contracts, read the target header together with the headers of its direct collaborators and verify that the asserted responsibility is not visibly duplicated, split, or already owned by one of them.

A narrow requested file scope limits edits, not the evidence needed to validate the target API. Treat owned child objects, configured widget classes, public collaborator types, delegates, and presentation or policy dependencies as responsibility clues. When the target resolves or interprets data that a direct collaborator also owns, report an upstream structural premise failure rather than accepting a broad class label that makes both responsibilities appear valid.

Do not redesign the class map in this pass. Separate the structural premise failure from header-contract findings, identify the directly implicated owner and collaborator, and return the affected path to a locality-first review. Continue header review only for APIs whose ownership premise remains valid.

## Concept Existence Gate

Before accepting an existing name or proposing a replacement, verify that every noun phrase denotes a concept that actually exists in the code or established design. Do not turn a group of co-occurring implementation effects into a named concept merely because they happen in one function or need one call site.

A concept passes this gate only when the review can identify:

- a concrete representation such as a type, field, parameter, or explicitly maintained invariant, or established terminology used consistently across the relevant APIs;
- one owner and a boundary that distinguishes what belongs to the concept from what does not;
- a lifecycle, value rule, or atomic transition that explains why its constituent changes belong together;
- callers that use the same concept rather than only one implementation that performs the effects together.

A concept does not need one dedicated struct, but a multi-field concept must have a demonstrable invariant and owner. Repeated co-location, a shared visual outcome, or a convenient summary sentence is not sufficient evidence.

Apply extra scrutiny to umbrella nouns such as `State`, `Placement`, `Context`, `Presentation`, `Result`, `Data`, and `Process`. Do not accept them without the evidence above. If a proposed noun fails this gate, do not replace the old name with a longer or more precise-sounding abstraction. Reuse an existing concrete concept, reshape the API around the actual source, target, or value, split independently meaningful operations, or return the ownership question to locality-first review.

Run this gate for proposed replacement names as well as existing names. Do not present a concrete rename until its target concept has passed.

## Review Order

1. Read the repository instructions and relevant architecture documents.
2. Establish the requested file and feature scope. Preserve unrelated dirty work.
3. Read the in-scope headers and their direct collaborator headers without reading their implementations first.
4. Apply the Review Premise Gate and separate any upstream structural failure from API findings.
5. Identify the smallest independently meaningful operations owned by each object before accepting a higher-level convenience API.
6. Apply the Concept Existence Gate to the nouns used by the current API and every proposed replacement.
7. Review each header as its own API surface. For each class and member, try to state its result in one concrete sentence.
8. Record every place where that sentence requires guessing or implementation knowledge.
9. Run a separate split review for compound names containing `And`, `Or`, or multiple parallel effects.
10. Only then inspect implementations and call sites to compare actual behavior with the header prediction.
11. Treat every prediction mismatch as an API finding even when the implementation is functionally correct.
12. After any edits, repeat the header-only pass, including the Concept Existence Gate, before compiling or running tests.

## Finding Disposition Gate

Discovery scope and edit scope are separate. Complete the requested discovery even when it reveals problems beyond the current change, but do not automatically add every confirmed finding to the implementation scope.

Before proposing or making an edit, assign each finding candidate exactly one disposition:

- `Current Change`: The current diff introduced or worsened the problem, or leaving it unresolved would make the responsibility or contract being changed internally inconsistent, misleading, or structurally incomplete. Resolve it before completing the current work even when it does not immediately block runtime behavior.
- `Required Prerequisite`: The problem belongs to another path or owner, but leaving it unresolved would force the current change to depend on a temporary workaround, duplicated ownership, or a false contract. Present it as a separate coherent change and candidate commit boundary before continuing the dependent work.
- `Adjacent Follow-up`: The problem already exists in an independently owned responsibility and the current change remains structurally complete without correcting it. Report it without editing it in the current scope.
- `Evidence Required`: The problem is not yet confirmed by sufficient source, editor, or runtime evidence. State the missing evidence and do not edit the path yet.

Classify by causality and ownership, not severity or functional blocking alone. Do not defer a structural problem merely because the feature currently runs. Conversely, do not absorb an independently owned problem merely because it was discovered while tracing the current feature.

If a correction adds or replaces an execution path, owner, collaborator, persistence boundary, replication path, or validation boundary, state that scope change and its candidate commit boundary before editing. A general approval such as "fix it" or "try it" applies only to the explicitly presented finding, disposition, and correction scope; it does not authorize additional findings discovered during implementation.

## Header Checks

Check whether each public and important private member reveals:

- the action it performs;
- the object or state it changes;
- the relevant scope, such as current, next, all players, or local client;
- a meaningful release condition or duration when one exists;
- whether it calculates, queries, mutates, starts, cancels, or reports;
- whether it is authoritative, local-only, replicated, or order-dependent when that distinction affects correct use.

Flag APIs when:

- caller-phase names such as `CompleteArrival()` hide the object's actual capabilities;
- abstract words such as `Condition`, `State`, `Process`, `Presentation`, `Progress`, or `Complete` require implementation context;
- `Get`, `Check`, `Evaluate`, or `Resolve` conceals calculation or mutation;
- the same term names different concepts at different layers;
- collection scope is unclear, such as what `All`, `Count`, or `Pending` contains;
- a wrapper adds another hop without adding an owned semantic action;
- a public function silently depends on a preceding call;
- a bypass variant such as `WithoutEvaluation`, `SkipUpdate`, or `NoValidation` exists mainly to evade hidden behavior in the original API rather than representing a real independent capability;
- unrelated state changes are bundled only to make the call site shorter.

Do not reject these words mechanically. Accept them when the owning class and full name make the result concrete.

Treat a bypass API as evidence that the original contract may own too much. Prefer separating the original responsibility over accumulating alternate entry points that callers must choose between based on implementation knowledge.

## Verb Contract

Treat the leading verb as a strict behavioral contract, not a loose description of the visible result. For every member, classify its primary mutation before accepting its name.

- `Show` and `Hide` change visibility or presence. Do not use them for assigning progress, clearing timers, cancelling fades, or resetting presentation state.
- `Set` assigns a named state or value. Prefer a normal value parameter such as `SetReadyFill(float)` when the operation is only assigning that value. Add fixed-value functions such as `Set...ToFull()` only when the fixed value represents a distinct domain state with its own invariant or behavior.
- `Start` begins an owned operation that remains in progress after the call.
- `Cancel` stops an in-progress operation and preserves whatever cancellation contract the owner defines.
- `Reset` returns owned state to a documented baseline rather than merely hiding its output.
- `Fade` begins a time-based opacity change; an immediate visibility change is not a fade.
- `Complete` is valid only when the object owns the operation being completed. Do not use it for unrelated caller phases or for ordinary state assignment.

Reject a name when its verb describes only what a caller happens to see while the implementation's primary operation uses a different verb. Apply the same check to forwarding wrappers; forwarding to another object does not make an inaccurate verb acceptable.

## Split Or Keep

Keep operations together when they are inseparable implementation steps of one capability owned by the object. For example, setting fade time and enabling Tick can both belong inside `FadeOutReadyFill()`.

Decompose the implementation into named, independently understandable functional units before judging whether a public abstraction is convenient. A high-level public function may coordinate several private units when the object owns their combined purpose, but it should not become a monolithic implementation merely because callers need one entry point.

Split operations when the caller owns the scenario and the object changes are independently meaningful. Prefer several explicit lines over a vague scenario wrapper:

```cpp
Circle->RequireAnyPlayerExitBeforeNextReadyCountdown();
Circle->SetAutoTravelEnabled(true);
Circle->FadeOutReadyFill();
```

Do not fragment one coherent transaction into `Can...` checks and partial mutation calls merely to avoid a semantic owner. The owner should still contain its validation and execution policy.

### Compound-Name Pass

Treat a name that joins actions or outcomes with `And`, `Or`, or a list of effects as a mandatory second-pass review signal. Do not accept or split it mechanically. Determine whether each named clause:

- has useful semantics when called independently;
- changes independently meaningful state;
- has its own failure, rollback, ordering, or reuse requirements;
- belongs to a scenario coordinated by the caller rather than one invariant owned by the callee.

Split the operation when those clauses are independently meaningful. Keep it together when they are inseparable mechanics of one transaction or invariant, but rename the API after that owned purpose instead of listing its internal steps. For example, prefer `NormalizeLoadedModuleDiscoveries()` over `RemoveInvalidAndDuplicateModuleDiscoveries()` when filtering, deduplication, and ordering collectively restore the loaded data's invariant.

An owned purpose does not by itself establish a valid named concept. Before replacing a compound name with a purpose-oriented name, require the replacement noun to pass the Concept Existence Gate.

After choosing to keep a compound operation, verify that the replacement name is concrete enough to predict mutation and scope. Do not replace an exact but bundled name with a vague umbrella such as `Process`, `Handle`, or `Update`.

When proposing names, first identify the target concept and its concrete evidence. Only then prefer action + target + relevant scope or condition. A longer exact name is better than a short name that requires opening the implementation, but length does not make an invented concept valid.

## Editing

When the user requests changes:

- edit only `Current Change` findings and explicitly approved `Required Prerequisite` findings;
- make the smallest rename or responsibility split that resolves the finding;
- update declarations, definitions, call sites, serialized references, architecture documents, and only tests that protect a real public contract in the same change when applicable;
- preserve behavior unless the user explicitly approves a behavioral change;
- distinguish newly introduced problems from existing readability debt;
- do not add comments as a substitute for an inaccurate name;
- do not create helper wrappers solely to make a call site one line.

Do not add an automated test merely because an API changed. Prefer header, caller, build, editor, and runtime verification unless the API exposes stable behavior with a concrete regression that cannot be protected adequately at those boundaries.

## Report

Present findings before implementation details. For each significant finding, include:

- the header API;
- what a first-time reader would reasonably predict;
- the actual behavior after implementation inspection;
- the mismatch or hidden responsibility;
- a concrete rename, split, or ownership correction, including the code or design evidence for every newly proposed concept;
- its disposition: `Current Change`, `Required Prerequisite`, `Adjacent Follow-up`, or `Evidence Required`.

When the review results in edits, report every logical modification separately. For each modification, state:

- the affected API, type, or responsibility;
- what changed, preferably as the previous shape and the resulting shape;
- why the review required that change;
- whether runtime behavior was preserved or intentionally changed.

Do not collapse unrelated edits into a vague summary such as "cleaned up the API." Group mechanical declaration, definition, and call-site updates under their single logical change, but do not omit any distinct rename, split, removal, ownership move, or behavioral correction.

Also identify reviewed compound or bundled candidates that were intentionally kept together when that decision is non-obvious, and state the owned transaction or invariant that justifies keeping them together.

Report source review, build validation, and runtime validation separately. Do not claim runtime completion from a successful compile.
