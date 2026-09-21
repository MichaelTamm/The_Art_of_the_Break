#!/usr/bin/env bash
set -euxo pipefail

# Prerequisites: create MichaelTamm/The_Art_of_the_Break on GitHub and install:
# - Google Cloud CLI: https://cloud.google.com/sdk/docs/install
# - GitHub CLI: https://cli.github.com/
# Sign in with accounts that can administer the Firebase project and repository.
# > gcloud auth login
# > gh auth login

# This creates an OIDC deployment identity, not a service-account key ...

PROJECT_ID="the-art-of-the-break"
GITHUB_REPOSITORY="MichaelTamm/The_Art_of_the_Break"
SERVICE_ACCOUNT="github-hosting-deployer@${PROJECT_ID}.iam.gserviceaccount.com"
PROJECT_NUMBER="$(gcloud projects describe "${PROJECT_ID}" --format='value(projectNumber)')"
REPOSITORY_ID="$(gh api "repos/${GITHUB_REPOSITORY}" --jq '.id')"
REPOSITORY_OWNER_ID="$(gh api "repos/${GITHUB_REPOSITORY}" --jq '.owner.id')"

gcloud services enable \
  iam.googleapis.com \
  iamcredentials.googleapis.com \
  sts.googleapis.com \
  cloudresourcemanager.googleapis.com \
  firebase.googleapis.com \
  firebasehosting.googleapis.com \
  serviceusage.googleapis.com \
  --project="${PROJECT_ID}"

gcloud iam service-accounts create github-hosting-deployer \
  --project="${PROJECT_ID}" \
  --display-name="GitHub Firebase Hosting deployer"

gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --member="serviceAccount:${SERVICE_ACCOUNT}" \
  --role="roles/firebasehosting.admin" \
  --condition=None

gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --member="serviceAccount:${SERVICE_ACCOUNT}" \
  --role="roles/serviceusage.serviceUsageConsumer" \
  --condition=None

gcloud iam workload-identity-pools create github-hosting \
  --project="${PROJECT_ID}" \
  --location=global \
  --display-name="GitHub Hosting deployments"

# Numeric IDs prevent a different repository reusing the same name from gaining
# access. Trust is restricted to the deployment workflow on trunk.
gcloud iam workload-identity-pools providers create-oidc github \
  --project="${PROJECT_ID}" \
  --location=global \
  --workload-identity-pool=github-hosting \
  --issuer-uri="https://token.actions.githubusercontent.com" \
  --attribute-mapping="google.subject=assertion.sub,attribute.repository_id=assertion.repository_id,attribute.repository_owner_id=assertion.repository_owner_id,attribute.ref=assertion.ref,attribute.workflow_ref=assertion.workflow_ref" \
  --attribute-condition="assertion.repository_id == '${REPOSITORY_ID}' && assertion.repository_owner_id == '${REPOSITORY_OWNER_ID}' && assertion.ref == 'refs/heads/trunk' && assertion.workflow_ref == '${GITHUB_REPOSITORY}/.github/workflows/deploy-to-firebase-hosting.yml@refs/heads/trunk'"

gcloud iam service-accounts add-iam-policy-binding "${SERVICE_ACCOUNT}" \
  --project="${PROJECT_ID}" \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/github-hosting/attribute.repository_id/${REPOSITORY_ID}"

# The provider resource name is a repository variable, not a secret.
gh variable set GCP_WORKLOAD_IDENTITY_PROVIDER \
  --repo="${GITHUB_REPOSITORY}" \
  --body="projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/github-hosting/providers/github"

# Allow a few minutes for IAM changes to propagate before deploying.
# Protect trunk and the workflow with branch protection or repository rulesets.