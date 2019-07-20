# Azure Pipelines Setup

## Identity Setup

* `User` is an entity with a username and password
* `Organization` is an entity that has billing plan, group of projects, teams of `users`, etc.

Follow [Microsoft instructions](https://azure.microsoft.com/en-us/services/devops/pipelines/) to setup free DevOps organization, account, and free project.

 * It may be easier to do it from the GitHub marketplace instead of starting at the Azure website. This is based on the method of authorization you want: personal account OAuth, computer account OAuth, GitHub web app, etc. [GitHub web app](https://docs.microsoft.com/en-us/azure/devops/pipelines/repos/github?view=azure-devops&tabs=yaml#grant-access-to-your-github-repositories) installed into a GitHub organization is the most flexible.
 * If prompted, choose or create a relevant organization. I created `gnucashbuilder` as the organization. Later, additional accounts/users can be added to your organization.
 * I recommend using a sample project to get the initial config and authorization in place.

## Project Setup for GnuCash + Build for v3.5

1. In your Azure organization, create a new *Project*, e.g. `GnuCash`.
   * Ensure this Azure project is *public*
2. Create a new Pipeline if not automatically prompted.
   * When you are viewing your project in the DevOps web UI, the left nav will have a *Pipelines* section. Click it
   * You will see a list of CI Pipelines. Click the *New* button above that list. Select *New build pipeline*
3. Where is your code?
   * GitHub App authorization
     1. Cancel this workflow. Because of a limitation in the Azure Web UI, you need to clone an existing Pipeline that already has the authorization via the GitHub app.
     2. Click on existing demo pipeline. Click 3-dot menu on top-right. Choose clone.
     3. Name `GnuCash 3.5`
     4. Agent pool `Hosted Ubuntu 1604`
     5. YAML file path `/ci/azure-pipelines.v3.5.yml`
     6. Top menu bar, click arrow to the right of *Save & queue* and choose *Save* and again *Save*.
   * OAuth authorization
     1. Click `Github`
     2. Follow the GitHub prompts. I recommend [limiting authorization](https://developer.github.com/apps/differences-between-apps/) to only the repos needed.
4. Click *Pipelines* in the top breadcrumb trail
5. Click the folder icon to the left of the *New* button
6. Click the *GnuCash 3.5* pipeline that you just created
7. Click *Run* in the middle of the right area and then again *Run*
8. The build has started. Click on this new build you started to view progress.
