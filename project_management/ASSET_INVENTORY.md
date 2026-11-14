# ASSET INVENTORY / সম্পদ তালিকা

> Phase 1 · Project: **GhorBD mobile app** (Flutter + Dio + BLoC, app side only)
> প্রজেক্ট: **ঘরবিডি মোবাইল অ্যাপ** (শুধু অ্যাপ সাইড)
> Status values: `Todo | In Progress | Done | Blocked`
> File status: `usable | unclear | missing`

**Phase status:** Done (website pass + client API documentation received)
**Last updated:** 2026-11-14
**Source basis / সোর্স:** Live website https://ghorbd.com/ (read-only audit) AND `client_assets/api_docs/GhorBd Documentation/` (Postman collection, OpenAPI 3.0.3 spec, environments, HTML reference, integration README). Mobile UI designs and PRD documents are not yet received.

## Rules for the AI / নিয়ম
1. List every source. Do not skip any. / প্রতিটি সোর্স তালিকাভুক্ত করো।
2. Write what is actually inside, not what the name suggests. / ভেতরে যা আছে তাই লেখো।
3. Unreadable or not-yet-received source → `unclear` or `missing`, and add an ISS entry. / পড়া না গেলে বা না পেলে ISS বানাও।
4. IDs never change. / ID কখনো বদলাবে না।

## Inventory / তালিকা

| ID | Source | Type | Folder | Contents summary (EN) | বিষয়বস্তু (বাংলা) | Status |
|----|--------|------|--------|-----------------------|--------------------|--------|
| AST-001 | https://ghorbd.com/ (Home) | Web page | live site | Hero search (rent/sale/land tabs), popular areas, 7 categories, 8 divisions (only Dhaka active), featured, for-sale, blog preview, 3-step guide, info services, owner CTA, testimonial, footer | হোম: সার্চ, জনপ্রিয় এলাকা, ক্যাটাগরি, বিভাগ, ফিচার্ড, বিক্রি, ব্লগ, তথ্য সেবা | usable |
| AST-002 | /listings | Web page | live site | Rent listings: list/map toggle, filters (type, area, rent range, bedrooms, verified), sort, cards | ভাড়ার তালিকা, ফিল্টার, সাজানো | usable |
| AST-003 | /map | Web page | live site | Map view with same filters, place search, list panel, "no location" notice | মানচিত্রে খোঁজা | usable |
| AST-004 | /land | Web page | live site | Land for sale: filters (area, land type, price, katha size, verified), sort | জমি বিক্রি, ফিল্টার | usable |
| AST-005 | /listings/<slug> (sample: "২ রুমের ফ্ল্যাট") | Web page | live site | Listing detail: facts, amenities, map coords, advertiser, login-gated contact, safety notice, report, similar listings | বিজ্ঞাপনের বিস্তারিত | usable |
| AST-006 | /pricing | Web page | live site | 3 plans: Free, Pro ৳499/mo, Business ৳1,499/mo (excl. VAT) | প্ল্যান ও দাম | usable |
| AST-007 | /help | Web page | live site | 5 FAQs (cost, verified badge, contact, advance money, edit/delete) | সাধারণ জিজ্ঞাসা | usable |
| AST-008 | /qa | Web page | live site | Q&A list, categories, search, "my questions", ask-question section (only list seen) | প্রশ্নোত্তর (শুধু তালিকা দেখা গেছে) | usable (partial) |
| AST-009 | /owner/register | Web page | live site | **Not readable** — site blocks automated access | পড়া যায়নি (ব্লক) | unclear |
| AST-010 | /login | Web page | live site | **Not readable** — site blocks automated access | পড়া যায়নি (ব্লক) | unclear |
| AST-011 | /listings/new | Web page | live site | **Not readable** — site blocks automated access | পড়া যায়নি (ব্লক) | unclear |
| AST-012 | /dashboard, /favorites | Web page | live site | Linked only; likely login-gated; not read | লিংক আছে, পড়া হয়নি | unclear |
| AST-013 | /blog | Web page | live site | Seen only as home preview: 6 posts, categories (land/law/deed/inheritance/news) | শুধু হোমের প্রিভিউ | unclear |
| AST-014 | /guides, /about, /contact, /privacy, /terms | Web page | live site | Linked only; not read | লিংক আছে, পড়া হয়নি | unclear |
| AST-015 | Brand assets by URL: `/brand/logo-mark.png`, `/hero-home.webp`, `/services/*.png`, `/opengraph-image.png` | Image refs | live site | Logo, hero, 12 service icons referenced; **originals not received** | লোগো, হিরো, আইকন (মূল ফাইল নেই) | unclear |
| AST-016 | Backend API collection | API collection & docs | `client_assets/api_docs/GhorBd Documentation/` | Complete backend API package: 116 requests in 15 folders (Postman), OpenAPI 3.0.3 specification (88 paths), 3 environments, HTML reference, and mobile integration README. | সম্পূর্ণ ব্যাকএন্ড এপিআই প্যাকেজ: ১১৬টি পোস্টম্যান রিকোয়েস্ট, ওপেনএপিআই ৩.০.৩, ৩টি এনভায়রনমেন্ট, এইচটিএমএল রেফারেন্স ও ইন্টিগ্রেশন রিডমি | usable |
| AST-017 | Design files (Figma / mobile screens) | Design | designs | **Not received** | মোবাইল ডিজাইন নেই | missing |
| AST-018 | Fonts | Font files | fonts | **Unknown.** Website font not identified | ফন্ট অজানা | missing |
| AST-019 | Requirement documents (PRD/brief) | Document | documents | **Not received** | রিকোয়ারমেন্ট ডকুমেন্ট নেই | missing |
| AST-020 | External tool sites: bhumibd.com, uttoradhikar.org | Web (external) | live site | Home "তথ্য সেবা" tiles open these in a new tab; **not part of GhorBD itself** | বাইরের সাইট, আলাদা | unclear |
| AST-021 | ghorbd-openapi.json | OpenAPI 3.0.3 spec | `client_assets/api_docs/GhorBd Documentation/` | Machine-readable OpenAPI 3.0.3 specification with 88 paths, schemas for User, Listing, Document, Notification, Question, Answer, Comment, etc., security schemes, and validation rules | মেশিন-রিডেবল ওপেনএপিআই ৩.০.৩ স্পেসিফিকেশন (৮৮টি পাথ, স্কিমা, ভ্যালিডেশন) | usable |
| AST-022 | GhorBD.postman_collection.json | Postman collection v2.1 | `client_assets/api_docs/GhorBd Documentation/` | 116 requests across 15 folders with request headers, parameters, body payloads, saved success & error response examples, and token-saving test scripts | পোস্টম্যান কালেকশন (১১৬টি রিকোয়েস্ট, ১৫টি ফোল্ডার, এক্সাম্পল সহ) | usable |
| AST-023 | GhorBD.*.postman_environment.json | Postman environments | `client_assets/api_docs/GhorBd Documentation/` | 3 environments: Local (`http://localhost:5000/api`), Production (`https://ghorbd.com/api`), Staging (placeholder). Defines token/id variables | ৩টি পোস্টম্যান এনভায়রনমেন্ট (লোকাল, প্রোডাকশন, স্টেজিং) | usable |
| AST-024 | ghorbd-api-reference.html | HTML reference | `client_assets/api_docs/GhorBd Documentation/` | Standalone, offline searchable single-page HTML documentation covering guide and every endpoint with examples | অফলাইন সার্চযোগ্য এইচটিএমএল এপিআই রেফারেন্স | usable |
| AST-025 | README.md (Integration Guide) | Markdown doc | `client_assets/api_docs/GhorBd Documentation/` | 453-line mobile integration guide: base URLs, headers, 3-part response contract, auth/OTP, JWT lifetimes, pagination/filtering, rate limits, 11 backend gaps | মোবাইল অ্যাপ ইন্টিগ্রেশন গাইড ও নিয়মাবলী | usable |
| AST-026 | client_assets/screenshots/ | Folder | `client_assets/screenshots/` | Directory created for screen captures. **Currently empty**; waiting for client screenshots of blocked pages | স্ক্রিনশট ফোল্ডার (বর্তমানে খালি) | unclear |

## Expected but missing / প্রত্যাশিত কিন্তু নেই

| What is missing | Why expected | Linked ISS |
|-----------------|--------------|------------|
| Login / register / create-listing screenshots | Core owner journey; web pages block automated access (`client_assets/screenshots/` is empty) | ISS-002 |
| Mobile design or Figma | App UI layout, spacing, components | ISS-003 |
| Brand originals (logo, icons) | High-res vector logo, app icon, splash, store listing assets | ISS-005 |
| PRD / Functional specifications | Edge-case rules, payment/monetization strategy | ISS-008 |

## Summary / সারসংক্ষেপ
- Total sources: 26
- usable: 14 (AST-001 to AST-008, AST-016, AST-021 to AST-025)
- unclear: 9 (AST-009 to AST-015, AST-020, AST-026)
- missing: 3 (AST-017, AST-018, AST-019)
