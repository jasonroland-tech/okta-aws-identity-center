# Lab guide: Okta to AWS IAM Identity Center

**Time:** about 90 minutes. **Cost:** free if you create no AWS resources.
**Why this lab:** "cloud IAM" in job posts mostly means federating the company IdP into AWS and mapping groups to least privilege roles. You already do SAML and SCIM daily, so this lab puts AWS behind them.

Uses the Okta org and users from Lab 1. 📸 = screenshot. Redact AWS account IDs and URLs.

## Part 1: AWS setup (20 min)

**1. Create an AWS account** at aws.amazon.com/free. Turn on **MFA for the root user** right away (account menu > Security credentials).
*Why:* root is the break glass account of AWS.

**2. Add a zero spend budget.** Billing > Budgets > Create budget > **Zero spend budget** > your email.
*Why:* you get an email if anything starts costing money.

**3. Enable IAM Identity Center.** Pick region **US East (Ohio)** top right > search IAM Identity Center > Enable (this also creates AWS Organizations).

## Part 2: SAML single sign on (25 min)

**4. Add the Okta app.** Okta admin > Applications > Browse App Catalog > **AWS IAM Identity Center** > Add. Keep it open in one tab.

**5. Swap metadata.** AWS: Identity Center > Settings > Identity source > Actions > **Change identity source** > External identity provider.
- Copy AWS's **ACS URL** and **Issuer URL** into the Okta app's Sign On tab fields. Save.
- In Okta's Sign On tab, download the **IdP metadata** and upload it to AWS. Type ACCEPT and finish.

*Why:* this is the same trust swap as your SendGrid SAML work: each side learns the other's URLs and signing certificate. 📸 the AWS identity source page showing External identity provider.

## Part 3: SCIM provisioning (20 min)

**6. Turn on automatic provisioning in AWS.** Identity Center > Settings > Automatic provisioning > Enable. Copy the **SCIM endpoint** and **access token** (shown once).

**7. Connect Okta.** Okta app > Provisioning tab > Configure API Integration > paste the endpoint and token > Test > Save. Then under To App, enable **Create Users, Update User Attributes, Deactivate Users**.

**8. Push groups.** Create two Okta groups, `AWS-ReadOnly` (add Ava) and `AWS-S3-Analysts` (add Cara). Assign both groups to the app, then use the **Push Groups** tab to push them. 📸 the Push Groups tab showing Active.
*Why:* AWS never gets a password. Okta creates and removes the users and groups.

## Part 4: Least privilege access (15 min)

**9. Create permission sets.** Identity Center > Permission sets > Create:
- `ReadOnly`: predefined **ReadOnlyAccess**, session 1 hour.
- `S3-Analyst`: custom, inline policy from [`docs/s3-analyst-policy.json`](docs/s3-analyst-policy.json), session 1 hour.

**10. Assign groups to the account.** AWS accounts > select your account > Assign users or groups > `AWS-ReadOnly` → ReadOnly, `AWS-S3-Analysts` → S3-Analyst. 📸 the assignments.

## Part 5: Test (10 min)

**11. Sign in as Ava.** Private window > Okta dashboard > AWS IAM Identity Center tile > your account > ReadOnly > Management console. Try to create an S3 bucket: it's denied. 📸 the access denied message.

**12. Offboard.** Remove Ava from `AWS-ReadOnly` in Okta. Refresh Identity Center > Users/Groups: she's gone from the group, and her access is gone. 📸 before and after.

Fill in the README results. Optional stretch: manage the permission sets with Terraform in [`terraform/`](terraform).
