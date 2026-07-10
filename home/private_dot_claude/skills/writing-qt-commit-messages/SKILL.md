---
name: writing-qt-commit-messages
description: Use when writing or drafting a git commit message in a Qt repository (qtbase and other qt modules), or when the user asks for a commit message in "my style" / "Alex's style". Covers Qt/Gerrit conventions plus this author's personal habits (Pick-to-first trailer order, problem-then-solution bodies scaled to complexity, Amends/Relates references).
---

# Writing Qt Commit Messages (Alex's style)

## Overview

Produce commit messages that match how Alexandru Croitor writes them in Qt
repos: a scoped imperative subject, a body that explains the problem before the
fix, and Gerrit trailers in a specific order. Qt-specific conventions layered
with personal habits derived from 100+ real commits.

**Core principle:** the body justifies *why* the change is needed and what
breaks without it — not only *what* changed.

## Length scales with complexity

Match the body length to the change. Do not pad a small fix into paragraphs,
and do not compress a subtle change into one line.

- **Trivial fix** (typo, rename, one-line guard): subject may be enough, or one
  short sentence of context. e.g. `CMake: Fix typo in CycloneDX SBOM summary
  entries` needs little or no body.
- **Ordinary change**: 1–2 short paragraphs — what was wrong, what you did.
- **Subtle / wide-impact change**: several paragraphs — current behavior, the
  failure, the fix, the reasoning, edge cases, and follow-up implications.
  Reserve the long form for changes that actually warrant it.

## Structure

```
Scope: Imperative verb, capitalized, no trailing period

Body wrapped at ~72 columns, length proportional to the change.
Problem / current behavior first, then the fix, then consequences.

Amends <full-sha>            # optional, when fixing up a prior commit

[ChangeLog][Category] User-facing one-liner.   # optional, only if user-visible

Pick-to: 6.8 6.11
Fixes: QTBUG-NNNNN           # or Task-number: QTBUG-NNNNN
Task-number: QTBUG-NNNNN
Change-Id: I...              # leave to the commit-msg hook; do not invent
```

## Subject line

- Format: `Scope: Imperative verb ...`. Verb-first after the colon, capitalized.
- No trailing period. Keep it ≲ 72 chars, ideally shorter.
- Common scopes (most frequent first): `CMake:`, `coin:`, `qmake:`, `syncqt:`,
  `Core:`, `macdeployqt:`, `configure.bat:`. Non-prefixed subjects exist (e.g.
  `Silence ...`, `Remove ...`, `Don't load ...`) when no single scope fits —
  prefer a scope when one applies.
- Nested sub-scope is allowed when it adds clarity: `Scope: subscope: Verb ...`,
  e.g. `CMake: doctools: Avoid blocking integrations due to version mismatch`.
- Verbs actually used: Add, Fix, Introduce, Improve, Allow, Use, Set, Remove,
  Change, Increase, Enable, Disable, Handle, Require, Export, Refactor,
  Implement, Move, Create, Replace, Guard, Harden, Validate, Convert, Look,
  Skip, Delay, Relax, Call, Forward, Clean up, Inform, Restore, Silence,
  Rework, Split, Decouple, Teach, Work around, Don't (negative imperative,
  e.g. `Don't process SIMD OSX_ARCHITECTURES on non-Apple platforms`).
- Special prefixes:
  - `WIP: Scope: ...` for work-in-progress commits not yet ready.
  - `Revert "<original subject>"` for reverts, with a body giving the
    `This reverts commit <sha>.` line and a `Reason for revert:` line.
  - `Reland: <original subject>` when re-landing a previously reverted change.
    Restate the original message in the body and explain what was fixed so it
    can land this time.

## Grammar and word choice

- **Imperative mood for the action you take**: "Add", "Switch to", "Provide",
  "Make sure to", "Move". The subject and the sentences describing your change
  are commands.
- **Present tense for describing behavior** (old or new): "creates", "shows",
  "doesn't get picked up", "fails with".
- **First-person plural is fine** for project decisions and history: "We don't
  support ...", "We already were copying ...", "We add the include guards ...".
- **Sentence openers** the author leans on: "The ...", "This ..." / "It ..."
  (referring back to the previous sentence), "We ...", "Previously ..." (to
  introduce old behavior), "To <verb> ..., <do X>" (purpose first), "If ...",
  "Otherwise ..." (the consequence of not doing it), "So ...", "Also ..." (to
  tack on a related action). Vary them; "This" / "The" carry most paragraphs.
- **Word-choice preferences** (use these forms): "instead of" / "rather than"
  / "in favor of" for replacements; "due to" for cause; "as well" (not "too");
  "in case ..."; "by default"; "used to ..." for former behavior; "anymore";
  "Make sure to ..."; "Note that ..."; "In contrast ...". Connect old→new with
  "Previously ... Now ..." / "This change ...".
- **Cautionary framing** is common: "We want to ensure we don't ...", "to not
  break existing ...", "One caveat is that ...".
- Contractions are fine and frequent ("don't", "doesn't", "it's", "can't",
  "that's", "didn't").
- Use "e.g." and "i.e." rather than spelling them out. Expand an obscure
  acronym once on first use.
- Quote real symbols, targets, variables, and flags verbatim
  (`SQLite::SQLite3`, `Qt::Positioning`, `QT_NO_INSTALL_FIND_MODULES`).
- Plain, matter-of-fact, technical tone. State facts; don't sell the change.
- **Avoid AI-tell / hype vocabulary.** Do not use: "smoking gun",
  "load-bearing", "delve", "leverage", "robust", "seamless", "crucial",
  "comprehensive", "intricate", "elevate", "underscore", "boasts", "realm",
  "testament", "it's worth noting", "in today's ...", "game-changer". Say it
  plainly instead (e.g. "important", "uses", "thorough").
- Don't editorialize ("nicely", "cleanly", "simply") unless it carries
  technical meaning.

## Body content habits

- Always a blank line after the subject. Wrap at ~72 columns.
- For non-trivial changes: lead with the current behavior / problem, then the
  solution, then reasoning and caveats.
- Use concrete artifacts when they clarify: indent error messages, CMake output,
  or code by a couple of spaces so they stand out.
- **Dash-bullet lists** are a common habit for listing options, conditions, or
  steps. Continuation lines align under the text after the `- `:
  ```
  Introduce two new options for SBOM entity type specification:
  - SBOM_ENTITY_TYPE: has the highest priority
  - DEFAULT_SBOM_ENTITY_TYPE: Used as a fallback when no explicit type
    is given.
  ```
- **Preconditions-then-outcome** framing for bug reproductions: a short lead-in
  ending in a colon ("If a user:", "The setup:"), a dash-bulleted list of the
  conditions, then a "then ..." paragraph describing what breaks.
- Enumerate distinct points as `1)`, `2)`, … and use `bonus)` for an extra
  aside. Use this (rather than dash bullets) when the points are reasons or
  arguments you then refer back to. Only when there are genuinely several.
- Reference related commits in the body, just above the trailers:
  - `Amends <full-40-char-sha>` when fixing up an earlier commit.
  - `Relates to <full-sha>` / `Fixes issue surfaced by <full-sha>` for context.
- Note follow-up implications honestly (e.g. "only works once all qt repos are
  reconfigured", behavior-change notes).

## Trailers (order matters)

Emit in this exact order; omit any that don't apply:

1. `[ChangeLog][Category] ...` — only when user-facing. Categories seen:
   `[Build Systems]`, `[Third-Party Code]`. One concise sentence.
2. `Pick-to: <branches>` — space-separated, e.g. `Pick-to: 6.8 6.11`. **This
   comes before `Fixes:`/`Task-number:`** (a personal-order signature).
3. `Fixes: QTBUG-NNNNN` — when the change closes a bug.
4. `Task-number: QTBUG-NNNNN` — for ongoing tasks (can co-exist with `Fixes:`).
5. `Change-Id: I...` — generated by Qt's `commit-msg` git hook. Do **not**
   fabricate one; leave it out and let the hook add it (mention this if asked).
6. `Reviewed-by:` — added by Gerrit on merge, never hand-written.

## Quick reference

| Element | Rule |
|---|---|
| Subject | `Scope: Verb ...`, no period, ~≤72 chars |
| Most common scope | `CMake:` |
| Body length | proportional to complexity; trivial = none/one line |
| Body content | problem → fix → consequences |
| Mood/tense | imperative for the action, present for behavior |
| "We" | fine for project decisions/history |
| Enumeration | `1)`, `2)`, `bonus)` (only with several points) |
| Commit refs | `Amends <sha>`, `Relates to <sha>` (full 40-char SHA) |
| Trailer order | ChangeLog → Pick-to → Fixes → Task-number → Change-Id |
| Pick-to position | **before** Fixes/Task-number |
| Change-Id | leave to the hook; don't invent |

## Common mistakes

- ❌ Putting `Fixes:`/`Task-number:` before `Pick-to:`. Pick-to comes first.
- ❌ Padding a trivial fix into multiple paragraphs.
- ❌ Compressing a subtle change into one line.
- ❌ Trailing period on the subject.
- ❌ AI-hype words (see grammar section).
- ❌ Inventing a `Change-Id:` value — the hook generates it.
- ❌ Hand-writing `Reviewed-by:`.
- ❌ Conventional-commits style (`feat:`, `fix:`). Use `Scope:` + imperative.
- ❌ Abbreviated SHAs in `Amends`/`Relates to` — use the full 40-char hash.

## Examples

Trivial — subject carries it:
```
CMake: Fix typo in CycloneDX SBOM summary entries

Change-Id: I...
```

Ordinary — short body:
```
CMake: Change warning to error for VCPKG_ROOT env var check

If the root is empty or doesn't exist, it's probably an accident and
configuration should fail early.

Pick-to: 6.8 6.11
Change-Id: I...
```

Complex — fuller body with reasoning:
```
CMake: Introduce WrapSystemSQLite3 wrapper to avoid deprecation

CMake 4.3's FindSQLite3.cmake file now creates a new
 SQLite3::SQLite3
target, instead of
 SQLite::SQLite3
which is now deprecated, and shows a warning when linking to it.

To keep Qt builds compatible with both target names regardless of the
cmake version used, add a new FindWrapSystemSQLite3.cmake file which
creates a WrapSystemSQLite3::WrapSystemSQLite3 target that links to
whichever one is available.

This gets rid of the deprecation warning and avoids leaking the target
name in the exported INTERFACE_LINK_LIBRARIES of consumers in a static
Qt build.

Pick-to: 6.8 6.11
Change-Id: I...
```
