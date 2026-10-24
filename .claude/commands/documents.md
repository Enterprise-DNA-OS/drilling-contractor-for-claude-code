---
description: Render the paperwork from the records, in your brand: plod sheets for client sign-off, progress claims, programme hole summaries.
---

1. `npm run docs` renders every document. One kind: `npm run docs -- plod`, `npm run docs -- claim`, `npm run docs -- hole-summary`.
2. Files land in `docs-out/<kind>/`. Print to PDF from the browser, or attach as is.
3. Business name, colours and the footer come from `brand.json`. A new document type is a new entry in `documents.json`.
