# Reusable Github Actions

`devenv-test.yml`: Run all pre-commit hooks via [devenv].

```yaml
# .github/workflows/lint-and-test.yml
name: Lint and Test
on:
  push:
    branches:
      - main
    paths-ignore:
      - "**.md"

jobs:
  devenv-test:
    uses: extrange/actions/.github/workflows/devenv-test.yml@v1.1
```

`build.yml`: Builds a Dockerfile (or a stage of it), caching via AWS ECR. Optionally, pushes the built image to ECR.

```yaml
# .github/workflows/build-and-deploy.yml
name: Build, Push to ECR and Deploy to `dev` K8S Cluster
on:
  push:
    branches:
      - main
    paths-ignore:
      - "**.md"

permissions:
  contents: write
  id-token: write

jobs:
  get-commit-metadata:
    uses: extrange/actions/.github/workflows/commit-metadata.yml@v1.1

  build:
    uses: extrange/actions/.github/workflows/build.yml@v1.1
    needs: get-commit-metadata
    with:
      ecr_repository: chatbot/russell-gpt-web # Change this
      target: deployment
      push: true
      iam_role: ${{ vars.IAM_ROLE }}
      aws_region: ${{ vars.AWS_REGION }}
      build_args: |
        COMMIT_SHA=${{ needs.get-commit-metadata.outputs.sha_short }}
        COMMIT_TIMESTAMP=${{ needs.get-commit-metadata.outputs.timestamp }}
      # You can add extra tags, e.g. the name of a pushed tag
      extra_tags: |
        ${{ github.ref_name }}
```

## Notes

- Naming convention: `${language}-${workflow-name}`.
  - For actions applicable to all languages, omit `${language}`.
- The Github Free plan [doesn't support] organization-level secrets and variables in private repositories.
- Called workflows only see the caller workflow repository's variables and secrets.
- Environment variables set in the `env` context, defined in the called workflow, are [not accessible] in the `env` context of the caller workflow. Use `vars` instead.
- Workflow files cannot [be in folders].

[doesn't support]: https://docs.github.com/en/actions/writing-workflows/choosing-what-your-workflow-does/store-information-in-variables#creating-configuration-variables-for-an-organization
[be in folders]: https://github.com/orgs/community/discussions/10773
[not accessible]: https://docs.github.com/en/actions/sharing-automations/reusing-workflows#limitations
[devenv]: https://devenv.sh
