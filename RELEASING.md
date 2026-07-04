# Releasing the Keyguard Designer (keyguard.scad)

This is the formal release process for the OpenSCAD Keyguard Designer. It is the
**same shape** as the process for the other Volksswitch projects (Conversant AAC and
the Keyguard Designer web app): *work locally, log each user-visible change to
`## Unreleased` in plain language, and say "bump keyguard designer" to cut a release.*
Only the mechanics (an integer `keyguard_designer_version`, and a file-download updater
instead of a served app) differ.

## Environment model

- **The PC is the development environment.** All day-to-day work is committed to the
  local `main` branch on the PC. **These commits are NOT pushed.** They are backed up
  and synced across your machines by OneDrive, which syncs the whole project folder
  including the `.git` directory.
- **GitHub is the release environment.** The repository is
  <https://github.com/Volksswitch/keyguard>. There is no served app — instead the
  Keyguard Designer **web app's in-app updater** downloads `main/keyguard.scad`, and the
  Volksswitch web pages link to it. So the copy of `keyguard.scad` on `main` **is** what
  clinicians get. Therefore:

  > **Commit to local `main` = save your work.
  > Push `main` = release to clinicians.**

  Everything you commit piles up locally, invisible to clinicians, until you release.
  We do not push between releases.

There is one branch: `main` (plus any transient `claude/*` worktree branches from cloud
agents, which never deploy). There is no separate `dev` or release branch.

## Between releases (the dev cycle)

- **Claude commits; Ken does not run git.** As each change is completed, Claude commits
  it to local `main`. No pushing.
- **Changelog-as-you-go (mandatory).** `CHANGELOG.md` is kept in lockstep with
  `keyguard.scad`. The moment a change lands that a **clinician** could see or do
  differently, add or edit the matching plain-English bullet under the topmost
  **`## Unreleased (next release)`** heading, **in the same commit as the code**, written
  the way a clinician reads it, matching the voice of the existing `## Version N` bullets.
  These bullets are literally clinician-facing UI text: at release the web app's
  `publish-scad-version.mjs` copies them **verbatim** into `latest_scad_version.json`,
  which is the "What's new" list shown in the in-app **Keyguard update** dialog. Exclude
  internal-only work (tests, tooling, refactors, geometry-harness with no visible effect);
  when in doubt, ask Ken. If a change is backed out, delete its bullet in the same commit.
  **Ken's own edits to `CHANGELOG.md` are authoritative** — preserve his wording; make
  only surgical edits.

## Version numbers

Two things carry the version:

- **`keyguard_designer_version`** (integer, in `keyguard.scad`, line ~522) — the version
  banner and CHANGELOG attribution.
- **`latest_scad_version.json`** — the manifest the web app's updater compares against; its
  `version` and `notes` are regenerated from the constant + `CHANGELOG.md` by
  `publish-scad-version.mjs` (in the web-app repo, trigger "publish scad version").

**Pre-bump (so you always know which build you're testing).** At the *end* of each release,
the local dev copy is immediately pre-incremented: `keyguard_designer_version` → (last public
release + 1). The dev build's version banner therefore always reads a number **higher than the
last public release**. This pre-bump lives **locally only (unpushed)** until its release.

**The updater gate — why the pre-bump must be held off `main` (this bit us once).** The web
app's updater downloads `main/keyguard.scad`, reads its `keyguard_designer_version`, and
**aborts** if it does not equal the manifest's `version`. So on GitHub `main`, `keyguard.scad`
and `latest_scad_version.json` must **both equal the currently-released version and each other**.
Never push a pre-bumped `.scad` to `main` ahead of a matching manifest. The number only ever
increases.

## When to release

Release only when a coherent chunk is done — a set of fixes/features you'd describe to a
clinician in one breath. Routine improvements wait for the next window (roughly a couple of
months); a bug that blocks a clinician from designing a keyguard may go out as soon as it's
fixed and tested. Anything below that bar stays as local commits; `main` does not move.

## Releasing — trigger phrase "bump keyguard designer"

Ken says **"bump keyguard designer"** (or an obvious variant). Ken issues this only **after he
has verified the `CHANGELOG.md` contents.** That single command authorizes the entire ritual
below **through the push** — Claude runs it end to end and does **not** pause for a second
confirmation before pushing. Let `N` = the pre-bumped `keyguard_designer_version`.

1. **Verify** `keyguard_designer_version` reads `N` (it was pre-bumped at the last release).
2. **Finalize the changelog.** Rename the topmost **`## Unreleased (next release)`** heading to
   **`## Version N`**, and add a fresh empty `## Unreleased (next release)` section above it.
3. **Regenerate the manifest:** "publish scad version"
   (`node scripts/publish-scad-version.mjs` in the web-app repo) — writes `version: N` and the
   `## Version N` bullets into `latest_scad_version.json`. Confirm the number matches.
4. **Commit** the release (`keyguard.scad`, `CHANGELOG.md`, `latest_scad_version.json`) as one
   commit, so `main`'s served file and the manifest both say `N` at the same moment.
5. **Push `origin main`.** The updater now offers `N` to clinicians on older versions.
6. **Start the next cycle — pre-bump.** Increment `keyguard_designer_version` to `N+1`, commit
   that locally, and **do not push.**

## Invariants — do not break these

- **Never push to `main` except as step 5 of "bump keyguard designer".** The copy of
  `keyguard.scad` on `main` is what clinicians download. Between releases, everything stays as
  local commits.
- **On `main`, `keyguard.scad`'s version and the manifest's `version` must always match** (the
  updater aborts otherwise). The pre-bumped `.scad` stays local (unpushed) until its manifest is
  pushed with it.
- **The version only ever increases** (never reused, never lowered).
- **`CHANGELOG.md` is authored as-you-go**, in clinician language; nothing is authored at release
  except the `## Unreleased` → `## Version N` rename.
- **Ken verifies `CHANGELOG.md` before issuing "bump keyguard designer";** the command then runs
  through the push without a second confirmation.

## Rolling back a bad release

Revert the release commit on `main`, then bump the version **up** again (e.g. `84` → `85`, never
back to `83`), regenerate the manifest so it matches, and push both together — same "file and
manifest agree on `main`" rule as a forward release.
