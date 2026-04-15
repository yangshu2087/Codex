# API contract checklist

Use this template before and after backend/API changes. Fill only the fields that apply, but do not omit contract, errors, permissions, data consistency, observability, and regression evidence for high-stakes backend work.

## Task card

- Goal:
- Constraints:
- Non-goals:
- Done criteria:
- Verification commands:

## Contract summary

- Service/module/route/job:
- Callers/consumers:
- Method/event type:
- Request/input shape:
- Response/output shape:
- Side effects:
- Backward compatibility expectations:
- Versioning or migration notes:

## Error semantics

| Case | Status/code/error name | User-visible message | Retryable? | Notes |
|---|---|---|---|---|
| Validation failure |  |  |  |  |
| Auth missing |  |  |  |  |
| Permission denied |  |  |  |  |
| Not found / empty |  |  |  |  |
| Conflict / concurrency |  |  |  |  |
| Provider failure |  |  |  |  |
| Rate limit / quota |  |  |  |  |
| Unknown failure |  |  |  |  |

Recommended internal error names when applicable:

- `missing_credentials`
- `permission_denied`
- `validation_failed`
- `not_found`
- `conflict`
- `rate_limited`
- `provider_untrusted`
- `schema_mismatch`
- `manual_review_required`

## Permissions and auth

- Authentication source:
- Required roles/scopes:
- Ownership/resource checks:
- Tenant/workspace boundary:
- Secret handling:
- External write permission:
- What validation does **not** prove:

## Data consistency

- Persistence layer:
- Transaction boundary:
- Idempotency key or dedupe behavior:
- Concurrency behavior:
- Cache invalidation:
- Queue/event ordering:
- Migration forward path:
- Rollback path:
- Data retention/privacy notes:

## Observability

- Logs:
- Metrics:
- Traces/request IDs:
- Audit events:
- Dashboard or alert:
- User-visible recovery path:
- Explicit none / reason:

## Targeted regression checks

| Check | Command or method | Expected result | Observed result |
|---|---|---|---|
| Typecheck/schema |  |  |  |
| Unit test |  |  |  |
| Route/integration test |  |  |  |
| Migration dry-run |  |  |  |
| API smoke |  |  |  |
| Error-path test |  |  |  |
| Permission test |  |  |  |

## Completion evidence

- Contract evidence:
- Error semantics evidence:
- Permission evidence:
- Data consistency evidence:
- Observability evidence:
- Regression evidence:
- Remaining contract risks:
