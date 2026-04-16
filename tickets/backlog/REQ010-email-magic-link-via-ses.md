---
id: REQ010
title: Email magic link delivery via AWS SES
priority: P0
status: backlog
estimate: M
area: backend
epic: EPIC-02 Auth & Magic Links
depends_on: [REQ003, REQ009]
---

## Problem
We need to actually deliver magic links to user inboxes. SES is our email channel for transactional auth and notification emails.

## User Story
As a director, I want a magic link in my inbox within seconds of requesting it, so that I can sign in without delay.

## Acceptance Criteria
- [ ] `backend/internal/email/ses.go` exports `Sender` with `SendMagicLink(ctx, to, link string, purpose string) error` and a generic `Send(ctx, msg Message) error`.
- [ ] Uses AWS SDK v2 (`github.com/aws/aws-sdk-go-v2/service/sesv2`).
- [ ] Templates live in `backend/internal/email/templates/*.tmpl.html` + `.tmpl.txt`. Both plain-text and HTML multipart.
- [ ] Magic link template includes: clear "Sign in to ComplianceKit" heading, the link button, expiration notice ("expires in 15 minutes"), a "did not request this?" footer.
- [ ] `From` address is `no-reply@compliancekit.com` (configurable via `SES_FROM_EMAIL`).
- [ ] Reply-to set to `support@compliancekit.com`.
- [ ] SES bounce + complaint SNS endpoint handled at `POST /webhooks/ses` — logs the event and (for complaints) suppresses the address.
- [ ] Retries on throttle (5xx) with exponential backoff, max 3 attempts.
- [ ] Unit tests use a fake `sesv2.Client` interface; integration test gated behind `SES_INTEGRATION=1`.

## Technical Notes
- Sandbox mode: production account must request SES production access ahead of launch. Ticket REQ056 covers verification of the sending domain.
- Include `List-Unsubscribe` header only on non-auth emails (chase notifications). Auth emails don't get it.
- Add `X-Ck-Purpose: magic-link` header for observability.
- Use `html/template` for HTML, `text/template` for txt; render both and pass to SES multipart.

## Definition of Done
- [ ] Integration test sends a real email to a test inbox in staging.
- [ ] Bounce + complaint webhook verified end-to-end.
- [ ] Unsubscribe suppressions honored on next send.

## Related Tickets
- Blocks: REQ011, REQ015, REQ043
- Blocked by: REQ003, REQ009
