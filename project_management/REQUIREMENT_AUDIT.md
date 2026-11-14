# REQUIREMENT AUDIT / রিকোয়ারমেন্ট অডিট

> Phase 2 · Project: **GhorBD mobile app** (app side only)
> Status values: `Todo | In Progress | Done | Blocked`

**Phase status:** Done (website-derived draft) — must be re-checked against the API collection and any client brief
**Depends on:** ASSET_INVENTORY.md
**Basis / ভিত্তি:** Everything below was observed on https://ghorbd.com/ . Nothing is invented. Items not seen on the site are in the "Proposed" table, not in the main table. / সাইটে যা দেখা গেছে শুধু তাই মূল তালিকায়; বাকি প্রস্তাব আলাদা।

## Requirements / রিকোয়ারমেন্ট

Priority: `Must | Should | Could` · `Amb.` = ambiguity (see ISS)

| ID | Feature (EN) | বাংলা | Source | Priority | Status | Amb. |
|----|--------------|-------|--------|----------|--------|------|
| REQ-001 | Home search: tabs (rent / sale / land), area, type, bedrooms, max budget (default ৳50,000) | হোম সার্চ | AST-001 | Must | Todo | |
| REQ-002 | Popular areas shortcuts (Dhanmondi, Uttara, Bashundhara, Mirpur, Gulshan, Banani, Khilgaon, Mohammadpur) | জনপ্রিয় এলাকা | AST-001 | Should | Todo | |
| REQ-003 | Property categories with counts: flat, house, room, hotel, shop, office, land | প্রপার্টি ক্যাটাগরি | AST-001 | Should | Todo | |
| REQ-004 | Browse by division (8 divisions; only Dhaka active, others "coming soon") | বিভাগ ভিত্তিক | AST-001 | Could | Todo | ISS-025 |
| REQ-005 | Featured properties section | ফিচার্ড প্রপার্টি | AST-001 | Should | Todo | |
| REQ-006 | For-sale listings (separate from rent) | বিক্রির জন্য | AST-001, AST-002 | Must | Todo | |
| REQ-007 | Rent listings screen with cards (title, verified badge, price/month, area, beds·baths·sqft, type, posted ago) | ভাড়ার তালিকা | AST-002 | Must | Todo | ISS-014 |
| REQ-008 | Filters: type, area, monthly rent min–max, bedrooms (any,1+,2+,3+,4+), verified only | ফিল্টার | AST-002 | Must | Todo | |
| REQ-009 | Sort (default "newest first") | সাজানো | AST-002 | Must | Todo | ISS-008 |
| REQ-010 | Result paging (infinite scroll or pages) | পেজিনেশন | AST-002 | Must | Todo | ISS-009 |
| REQ-011 | Map view: markers, place search, same filters, list panel | মানচিত্র | AST-003 | Must | Todo | ISS-018 |
| REQ-012 | Listings with no coordinates are excluded from map with a notice | লোকেশন না থাকলে নোটিস | AST-003 | Should | Todo | |
| REQ-013 | Land listings: filters area, land type (residential/commercial), price, katha size (1+,2+,3+,5+,10+), verified, sort | জমি লিস্টিং | AST-004 | Must | Todo | |
| REQ-014 | Land fields and units: katha, bigha, road width, dag/khatian number | জমির ফিল্ড ও একক | AST-004 | Must | Todo | ISS-013 |
| REQ-015 | Detail header: gallery, title, address, verified badge, view count, posted ago | বিস্তারিত হেডার | AST-005 | Must | Todo | ISS-019 |
| REQ-016 | Detail facts: type, bedrooms, bathrooms, area (sqft), floor, unit, description, amenities, monthly rent | বিস্তারিত তথ্য | AST-005 | Must | Todo | |
| REQ-017 | Detail map with coordinates and "open large map" | ম্যাপে অবস্থান | AST-005 | Should | Todo | ISS-018 |
| REQ-018 | Contact advertiser: show phone and send message, **both require login** | যোগাযোগ (লগইন লাগবে) | AST-005, AST-007 | Must | Todo | ISS-007, ISS-026 |
| REQ-019 | Safety notice: view property in person, never send advance money | নিরাপত্তা সতর্কতা | AST-005, AST-007 | Must | Todo | |
| REQ-020 | Report a listing (fake, fraud, wrong info) | বিজ্ঞাপন রিপোর্ট | AST-005, AST-007 | Must | Todo | |
| REQ-021 | More listings in the same area | একই এলাকার আরও বিজ্ঞাপন | AST-005 | Should | Todo | |
| REQ-022 | Favorites: save/unsave, favorites screen | পছন্দের তালিকা | AST-001, AST-012 | Must | Todo | ISS-007 |
| REQ-023 | Login | লগইন | AST-010 | Must | Blocked | ISS-002, ISS-006 |
| REQ-024 | Owner registration | মালিক রেজিস্ট্রেশন | AST-009 | Must | Blocked | ISS-002, ISS-006 |
| REQ-025 | Create / edit listing (free) | বিজ্ঞাপন দিন | AST-011 | Must | Blocked | ISS-002 |
| REQ-026 | Photo upload with description | ছবি আপলোড | AST-001, AST-006 | Must | Todo | ISS-027 |
| REQ-027 | Owner dashboard: "My listings", edit, archive | ড্যাশবোর্ড, আমার বিজ্ঞাপন | AST-007, AST-012 | Must | Todo | |
| REQ-028 | Update price, photos, status any time | যেকোনো সময় সম্পাদনা | AST-001 | Must | Todo | |
| REQ-029 | Verified badge: show on listings; owner-side verification flow | যাচাইকৃত ব্যাজ | AST-001, AST-007 | Should | Todo | ISS-011 |
| REQ-030 | Tenant sends interest/message to owner (shown to owner, also by email) | আগ্রহ/মেসেজ পাঠানো | AST-001, AST-007 | Must | Todo | ISS-010 |
| REQ-031 | Show plans: Free, Pro ৳499/mo, Business ৳1,499/mo | প্রাইসিং | AST-006 | Should | Todo | ISS-012 |
| REQ-032 | Free plan limit: up to 3 ads; Pro unlimited | ফ্রি প্ল্যানে ৩টি বিজ্ঞাপন | AST-006 | Must | Todo | ISS-012 |
| REQ-033 | Pro/Business tools: invoice and PDF receipt, rent reminder, building QR, multiple buildings and units, income/expense report and CSV, tenant and contract management | প্রো/বিজনেস টুল | AST-006 | Could | Todo | ISS-012 |
| REQ-034 | Plan purchase (website sends Pro/Business to Contact page, no checkout seen) | প্ল্যান কেনা | AST-006 | Could | Todo | ISS-012 |
| REQ-035 | Blog: list, categories, post detail | ব্লগ | AST-001, AST-013 | Should | Todo | |
| REQ-036 | Q&A: list, categories, search, my questions, ask, answer, view/answer counts | প্রশ্নোত্তর | AST-008 | Should | Todo | ISS-023 |
| REQ-037 | Guides | গাইড | AST-001, AST-014 | Could | Todo | |
| REQ-038 | Help Center FAQ | হেল্প সেন্টার | AST-007 | Should | Todo | |
| REQ-039 | Static pages: About, Contact, Privacy Policy, Terms | সম্পর্কে, যোগাযোগ, প্রাইভেসি, শর্তাবলী | AST-014 | Must | Todo | |
| REQ-040 | Information services tiles (external tools: land calculator, share, inheritance, khatian, deed fees, forms, satellite map, etc.) | তথ্য সেবা | AST-001, AST-020 | Could | Todo | ISS-024 |
| REQ-041 | Language toggle Bangla / English | ভাষা পরিবর্তন | AST-001 | Must | Todo | ISS-028 |
| REQ-042 | Bangla numerals and BDT format with lakh/crore grouping (e.g. ৭২,০০,০০০ ৳) | বাংলা সংখ্যা ও টাকার ফরম্যাট | AST-001 | Must | Todo | |
| REQ-043 | Theme (site theme color `#0b1017`, dark look) | থিম | AST-001 | Should | Todo | ISS-021 |
| REQ-044 | Bottom navigation: Home, Search, Post ad, Saved, Login | নিচের নেভিগেশন | AST-001 | Must | Todo | |
| REQ-045 | "বাড়ি চাই" ("I want a house") button on hero, currently opens map | বাড়ি চাই বাটন | AST-001 | Could | Todo | ISS-017 |

## Proposed (NOT in source — need client approval) / প্রস্তাব (সোর্সে নেই)

| ID | Proposal | Why | Linked ISS |
|----|----------|-----|-----------|
| PRP-001 | In-app account deletion | Play Store and App Store require it when sign-up exists | ISS-022 |
| PRP-002 | Push notifications (new message, listing status) | Mobile expectation | ISS-022 |
| PRP-003 | Share listing | Common on mobile | ISS-022 |
| PRP-004 | Deep links `ghorbd.com/listings/<slug>` to app | Link sharing | ISS-020 |

## Non-functional requirements (proposed, need confirmation) / নন-ফাংশনাল

| ID | Area | Requirement | Priority |
|----|------|-------------|----------|
| NFR-001 | Security | Tokens only in secure storage; single-flight refresh on 401 | Must |
| NFR-002 | Security | Phone reveal and message are login-gated; handle rate-limit errors cleanly | Must |
| NFR-003 | Security | No tokens, phone numbers or passwords in logs | Must |
| NFR-004 | Security | Validate and sanitize user text (messages, Q&A, listing description); validate image type and size before upload | Must |
| NFR-005 | Security | SSL pinning (production), root/jailbreak warning on sensitive actions | Should |
| NFR-006 | Security | Session idle timeout, logout clears all user data and caches | Should |
| NFR-007 | Security | Strip location metadata (EXIF) from uploaded photos before upload | Should |
| NFR-008 | Performance | Use sized image variants (site uses `-w400.webp`), cached images, list paging | Must |
| NFR-009 | Offline | Show clear offline and retry states; cache last listing page | Should |
| NFR-010 | Localization | All text via ARB files; Bangla default, English secondary | Must |
| NFR-011 | Accessibility | Bangla text scaling, tap targets, contrast | Should |

## Use Case Journeys / ইউজার জার্নি

Legend: CAP-xx are API capabilities (see API_AUDIT.md). Real endpoints will replace them once the collection arrives.

### UJ-001: First open and guest browse / প্রথমবার অ্যাপ খোলা
| Step | User action | System response | REQ | SCR | CAP |
|------|-------------|-----------------|-----|-----|-----|
| 1 | Opens app | Language set, home loads | REQ-041, REQ-044 | SCR-001 | CAP-08 |
| 2 | Types area, type, bedrooms, budget, taps Search | Results screen | REQ-001 | SCR-001, SCR-002 | CAP-03 |
| 3 | Taps popular area / category | Filtered results | REQ-002, REQ-003 | SCR-002 | CAP-03, CAP-07 |

### UJ-002: Find a rental and contact the owner / ভাড়া খুঁজে মালিকের সাথে যোগাযোগ
| Step | User action | System response | REQ | SCR | CAP |
|------|-------------|-----------------|-----|-----|-----|
| 1 | Applies filters, sorts | Updated list, paging | REQ-007–010 | SCR-002, SCR-003 | CAP-03 |
| 2 | Opens a listing | Detail with facts, map, safety notice | REQ-015–019 | SCR-006 | CAP-04 |
| 3 | Taps "show phone" or "send message" as guest | Login prompt | REQ-018 | SCR-010 | CAP-02 |
| 4 | Logs in, returns to listing | Phone shown / message sheet opens | REQ-018, REQ-030 | SCR-006, SCR-008 | CAP-09, CAP-10 |

### UJ-003: Map search / মানচিত্রে খোঁজা
| Step | User action | System response | REQ | SCR | CAP |
|------|-------------|-----------------|-----|-----|-----|
| 1 | Opens Map | Markers + list panel | REQ-011 | SCR-004 | CAP-05 |
| 2 | Searches a place, applies filters | Map recenters, markers update | REQ-011 | SCR-004 | CAP-05 |
| 3 | Sees listing with no location | Notice shown | REQ-012 | SCR-004 | CAP-05 |

### UJ-004: Land search / জমি খোঁজা
| Step | User action | System response | REQ | SCR | CAP |
|------|-------------|-----------------|-----|-----|-----|
| 1 | Opens Land | Land list | REQ-013 | SCR-005 | CAP-06 |
| 2 | Filters by area, type, price, katha | Updated list | REQ-013, REQ-014 | SCR-005 | CAP-06, CAP-07 |
| 3 | Opens a plot | Detail with land fields | REQ-014–016 | SCR-006 | CAP-04 |

### UJ-005: Save favorites / পছন্দের তালিকা
| Step | User action | System response | REQ | SCR | CAP |
|------|-------------|-----------------|-----|-----|-----|
| 1 | Taps save on a card or detail | Saved (guest behavior unknown) | REQ-022 | SCR-002, SCR-006 | CAP-11 |
| 2 | Opens Saved tab | Favorites list | REQ-022 | SCR-009 | CAP-11 |

### UJ-006: Report a listing / বিজ্ঞাপন রিপোর্ট
| Step | User action | System response | REQ | SCR | CAP |
|------|-------------|-----------------|-----|-----|-----|
| 1 | Taps "report this ad" | Report sheet | REQ-020 | SCR-007 | CAP-12 |
| 2 | Submits | Confirmation | REQ-020 | SCR-007 | CAP-12 |

### UJ-007: Owner registers and posts first ad / মালিক রেজিস্ট্রেশন ও প্রথম বিজ্ঞাপন
| Step | User action | System response | REQ | SCR | CAP |
|------|-------------|-----------------|-----|-----|-----|
| 1 | Taps "post ad" | Register/login if guest | REQ-024, REQ-023 | SCR-011, SCR-010 | CAP-01, CAP-02 |
| 2 | Fills listing form, adds photos, location | Draft/preview (unknown) | REQ-025, REQ-026 | SCR-012 | CAP-13, CAP-14 |
| 3 | Publishes | Listing live, status shown (verification flow unknown) | REQ-025, REQ-029 | SCR-013 | CAP-13, CAP-21 |

### UJ-008: Owner manages listings / মালিকের বিজ্ঞাপন ব্যবস্থাপনা
| Step | User action | System response | REQ | SCR | CAP |
|------|-------------|-----------------|-----|-----|-----|
| 1 | Opens dashboard | "My listings" | REQ-027 | SCR-013 | CAP-15 |
| 2 | Edits price/photos/status or archives | Updated listing | REQ-027, REQ-028 | SCR-012, SCR-013 | CAP-13, CAP-14 |
| 3 | Reaches Free plan limit (3 ads) | Upgrade prompt | REQ-032 | SCR-014 | CAP-16 |

### UJ-009: Q&A and learning / প্রশ্নোত্তর ও গাইড
| Step | User action | System response | REQ | SCR | CAP |
|------|-------------|-----------------|-----|-----|-----|
| 1 | Opens Q&A, searches or filters category | Question list | REQ-036 | SCR-017 | CAP-18 |
| 2 | Opens a question | Answers, view count | REQ-036 | SCR-018 | CAP-18 |
| 3 | Asks a question | Posted (rules unknown) | REQ-036 | SCR-019 | CAP-18 |
| 4 | Reads blog / guide / help | Content screens | REQ-035, 037, 038 | SCR-015, 016, 020, 021 | CAP-17, CAP-19 |

### UJ-010: Plan upgrade / প্ল্যান আপগ্রেড
| Step | User action | System response | REQ | SCR | CAP |
|------|-------------|-----------------|-----|-----|-----|
| 1 | Opens Pricing | 3 plans | REQ-031 | SCR-014 | CAP-16 |
| 2 | Chooses Pro/Business | Website opens Contact page; real flow unknown | REQ-034 | SCR-023 | CAP-16, CAP-20 |

### UJ-011: Logout and session expiry / লগআউট ও সেশন শেষ
| Step | User action | System response | REQ | SCR | CAP |
|------|-------------|-----------------|-----|-----|-----|
| 1 | Logs out, or token refresh fails | Tokens and cached user data cleared, back to guest | NFR-001, NFR-006 | SCR-001 | CAP-02 |

## Summary / সারসংক্ষেপ
- REQ: 45 → Must 27 · Should 12 · Could 6
- Proposed additions: 4 · NFR: 11 · Journeys: 11
- Blocked REQ: 3 (REQ-023, 024, 025) — see ISS-002
