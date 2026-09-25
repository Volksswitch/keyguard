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
  <https://github.com/Volksswitch/keyguard>. Pushing `main` publishes `keyguard.scad`
  there, which is where the Volksswitch web pages link and where the web app's publish
  step fetches it from. Therefore:

  > **Commit to local `main` = save your work.
  > Push `main` = publish the file.**

  Everything you commit piles up locally, invisible to clinicians, until you release.
  We do not push between releases.

- **⚠ Pushing this repository is NOT the whole release.** Clinicians do **not** download
  `keyguard.scad` from GitHub. Since web app release 102 the app fetches the designer
  file and its version list from **its own address** (`keyguard.volksswitch.org`),
  because school networks block GitHub by hostname and a clinician behind one would
  otherwise never be offered an update. So a version that is on GitHub and nowhere else
  has reached **nobody**. The copy that matters lives in the `keyguard-web` folder,
  beside `app.html`, as `keyguard_v<N>.scad` + `latest_scad_version.json`.

  **This is exactly how the v90 release stalled half-done on 24 Sep 2026** — this file
  described only the GitHub half, so that is all that got done, and Ken was still being
  offered v89. Both halves are one act. `release-designer.mjs` does both; do not do
  either by hand.

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
has verified the `CHANGELOG.md` contents.** That single command authorizes the whole thing
**through both pushes** — Claude runs it end to end and does **not** pause for a second
confirmation.

**Claude runs one command and nothing else:**

```
node scripts/release-designer.mjs        # in the keyguard-web folder
```

Add `--dry-run` to print the plan and change nothing. **Do not hand-run the steps below.**
They are here so you can read what the script does and check its work — not as a recipe.
Hand-running them is how v90 went out half-finished on 24 Sep 2026.

Let `N` = the pre-bumped `keyguard_designer_version`.

**Preflight (all of it before the first push, so a failure never leaves one repository
released and the other not):** both repos on `main`; no uncommitted edits to release files;
`N` actually leads the published version; `## Unreleased` has clinician notes (a version is
never advertised without them); the retired app at release 21 can still drive the new file
(`check-old-app-compat.mjs`); and the web app has no unreleased work of its own — see
"What this command must never carry" below.

**Phase 1 — publish the file (the `.scad` repo):**

1. **Finalize the changelog.** Rename the topmost **`## Unreleased (next release)`** heading to
   **`## Version N`**, and add a fresh empty `## Unreleased (next release)` section above it.
2. **Regenerate the manifest** (`publish-scad-version.mjs`) — writes `version: N` and the
   `## Version N` bullets into `latest_scad_version.json`. Confirm the number matches.
3. **Commit** (`keyguard.scad`, `CHANGELOG.md`, `latest_scad_version.json`) as one commit, so
   the file and the manifest say `N` at the same moment.
4. **Push `origin main`.**
5. **Pre-bump.** Increment `keyguard_designer_version` to `N+1`, commit locally, **do not push.**

**Phase 2 — deliver it (the `keyguard-web` repo):** *without this, nothing reaches anyone.*

6. **Wait for GitHub** to actually serve `v N` (the publish step verifies what it fetched
   rather than shipping the wrong bytes).
7. **Publish the designer file** (`publish-designer-file.mjs`) — writes `keyguard_v<N>.scad`
   and `latest_scad_version.json` beside `app.html` and deletes the superseded copy.
8. **Commit and push** just those files. Live within about ten minutes (GitHub Pages
   freshness). Clinicians are offered `N` the next time they open a project.

**No web app release is involved.** `APP_RELEASE`, `CACHE_NAME`, the app's changelog and
`latest_app_version.json` are **not** touched — publishing a keyguard file is not an app
change, and the app does not need to be re-released to deliver one. Both designer files are
deliberately kept **out** of `sw.js`'s `SHELL` precache, so a running app fetches them from
the network every time it checks. (Until 24 Sep 2026 this command also shipped a token app
release, on the belief that it had to. It does not; Ken's call.)

## What this command must never carry

Pushing `keyguard-web`'s `main` deploys **whatever is committed there** — GitHub Pages serves
that branch. So a keyguard delivery must never be the thing that puts unrelated app work in
front of clinicians. `release-designer.mjs` refuses to run when the web app has unreleased
clinician-facing changes of its own, or unpushed commits touching anything but the designer
files, and names what it found. That work deserves its own considered release: say
**"bump keyguard web app"** first, then release the keyguard.

The two phrases are separate and stay separate (Ken, 24 Sep 2026):

| Phrase | Releases |
|---|---|
| **"bump keyguard designer"** | the `.scad` only — published and delivered, no app release |
| **"bump keyguard web app"** | the web app's own work |

## Invariants — do not break these

- **Never push either repository except as part of "bump keyguard designer"** (or, for the app's
  own work, "bump keyguard web app"). Between releases, everything stays as local commits.
- **A release is not finished until Phase 2 is pushed.** Stopping after the GitHub push leaves
  clinicians on the previous version with nothing to show that anything went wrong. Confirm it:
  `latest_scad_version.json` at `keyguard.volksswitch.org` must report `N`, and
  `keyguard_v<N>.scad` must download from there.
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
manifest agree on `main`" rule as a forward release. Then run Phase 2 again so the good version
is the one sitting beside `app.html`: a rollback that stops at GitHub leaves clinicians being
offered the bad file.
