# Design Reference Shortlist

Source repo: [VoltAgent/awesome-design-md](https://github.com/VoltAgent/awesome-design-md)

This shortlist is the workspace-approved reference set for current Codex UI work.
Use these references as design-language input, not as a brand-cloning kit.

## Safe local usage

The `DESIGN.md` bodies are now served through the `getdesign` CLI / `getdesign.md` pages rather than stable GitHub `design-md/<brand>/DESIGN.md` blob paths.

Use a pinned CLI version and write references to a non-active folder first:

```bash
cd /path/to/target-repo
mkdir -p docs/design-references
GETDESIGN_DISABLE_TELEMETRY=1 npx getdesign@0.6.2 add vercel --out ./docs/design-references/vercel.DESIGN.md
```

Replace `vercel` with another template id such as `linear.app`, `stripe`, `notion`, or `mintlify`.

Do not run `getdesign add <brand> --force` from `/Users/yangshu/Codex` unless the intent is to overwrite the active workspace `DESIGN.md`. Review the downloaded reference and merge only the relevant guidance into the target repo's own `DESIGN.md`.

## Translation rules for humane UI

Use these references to make product surfaces clearer and more humane, not more ornamental:

- Translate mood into local design tokens: spacing, type scale, surfaces, focus rings, and component states.
- Translate hierarchy into user decisions: the next action, recovery path, and success state should be obvious.
- Translate density into task context: marketing pages can breathe; dashboards should prioritize scanning and fast operation.
- Translate motion into affordance: entrance, hover, and reveal effects must clarify hierarchy or feedback.
- Never copy brand signatures verbatim, including proprietary color combinations, exact typography treatments, product-specific workflow colors, or distinctive hero compositions.

Every front-end task that uses this shortlist should name the 1-2 references used and state the local translation in terms of repo-native components/tokens.

## Selection criteria

The goal was to pick references that match our current mix of:

- AI / developer-tool products
- SaaS marketing pages
- authenticated product shells
- documentation and knowledge surfaces

We optimized for references that are:

- high-signal for AI agents
- strong at layout and hierarchy
- reusable across multiple projects
- less risky than highly distinctive brand worlds

## Top 5 references

### 1. Vercel

Files:

- [repo folder](https://github.com/VoltAgent/awesome-design-md/tree/main/design-md/vercel)
- [current DESIGN.md page](https://getdesign.md/vercel/design-md)
- CLI template id: `vercel`

Why it made the cut:

- best baseline for developer-tool marketing and infrastructure product surfaces
- strong light-mode precision
- excellent border, shadow, and spacing restraint
- useful for hero sections, feature grids, pricing summaries, and polished docs chrome

Use it for:

- landing pages
- product marketing sections
- pricing / trust / feature comparison blocks
- docs homepages

Do not copy literally:

- exact Geist-heavy brand mimicry
- Vercel workflow accent colors all at once

### 2. Linear

Files:

- [repo folder](https://github.com/VoltAgent/awesome-design-md/tree/main/design-md/linear.app)
- [current DESIGN.md page](https://getdesign.md/linear.app/design-md)
- CLI template id: `linear.app`

Why it made the cut:

- strongest reference for dark, authenticated product shells
- excellent information-density discipline
- useful for settings, dashboards, tables, sidebars, and command-heavy flows

Use it for:

- logged-in product areas
- dashboard pages
- issue/task/list/detail layouts
- power-user interaction patterns

Do not copy literally:

- blanket dark mode on all public pages
- brand-indigo overuse

### 3. Stripe

Files:

- [repo folder](https://github.com/VoltAgent/awesome-design-md/tree/main/design-md/stripe)
- [current DESIGN.md page](https://getdesign.md/stripe/design-md)
- CLI template id: `stripe`

Why it made the cut:

- best trust-and-conversion reference in the set
- useful for pricing, forms, payment, enterprise reassurance, and polished CTAs
- strong typography, hierarchy, and commercial clarity

Use it for:

- pricing pages
- onboarding flows
- checkout or billing-related UI
- enterprise trust sections

Do not copy literally:

- premium gradient theatrics everywhere
- overly luxurious styling on utilitarian product pages

### 4. Notion

Files:

- [repo folder](https://github.com/VoltAgent/awesome-design-md/tree/main/design-md/notion)
- [current DESIGN.md page](https://getdesign.md/notion/design-md)
- CLI template id: `notion`

Why it made the cut:

- strongest reference for calm content-heavy experiences
- good for docs, help centers, knowledge bases, and editor-adjacent UIs
- excellent warm-neutral reading surface

Use it for:

- content pages
- help / FAQ / education sections
- editor or note-like surfaces
- knowledge capture / internal docs

Do not copy literally:

- overly soft information density where task execution matters
- exact Notion visual warmth as a default for all products

### 5. Mintlify

Files:

- [repo folder](https://github.com/VoltAgent/awesome-design-md/tree/main/design-md/mintlify)
- [current DESIGN.md page](https://getdesign.md/mintlify/design-md)
- CLI template id: `mintlify`

Why it made the cut:

- best documentation-specific reference
- strong for API docs, developer onboarding, and information hierarchy
- useful for lightweight marketing/docs hybrids

Use it for:

- docs portals
- API reference chrome
- onboarding/tutorial pages
- product documentation landing pages

Do not copy literally:

- green branding as a global default
- excessively soft contrast on dense product UI

## Not selected as default team references

These are useful, but too brand-distinctive for the workspace default layer:

- `cursor`: strong and interesting, but too editorial/warm and too tied to one brand world
- `claude`: useful for warm editorial AI surfaces, but not broad enough for the default team baseline
- `raycast`: good for utility/productivity aesthetics, but too dark-utility-specific for the default layer

Use them only when a project intentionally wants that direction.

## Default blend rules

These blend rules help Codex use the references without producing direct copies.

### Public marketing / devtool landing

- 60% `vercel`
- 20% `stripe`
- 20% `mintlify`
- Humanization focus: short promise, one dominant CTA, proof before decoration, and first viewport that communicates the product without relying on stat strips or generic card grids.

### Authenticated app shell

- 70% `linear.app`
- 20% `vercel`
- 10% `notion`
- Humanization focus: navigation clarity, visible system status, fast task recovery, dense but breathable lists/tables, and one clear accent for state/action.

### Docs / knowledge surfaces

- 50% `mintlify`
- 30% `notion`
- 20% `vercel`
- Humanization focus: readable content width, strong search/onboarding paths, copy that explains prerequisites, and empty/error states that help users continue.

## Agent usage rules

- Always read the repository `DESIGN.md` first.
- Use this shortlist only as inspiration and calibration.
- Explicitly state which 1-2 references are being used for the current task.
- Translate reference styles into local design tokens, spacing, and components.
- Do not clone external brand signatures verbatim.
