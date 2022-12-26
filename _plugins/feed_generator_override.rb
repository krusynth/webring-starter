# This plugin disables the jekyll-feed plugin automatically included by minima
# We use a custom feed generator instead.

module JekyllFeed
  class Generator < Jekyll::Generator
    safe true
    priority :lowest

    # Main plugin action, called by Jekyll-core
    def generate(_site)
    end
  end
end