# Okta to AWS IAM Identity Center: SAML SSO and SCIM

> **Loom walkthrough:** _link coming soon_

Okta is the source of truth for who can reach AWS. Users sign in through Okta with SAML, Okta creates and removes them in AWS with SCIM, and Okta groups map to least privilege permission sets. No one has an AWS password or a long lived access key.

## What this proves

| Skill | Evidence |
| --- | --- |
| Cloud federation | Okta set as the external identity provider for IAM Identity Center (SAML 2.0) |
| Automated provisioning | SCIM pushes users and groups from Okta to AWS; removal in Okta removes access |
| Least privilege | Two permission sets with 1 hour sessions, assigned to groups only |
| AWS IAM policy | Custom inline policy ([`docs/s3-analyst-policy.json`](docs/s3-analyst-policy.json)) |
| Account security | Root MFA and a zero spend budget on day one |
| Identity as code (stretch) | Permission sets and assignments in [`terraform/`](terraform) |

## Access model

| Okta group | AWS permission set | What it allows | Session |
| --- | --- | --- | --- |
| `AWS-ReadOnly` | ReadOnly | View any service, change nothing | 1 hour |
| `AWS-S3-Analysts` | S3-Analyst | List buckets and read objects only | 1 hour |

```
User ──SAML──> Okta (MFA) ──> AWS access portal ──> account + permission set
Okta ──SCIM──> IAM Identity Center (users, groups)
```

## Results

| Test | Expected | Result |
| --- | --- | --- |
| Ava signs in from Okta tile | Lands in console with ReadOnly | _pending_ |
| Ava creates an S3 bucket | Access denied | _pending_ |
| Groups pushed by SCIM | Both groups appear in Identity Center | _pending_ |
| Ava removed from group in Okta | Access removed in AWS | _pending_ |

## Production notes

- Assign permission sets to member accounts, not the management account.
- Rotate the SCIM access token before it expires (AWS issues it for one year) and track the date.
- Use permission boundaries and Service Control Policies for guardrails across accounts.

## Run it

See [LAB-GUIDE.md](LAB-GUIDE.md).
