# Lab guide: Okta to AWS IAM Identity Center

**Time:** 40 to 45 min. **Cost:** free.
**Skills:** cloud federation (SAML), SCIM provisioning, AWS IAM policy, least privilege permission sets, offboarding.

Uses the Okta org from Lab 1. 📸 = screenshot. Redact AWS account IDs and URLs.

## AWS setup (10 min)

**1. AWS account** at aws.amazon.com/free. Turn on **root MFA** (account menu > Security credentials) and create a **Zero spend budget** (Billing > Budgets).
*Why:* root is AWS's break glass account, and the budget emails you if anything costs money.

**2. Enable IAM Identity Center** in **US East (Ohio)**.

## SAML (10 min)

**3. Add the app.** Okta > Applications > Browse App Catalog > **AWS IAM Identity Center** > Add.

**4. Swap metadata.** AWS: Identity Center > Settings > Identity source > Actions > **Change identity source** > External identity provider. Copy AWS's **ACS URL** and **Issuer URL** into the Okta app's Sign On tab and save. Download Okta's **IdP metadata** and upload it to AWS. 📸 identity source = External.
*Why:* same trust swap as your SendGrid SAML work, now with a cloud provider.

## SCIM (10 min)

**5. AWS side.** Settings > Automatic provisioning > Enable. Copy the **SCIM endpoint** and **access token**.

**6. Okta side.** App > Provisioning > Configure API Integration > paste both > Test > Save. To App: enable **Create Users, Update User Attributes, Deactivate Users**.

**7. Push a group.** Create Okta group `AWS-S3-Analysts`, add Ava, assign it to the app, then **Push Groups**. 📸 pushed = Active.

## Least privilege (10 min)

**8. Write the policy.** Identity Center > Permission sets > Create > Custom > `S3-Analyst`, session 1 hour, inline policy from [`docs/s3-analyst-policy.json`](docs/s3-analyst-policy.json).
*Why:* writing your own AWS IAM policy is a skill posts ask for by name. This one can read S3 and nothing else.

**9. Assign it.** AWS accounts > your account > Assign users or groups > `AWS-S3-Analysts` > `S3-Analyst`.

## Test (5 min)

**10. Sign in as Ava** (private window) > Okta tile > account > S3-Analyst > console. Buckets list, but creating one is **denied**. 📸

**11. Offboard.** Remove Ava from the group in Okta and refresh Identity Center: her access is gone. 📸 before and after.
