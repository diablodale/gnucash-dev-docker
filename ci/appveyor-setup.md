# AppVeyor CI Setup

## User and Account setup

* `User` is an entity with a username and password
* `Account` is an entity that has billing plan, group of projects, and a team of `users`

1. Follow the [AppVeyor](https://www.appveyor.com/) new user setup.
2. Visit the user profile area on the AppVeyor website
3. Click `Security` settings and enable Two-Factor authentication (2FA)
4. Click `API keys`. Here is where you generate API keys. You will need a key later in this setup.
5. If you are the first GnuCash user on AppVeyor, then create a new `Account`
   * Name `gnucashbuilder`
   * Timezone `UTC`
   * Authorizations `GitHub App`. Choice depends on how CI is integrated/not into GnuCash git repo
   * Security `Require 2FA`
   * Billing for this `account` can be free as it is for the GnuCash FOSS project. Contact the AppVeyor team as needed.

## Project setup

Below are three project examples; each showing how to control the specific OS used for the build
and the specific GnuCash code to compile. Often, the only changes are the environment
variables `GNC_GIT_CHECKOUT` and list of `OS_DISTTAG`.

* `OS_DISTTAG` declares the docker image `gnucashbuilder:${OS_DISTTAG}` to use for the build
* `GNC_GIT_CHECKOUT` is utilized by the Docker files; it  supports any
  term you can use on `git checkout ${GNC_GIT_CHECKOUT}` such as a branch, tag, commit hash, etc.

### GnuCash 3.5, fourteen operating systems, built 5th of every month

Monthly compiles of stable releases can be useful to validate dependencies
such as updated packages, OS patches, date/time handling (Y2K), etc.

* General settings
  * Project name `gnucash-3.5`
  * GitHub repository `diablodale/gnucash-dev-docker`  
    *Choice depends how these CI files are integrated/not into main GnuCash repo.*
  * Default branch `master`  
    *Choice depends on branch you desire for manual UI and cron scheduled builds. And what branch contains the `appveyor.yml` you want and how it relates to setting `Custom configuration .yml file name/location`.*
  * Do not build tags `selected`
  * Build schedule `22 22 5 * *`  
    *Contact the AppVeyor team and briefly describe your need for scheduled builds*
  * Custom configuration .yml file name `ci/appveyor.yml`
  * Rolling builds `selected`
  * Save build cache in Pull Requests `selected`
  * Do not build on "Push" events `selected`
  * Do not build on "Pull request" events `selected`
  * Click (Save) at the bottom
* Environment settings
  * Environment variables  
    * `GNC_GIT_CHECKOUT = 3.5`  
    * *Only if docker builder images are in secure registry*  
      `DOCKERHUBPW = <Click lock icon, then type/paste in password>`
  * Click (Save) at the bottom
* Optionally, update AppVeyor project URL.
  * AppVeyor may provide a random project URL, e.g.  
    `.../gnucashbuilder/gnucash-repo-mrg3f`  
    If it does, you can update it to have a clean URL e.g.  
    `.../gnucashbuilder/gnucash-3-5`
  * Edit the settings inside `ci/appveyor-update-project-slug.sh` and execute on
    a Linux computer. You get the API key from step 4 of `user` setup above.

### GnuCash 3.6, fourteen operating systems, built 6th of every month

Same settings as above except the following:

* General settings
  * Project name `gnucash-3.6`
  * Build schedule `22 22 6 * *`
  * Click (Save) at the bottom
* Environment settings
  * Environment variables  
    * `GNC_GIT_CHECKOUT = 3.6`  
  * Click (Save) at the bottom

### GnuCash maint branch, fourteen operating systems, built each day

Same settings as above except the following:

* General settings
  * Project name `gnucash-maint`
  * Build schedule `40 5 * * *`  
  * Click (Save) at the bottom
* Environment settings
  * Environment variables  
    * `GNC_GIT_CHECKOUT = maint`  
  * Click (Save) at the bottom

### GnuCash commit and pull request validation/integration

* This is best integrated by enabling the AppVeyor GitHub App (webhooks, etc.)
  on the main GnuCash repo so that GitHub will notify AppVeyor on pushes, commits, PRs, etc.
* Due to AppVeyor bug, a separate appveyor.yml is necessary to limit the number of operating systems.
* Optionally, including (or submodule integrating) these CI files into the main GnuCash repo.
