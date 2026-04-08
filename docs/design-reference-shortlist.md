# Design Reference Shortlist

Source repo: [VoltAgent/awesome-design-md](https://github.com/VoltAgent/awesome-design-md)

This shortlist is the workspace-approved reference set for current Codex UI work.  
Use these references as design-language input, not as a brand-cloning kit.

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
- [DESIGN.md](https://github.com/VoltAgent/awesome-design-md/blob/main/design-md/vercel/DESIGN.md)

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
- [DESIGN.md](https://github.com/VoltAgent/awesome-design-md/blob/main/design-md/linear.app/DESIGN.md)

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
- [DESIGN.md](https://github.com/VoltAgent/awesome-design-md/blob/main/design-md/stripe/DESIGN.md)

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
- [DESIGN.md](https://github.com/VoltAgent/awesome-design-md/blob/main/design-md/notion/DESIGN.md)

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
- [DESIGN.md](https://github.com/VoltAgent/awesome-design-md/blob/main/design-md/mintlify/DESIGN.md)

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

### Authenticated app shell

- 70% `linear.app`
- 20% `vercel`
- 10% `notion`

### Docs / knowledge surfaces

- 50% `mintlify`
- 30% `notion`
- 20% `vercel`

## Agent usage rules

- Always read the repository `DESIGN.md` first.
- Use this shortlist only as inspiration and calibration.
- Explicitly state which 1-2 references are being used for the current task.
- Translate reference styles into local design tokens, spacing, and components.
- Do not clone external brand signatures verbatim.
