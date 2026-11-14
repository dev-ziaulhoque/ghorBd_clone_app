# DESIGN AUDIT / ডিজাইন অডিট

> Phase 3 · Project: **GhorBD mobile app**
> Status values: `Todo | In Progress | Done | Blocked`

**Phase status:** Done (website-derived) — **no mobile design or Figma received** (AST-017)
**Depends on:** REQUIREMENT_AUDIT.md
**Basis / ভিত্তি:** Screens below come from website pages and links. Visual details (spacing, exact colors, fonts) were **not** extractable from the page text, so they are marked unknown instead of guessed. / ভিজ্যুয়াল ডিটেইল অজানা হলে অনুমান করা হয়নি।

## Screens / স্ক্রিন

Evidence: `Seen` = page content read · `Linked` = only a link seen · `Blocked` = site blocked reading · `Derived` = needed by a seen feature

| ID | Screen | বাংলা | Web route | Linked REQ | Design file | Evidence | Status |
|----|--------|-------|-----------|------------|-------------|----------|--------|
| SCR-001 | Home | হোম | `/` | REQ-001–006, 040, 044, 045 | none (website only) | Seen | Todo |
| SCR-002 | Listings (rent list; also sale/category/verified presets) | তালিকা | `/listings`, `/listings/sale`, `/listings/<type>`, `/listings/verified` | REQ-003, 006–010 | none | Seen | Todo |
| SCR-003 | Filter sheet | ফিল্টার | (panel on `/listings`) | REQ-008 | none | Seen | Todo |
| SCR-004 | Map view | মানচিত্র | `/map` | REQ-011, 012 | none | Seen | Todo |
| SCR-005 | Land listings | জমি | `/land` | REQ-013, 014 | none | Seen | Todo |
| SCR-006 | Listing detail | বিস্তারিত | `/listings/<slug>` | REQ-014–021, 029 | none | Seen | Todo |
| SCR-007 | Report listing sheet | রিপোর্ট | (on detail) | REQ-020 | none | Seen (fields unknown) | Todo |
| SCR-008 | Message / contact sheet | মেসেজ পাঠান | (on detail) | REQ-018, 030 | none | Derived | Todo |
| SCR-009 | Favorites | সেভ | `/favorites` | REQ-022 | none | Linked | Todo |
| SCR-010 | Login | লগইন | `/login` | REQ-023 | none | Blocked | Blocked |
| SCR-011 | Owner registration | মালিক রেজিস্ট্রেশন | `/owner/register` | REQ-024 | none | Blocked | Blocked |
| SCR-012 | Create / edit listing | বিজ্ঞাপন দিন | `/listings/new` | REQ-025, 026, 028 | none | Blocked | Blocked |
| SCR-013 | Dashboard: My listings | আমার বিজ্ঞাপন | `/dashboard` | REQ-027, 029, 032 | none | Linked | Todo |
| SCR-014 | Pricing / plans | প্রাইসিং | `/pricing` | REQ-031, 032, 034 | none | Seen | Todo |
| SCR-015 | Blog list | ব্লগ | `/blog` | REQ-035 | none | Linked | Todo |
| SCR-016 | Blog detail | ব্লগ পোস্ট | `/blog/<slug>` | REQ-035 | none | Linked | Todo |
| SCR-017 | Q&A list | প্রশ্নোত্তর | `/qa` | REQ-036 | none | Seen | Todo |
| SCR-018 | Q&A detail | প্রশ্ন ও উত্তর | `/qa/<slug>` | REQ-036 | none | Linked | Todo |
| SCR-019 | Ask a question | প্রশ্ন করুন | (on `/qa`) | REQ-036 | none | Seen (fields unknown) | Todo |
| SCR-020 | Guides | গাইড | `/guides` | REQ-037 | none | Linked | Todo |
| SCR-021 | Help Center | হেল্প সেন্টার | `/help` | REQ-038 | none | Seen | Todo |
| SCR-022 | About | আমাদের সম্পর্কে | `/about` | REQ-039 | none | Linked | Todo |
| SCR-023 | Contact | যোগাযোগ | `/contact` | REQ-034, 039 | none | Linked | Todo |
| SCR-024 | Privacy Policy | প্রাইভেসি পলিসি | `/privacy` | REQ-039 | none | Linked | Todo |
| SCR-025 | Terms | শর্তাবলী | `/terms` | REQ-039 | none | Linked | Todo |
| SCR-026 | Area page | এলাকা পাতা | `/rent/dhaka/<area>` | REQ-002 | none | Linked | Todo |
| SCR-027 | Division page | বিভাগ পাতা | `/listings/division/<slug>` | REQ-004 | none | Linked | Todo |

## Missing states per screen / অনুপস্থিত স্টেট

All states are `missing` (no design). Known behavior from the website is noted.

| Screen | Loading | Empty | Error | Offline | Validation | Success | Known web behavior |
|--------|---------|-------|-------|---------|------------|---------|--------------------|
| SCR-002 | missing | missing | missing | missing | n/a | n/a | Result count shown on land page ("৩টি জমির বিজ্ঞাপন পাওয়া গেছে") |
| SCR-004 | missing | missing | missing | missing | n/a | n/a | Per-listing notice when no location |
| SCR-006 | missing | n/a | missing | missing | n/a | n/a | Guest sees "login to view number / send message" |
| SCR-007 | n/a | n/a | missing | missing | missing | missing | Fields unknown |
| SCR-010–012 | missing | n/a | missing | missing | missing | missing | Pages blocked |
| SCR-013 | missing | missing | missing | missing | n/a | missing | Edit and archive actions |
| SCR-017 | missing | missing | missing | missing | n/a | n/a | Counts: questions, answers, views |

## Theme / থিম

### Colors / রং
| Token | Hex | Used for | Source |
|-------|-----|----------|--------|
| theme-color (browser bar) | `#0b1017` | Very dark navy/black, likely dark background | AST-001 page meta |
| primary | unknown | | needs design |
| secondary | unknown | | needs design |
| background / surface | unknown (light or dark not confirmed) | | needs design |
| error / success | unknown | | needs design |
| text-primary / secondary | unknown | | needs design |

### Typography / টাইপোগ্রাফি
| Style | Font | Size | Weight | Source |
|-------|------|------|--------|--------|
| all | unknown | unknown | unknown | not extractable |

Fonts provided in `fonts/`? **No.** The app needs a font that renders Bangla properly. Choice is an open question (ISS-005).

### Spacing, radius, elevation
All unknown. Do not guess; take from design or screenshots.

### Icons and images / আইকন ও ছবি
| Asset | Reference | Format | Status |
|-------|-----------|--------|--------|
| Logo mark | `/brand/logo-mark.png` | PNG | URL only, original needed |
| Hero image | `/hero-home.webp` | WebP | URL only |
| Service icons (12) | `/services/land-calculator.png`, `land-share.png`, `inheritance.png`, `age-calculator.png`, `all-land-info.png`, `khatian.png`, `video-service.svg`, `chat-support.png`, `deed-fees.png`, `buy-sell.png`, `land-forms.png`, `satellite-map.png` | PNG/SVG | URL only, originals needed |
| OG image | `/opengraph-image.png` | PNG | Not needed in app |
| Listing photos | `/uploads/<ownerId>/<yyyymmdd>/<file>-w400.webp` | WebP, sized variants | Observed pattern; API will give URLs |

## Cross-check / ক্রস-চেক

| Gap | Detail | Linked ISS |
|-----|--------|------------|
| REQ with no screen | REQ-041–043 are global (toggle, number format, theme) | n/a |
| Screen with no REQ | none | |
| Dark mode | Site theme color suggests dark; light/dark not confirmed | ISS-021 |
| Tablet/responsive | Not provided | ISS-003 |
| Mobile designs | None | ISS-003 |

## Summary / সারসংক্ষেপ
- Screens: 27 (Seen 11, Linked 12, Blocked 3, Derived 1; counted by evidence column)
- Orphan screens: 0
- Screens with a real mobile design: 0
- Theme values confirmed: 1 (`#0b1017`)
