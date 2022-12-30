# webring-starter

Webring Starter is a modern, simple webring that anyone can setup and use!

In the early days of the World Wide Web, webrings were a popular way for people to connect through common interests. People used CGI scripts to run these, but today, a lot can be done with just a few lines of JavaScript on static websites.

## Features

* This starter site is built with Jekyll as a static site and can be run with GitHub Pages **for free**.

* Only a few lines of JavaScript need to be added to member sites, no additional configuration is needed by members.

* It also uses modern interoperability standards, and provides an [Atom RSS](https://validator.w3.org/feed/docs/atom.html) feed of member sites' posts (if they provide an Atom or RSS feed), an [OPML](http://opml.org/) file of the members that folks can subscribe to with their RSS readers, and a [FOAF](http://xmlns.com/foaf/0.1/) file for portability of discovering members.

* No knowledge of JavaScript or Jekyll or Ruby required! Running the site requires tweaking a couple of YAML files and one JSON file, easy enough for most folks without technical know-how.

* Fully customizable. If you do want to tweak the webring, you can use standard Jekyll theming & features.

## Getting Started

1. **Create a fork of this repo.** You can do that by clicking the **Fork** button there at the top of this page. Give it a good name, and make sure "Copy the main branch only" is **checked**.

  * If you're going to be using issues for people to sign up, on GitHub in your new fork go to **Settings** and under **Features** check the box next to "Issues"

2. **Customize the site for your webring.** Edit the following files, commit them, and push them back to your fork of the repo:

  * list.json - This is your list of members, in [JSON format](https://www.json.org/json-en.html). You should remove me and the example and put your own sites in there instead. You'll need to update this file anytime someone new is added to the webring.

  * \_config.yml - You should definitely edit all the values between `# START` and `# END`, including giving your webring a name and description, and filling in the repository path here. If you're planning to use a [custom domain](https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site) configure that here, otherwise you'll need to set the `baseurl` for GitHub Pages (should be the same as your repository name without your username).

3. **Set up automatic deployment.** We recommend you use [GitHub Actions](https://docs.github.com/en/actions) for automatic deployment of your site. Under **Settings** to go **Pages**:

  * If you are using a custom domain for the webring, enter it in the "Custom Domain" box. Make sure you've followed the instructions above for setting up a custom domain in your registrar's DNS settings. Do this and make sure the domain is resolving before proceeding. (If you are not using a custom domain, you do not need to wait.)

  * Under "Build and deployment" for your **Source** select GitHub Actions, and choose the Jekyll Workflow.

  * You'll be prompted to Configure the workflow before committing the new Workflow file. You can commit this as written and it will update the site every time you commit a change to any file and push it to the repo. However you'll probably want to add a couple of lines to refresh the RSS feeds every few hours, to pull the latest blog posts from your network.  Under the `on:` option, below the `push: branches` lines, add these lines, indented two spaces (lines up with "push"):

    ```
      # Runs every six hours
      schedule:
        - cron: '5 */6 * * *'
    ```

    (You can see this how this should appear [on my webring](https://github.com/krusynth/public-interest-tech-webring/blob/main/.github/workflows/jekyll.yml#L14-L15).) Click "Start commit" then "Commit new file" to save this file.


4. **Deploy & test.** After configuring and committing the new file, your site should automatically deploy. From your main repository page click the **Actions** tab and you should see the deployment action running. This takes about a minute. The site should then appear at the url you configured for it - either your custom domain, or the default of `https://your-username.github.io/your-repository-name/`.

5. **Add the webring code to your website.** Go to the **Join** page of your new webring and copy the JavaScript code. Paste this onto your website and you should be up and running immediately!

6. **Add new sites.**  The default text to join tells potential members to open an issue on GitHub to join your new webring, but you can customize this to have folks email you or whatever makes sense for your use case. Note that adding sites is not automatic through GitHub, you'll always need to edit the `list.json` file to add new members. Once you've done so, you do **not** need to issue a new webring script to member sites, they should pick up the new list automatically.

## Customization

The site is a standard Jekyll website, and is running the default `minima` theme. However, you can customize this in any way you would like, using different themes or rearranging pages. [The Public Interest Tech Webring](https://pitwebring.billhunt.dev/) is a good example of how you can use a simple custom theme.

## How the Webring Code Works

There are several key pieces for how the webring works.  The core element is a JavaScript file included on the members sites, which is served from GitHub Pages directly. That file looks up the `list.json` file from GitHub to figure out which members are in the ring, and then determines the next/previous links from the current page.

If the member is using the static version of the code on their site, instead the link goes to the webring's `redirect/` page, which uses the `from` argument in the query string to determine where to redirect to next.

The Jekyll site generates the members list at build time from the `list.json` file. This is done in the `get-feeds.rb` plugin. It then downloads a copy of each member's RSS file, and then merges those into the **Recent Posts** on the homepage as well as the `feed.xml` RSS feed. This feed must override the default inclusion of `jekyll-feed`, which is done through a separate plugin, `feed_generator_override.rb`.