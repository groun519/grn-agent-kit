---
name: grn-locality-first-review
description: "Review class-level architecture against a locality-first philosophy: accurate concept boundaries, complete ownership, first-caller-independent reuse, justified dependencies, and confirmed future requirements without hypothetical overdesign. Report concrete functional defects encountered during the review separately; do not turn this pass into an exhaustive correctness, API, or implementation audit."
---

# Locality-First Architecture Review

Review the class map by following the feature concept to the class that owns it. A maintainer should be able to start from the gameplay or product concept, find one responsible class, and understand the major dependency path without searching through unrelated managers, processors, registries, or wrappers.

The goal is not the smallest structure today. It is a durable foundation built from accurately modeled concepts, implementations decomposed into meaningful functional units, convenient semantic public entry points, and owners that remain independent of their first caller. Include confirmed future requirements in the present design scope; apply YAGNI only to hypothetical futures.

This pass primarily judges classes, layers, and ownership boundaries. While tracing the current feature path, also report concrete functional defects that are directly evidenced. Keep those defects separate from structural findings: a bug does not by itself prove that the class structure is wrong.

## Review Premise Gate

Do not treat a prior review result, checkpoint boundary, class comment, or requested target file as proof that the current ownership model is correct. Before accepting the class map, restate the feature concept, its asserted owner, and the owner's direct collaborators, then verify that the code actually follows that boundary.

A narrow requested edit scope limits what may be changed; it does not forbid reading the directly collaborating types needed to validate ownership. In particular, when a container, entry, presenter, content object, or child widget composes another presentation object, trace each independently meaningful policy or datum to the object that decides it. Do not accept a broad label such as "presentation" or "entry behavior" when it hides separately changing frame, content, interaction, placement, or lifecycle responsibilities.

If the asserted owner duplicates a collaborator's policy, interprets data solely to feed that collaborator, or retains responsibility already represented by the collaborator, record a structural premise failure. Reconstruct the smallest accurate ownership boundary instead of continuing from the inherited premise. If the requested evidence scope is too narrow to confirm that boundary, report that limitation rather than concluding that the structure has no findings.

## Review Boundary

Use this skill for:

- architecture proposals and checkpoint plans;
- class ownership and responsibility boundaries;
- dependency direction and the number of class hops in a feature path;
- deciding whether a class, component, factory, resolver, manager, registry, or polymorphic layer is justified;
- deciding whether classes should remain separate, merge, move, or disappear;
- reporting concrete functional defects encountered while establishing the current ownership and dependency path.

Do not expand this pass into an exhaustive search for missing validation, unsupported data, stale assets, edge cases, error messages, performance, or security problems. Do not review individual function names, fields, branches, guards, helpers, or line count unless they directly evidence either an actual functional defect or a misplaced class responsibility.

The structural result decides whether the class-level shape matches the architecture philosophy. Leave per-header contracts to a header-first review, comprehensive correctness work to a dedicated functional review, and implementation weight to an implementation-thinning review.

## Review Method

1. Read repository instructions and relevant architecture documents before judging the design.
2. Establish the requested feature, current behavior, and confirmed future requirements. Do not treat checkpoint, file, module, or layer boundaries as automatic class boundaries, and do not treat an imagined future as confirmed scope.
3. Apply the Review Premise Gate to the asserted owner and its direct collaborators.
4. List each in-scope class or major value type and describe its responsibility in one sentence.
5. Draw the class-level dependency and call path. Ignore internal branches and validation details.
6. For each class, ask why it must exist as a separate owner rather than being data, a private mechanic, or part of another existing owner.
7. Check whether one responsibility is spread across classes or one class combines independently owned concepts.
8. Trace the debugging path at class granularity: identify how many owners a maintainer must visit to change one policy.
9. Inspect current requirements before accepting extension layers, compatibility layers, additional lifecycles, or speculative class boundaries.
10. Check whether a reusable capability is modeled independently of its first caller and whether shared mechanism is separated from caller-specific policy.
11. Compare the current class map with the shortest complete ownership path that still supports all current and confirmed requirements.
12. Record directly evidenced functional defects separately. Do not classify them as structural unless the class ownership or dependency direction is the cause.

## Ownership Standard

Prefer a caller that reaches one semantic owner without traversing classes that only forward, rename, or redistribute the request. The responsible class may contain several private mechanics when they all implement its one capability.

The semantic owner must complete the capability: its state, policy, validation, and execution end there. Callers should not need to pre-check owner state, repeat type or authority branches, or reproduce exception policy before asking for the capability. Treat a policy decision copied across several classes as scattered ownership even when each copy is small.

Do not move a caller-owned scenario into a lower object merely to shorten the call site. Independent actions may remain several explicit calls when no single object owns the combined scenario.

Policy branches do not disappear when hidden behind an abstraction. Place each branch in the object that owns the affected concept rather than moving it into a caller, generic manager, or shared utility.

## Durable Abstraction Standard

- Model real domain concepts accurately before optimizing file count or call-site length.
- First identify the smallest independently understandable functional units. "Smallest" means one coherent operation with a useful name, not one statement or an arbitrary micro-helper.
- Only after those units are clear, compose them into convenient semantic public entry points owned by the object.
- Keep the public surface easy for other objects to use without collapsing the owner's internal units into one unreadable implementation.
- Do not expose every internal unit merely to keep the public wrapper thin; callers should not inherit the owner's orchestration policy.
- Make a reusable capability depend on its own domain inputs and contracts, not on the widget, actor, workflow, or module that happened to need it first.
- Separate reusable mechanism from use-case policy, then compose specialized owners instead of embedding one caller's scenario in the common mechanism.
- Treat a documented, agreed, or otherwise confirmed future requirement as present design scope when omitting it would force the foundation to be replaced later.
- Apply YAGNI to hypothetical variants, imagined scale, and unspecified extension points. Confirmed future scope does not justify unrelated general-purpose frameworks.

Functional abstraction is secondary to clear functional decomposition. Durability is not measured by the number of extension points or by how much behavior fits behind one method. Prefer the smallest complete foundation that can support the known lifecycle and confirmed variations without moving policy into callers or requiring a later ownership rewrite.

## Indirection Gate

For every factory, resolver, processor, manager, registry, context, mapping, forwarding wrapper, or runtime object, require a concrete benefit. Keep it only when it does at least one of the following without scattering ownership:

- shortens both the usage path and the debugging path;
- removes a central type switch by localizing behavior in the responsible implementation;
- owns a real lifecycle, state, policy, or transaction;
- represents a current external or serialization boundary.

Reject an abstraction that only renames a direct call, hides a simple branch, prepares for an unspecified future, or requires maintainers to traverse more files to find the actual decision. Accept future-facing structure only when it corresponds to a confirmed requirement and preserves a shorter ownership path than deferring it would.

Use polymorphism when adding a variant changes its implementation or data without editing unrelated central systems. Do not introduce an object hierarchy for a small stable branch that already belongs to one owner.

## Class Boundary Test

- Keep classes that own a real lifecycle, state, external boundary, framework role, or independently changing policy.
- Remove speculative structural layers and extension points that have no current or confirmed owner or requirement.
- When an optional capability is absent, require its structural cost to be absent too: no dedicated owner, dependency, state, binding, ticking, or lifecycle should remain active solely for that capability.
- Do not split one owner into data, resolver, processor, and presenter classes merely to make methods shorter.
- Do not merge independently owned concepts merely to reduce the class count.
- Prefer small local duplication over a shared abstraction that crosses responsibility boundaries. Deduplicate only when the shared owner shortens both usage and debugging paths.
- A checkpoint is a delivery and verification boundary, not an automatic runtime class boundary.
- Prefer direct data plus a clear owner over a framework built for possible future variants.
- If a temporary connection is introduced because its final owner does not yet exist, treat it as explicit architecture debt and record its exact location, intended owner, and removal condition in the project's existing architecture documentation.
- This documentation requirement does not authorize changing `.gitignore`, staging files, changing tracking policy, or introducing a new documentation policy. If no established destination exists, report that fact and ask where the debt should be recorded.
- Do not apply this rule when the final owner already exists or when the implementation merely precedes a confirmed future extension.

## Findings

Always report two independent result sections, even when one has no findings:

1. **Functional Defects**: concrete current behavior that is wrong, with the observed effect and supporting code or data path. Do not include speculative risks or demand structural change when a local correction is sufficient.
2. **Structural Philosophy**: class-level ownership, dependency, or abstraction findings. A structural violation does not require an already observed runtime bug.

For each structural finding, state:

- the feature concept and expected owner;
- the current class and dependency path;
- why a class is missing, unnecessary, misplaced, over-broad, or split across owners;
- the smallest class-level correction: keep, merge, split, move, or remove;
- which later review should inspect API or implementation details.

Also name non-obvious classes that were reviewed and intentionally retained, with the lifecycle, boundary, or ownership reason that justifies them. If the class structure already matches the philosophy, say so instead of inventing functional or implementation findings.

## Editing

When the user requests implementation:

- make only the smallest class-level ownership change supported by current dependency paths;
- remove types, dependencies, and forwarding layers that existed only for the rejected ownership model;
- update architecture documents affected by the changed boundary;
- preserve unrelated work and avoid broad cleanup outside the reviewed capability;
- hand off API naming and implementation compaction to their dedicated review passes.
