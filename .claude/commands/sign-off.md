---
description: Record the client's answer on a plod: signed off (with who and when) or rejected (with the reason). Signed-off plods become claimable.
---

1. Signed off: `npm run drill -- approve <plod> --by="Name (Client)" [--on=date]`.
2. Rejected: `npm run drill -- reject <plod> --reason="what the client said"`. Then fix the lines with the driller and `npm run drill -- submit <plod>` again.
3. A signed-off plod cannot be edited. If the client asks for a change after signing, `npm run drill -- reopen <plod>` puts it back to draft and it needs signing again. A plod already on a claim cannot be reopened: credit it on the next claim.
