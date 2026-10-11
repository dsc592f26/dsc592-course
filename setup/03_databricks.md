# Step 3: Databricks Free Edition

We use **Databricks Free Edition**: a free, personal Databricks workspace for learning.
You don't need an Azure account or a credit card.

## Sign up

1. Go to https://www.databricks.com/learn/free-edition and click **Sign up**.
2. Sign up with your **UNCW Microsoft account** (Continue with Microsoft) or your UNCW email.
   Use the same account all semester.
3. Wait for your workspace to be created (usually a minute or two). It opens automatically.

Bookmark your workspace URL. To get back later, sign in at the same page.

## Check

In the left sidebar you should see **Workspace**, **Catalog**, **SQL Editor**, and **Jobs & Pipelines**.

1. Open **SQL Editor**.
2. Run:
   ```sql
   SELECT current_user(), current_catalog();
   ```
3. You should see your email and a catalog name. That's it for now.

## Good to know

- **Quotas.** Free Edition has daily compute limits. If you go over, compute pauses until the next day,
  so don't leave long jobs running and start labs early rather than the night before.
- **Serverless only.** You never create or size clusters; compute starts when you run something.
- **Non-commercial use only.** It's for learning, which is exactly what we're doing.
- **The UI changes often.** If a menu in the slides looks different, look for the same word nearby,
  or ask.
