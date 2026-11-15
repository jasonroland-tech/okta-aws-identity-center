# Okta to AWS IAM Identity Center: SAML SSO and SCIM

> **Loom walkthrough:** _link coming soon_

Okta is the source of truth for who can reach AWS. Users sign in through Okta with SAML, Okta creates and removes them in AWS with SCIM, and an Okta group maps to a least privilege permission set built from my own IAM policy. No one has an AWS password or a long lived access key.

## What this proves

| Skill | Evidence |
| --- | --- |
| Cloud federation | Okta set as the external identity provider for IAM Identity Center (SAML 2.0) |
| Automated provisioning | SCIM pushes users and groups from Okta to AWS; removal in Okta removes access |
| Least privilege | Custom permission set with a 1 hour session, assigned to a group only |
| AWS IAM policy | Custom inline policy ([`docs/s3-analyst-policy.json`](docs/s3-analyst-policy.json)) |
| Account security | Root MFA and a zero spend budget on day one |
| Identity as code (stretch) | Permission sets and assignments in [`terraform/`](terraform) |

## Access model

| Okta group | AWS permission set | What it allows | Session |
| --- | --- | --- | --- |
| `AWS-S3-Analysts` | S3-Analyst (custom inline policy) | List buckets and read objects only | 1 hour |

```
User ──SAML──> Okta (MFA) ──> AWS access portal ──> account + permission set
Okta ──SCIM──> IAM Identity Center (users, groups)
```

## Results

| Test | Expected | Result |
| --- | --- | --- |
| Ava signs in from Okta tile | Lands in console with S3-Analyst | _pending_ |
| Ava creates an S3 bucket | Access denied | _pending_ |
| Group pushed by SCIM | Appears in Identity Center with Ava | _pending_ |
| Ava removed from group in Okta | Access removed in AWS | _pending_ |

## Production notes

- Assign permission sets to member accounts, not the management account.
- Rotate the SCIM access token before it expires (AWS issues it for one year) and track the date.
- Use permission boundaries and Service Control Policies for guardrails across accounts.

## Run it

See [LAB-GUIDE.md](LAB-GUIDE.md).
