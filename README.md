# ⚠️ Deprecation notice ⚠️

Since Spree 4.3 this extension is deprecated and not needed. Multi Store feature is now built-in into Spree 4.3 and greatly expanded. Please see: https://github.com/spree/spree/discussions/11232

# Multi Domain Store

Part of this extension was pulled into Spree 4.2. With Spree 4.3 full feature set will be available in Spree core. Upgrade process will be as easy as removing the extension from your Gemfile.

This extension allows a single Spree instance to have several customer facing stores, with a single shared backend administration system (i.e. multi-store, single-vendor).

## Current features

1. Each store can have its own layout(s) - these layouts should be located in your site's theme extension in the app/views/spree/layouts/_store#code_/ directory. So, if you have a store with
a code of "alpha" you should store its default layout in app/views/spree/layouts/alpha/spree_application.html.erb

2. Each product can be assigned to one or more stores.

## Installation

1. Add this extension to your Gemfile with this line:

    ```ruby
    gem 'spree_multi_domain', github: 'spree-contrib/spree-multi-domain'
    ```

2. Install the gem using Bundler:

    ```ruby
    bundle install
    ```

3. Copy & run migrations

    ```ruby
    bundle exec rails g spree_multi_domain:install
    ```

4. Restart your server

    If your server was running, restart it so that it can find the assets properly.
