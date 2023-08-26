require 'net/http'
require 'json'
require 'oga'
require 'feedjira'

module Jekyll
  class GetFeeds < Jekyll::Generator
    safe true
    priority :low

    def generate(site)
      # Use our local list.json file.
      sources = JSON.parse(File.read('list.json'));

      site.data['sites'] = sources['sites']

      site.data['feed'] = Array.new

      site.data['sites'].map! { |entry|
        puts entry['name']

        ### TODO: Enable FOAF checks
        if !entry['rss'] #|| !entry['foaf']
          document = get_document(entry['url']);

          if !entry['rss']
            entry['rss'] = find_feed(document)
          end

          # if !entry['foaf']
          #   entry['foaf'] = get_foaf(document)
          # end
        end

        if entry['rss']
          entry['feed'] = get_feed(entry['rss'], entry)

          if entry['feed']
            puts "Found #{entry['feed'].size()} entries"
            site.data['feed'] += entry['feed']
          else
            puts 'No feed found'
          end
        end

        puts

        entry
      }

      site.data['feed'].sort! do |x,y|
        y['published'] <=> x['published']
      end

      site
    end

    def get_sources(url)
      json = Net::HTTP.get(URI(url))
      data = JSON.parse(json)
    end

    def get_document(url)
      html = Net::HTTP.get(URI(url))
      html = html.encode('iso-8859-1', :invalid => :replace, :undef => :replace, :replace => '')
                 .encode('utf-8', :invalid => :replace, :undef => :replace, :replace => '')
      document = Oga.parse_html(html)
    end

    def find_feed(document)
      puts 'Searching homepage for RSS feed url'

      # Look for a RSS feed first
      link = document.at_xpath('//link[@rel="alternate" and @type="application/rss+xml"]')

      if link
        puts 'Found RSS ' + link['href']
        return link['href']
      end

      # An Atom feed is just as good
      link = document.at_xpath('//link[@rel="alternate" and @type="application/atom+xml"]')
      puts link.inspect
      if link
        puts 'Found Atom ' + link['href']
        return link['href']
      else
        puts 'No feed found'
      end

    end

    def get_feed(url, site)
      results = Array.new

      # We may or may not have a valid url. If we don't, don't worry.
      begin
        rss = Net::HTTP.get(URI(url))
        feed = Feedjira.parse(rss.force_encoding("UTF-8"))
      rescue
        return
      end

      # puts feed

      entries = feed.entries[0..9] # Only get 10 entries per person

      entries.each do |entry|
        # Clean up misconfigured urls
        if (!entry.url.start_with?('http://') && !entry.url.start_with?('https://'))
          entry.url =  site['url'].chomp('/') + entry.url
        end

        result = Hash.new
        result['site_name'] = site['name']
        result['site_url'] = site['url']
        result['title'] = entry.title
        result['published'] = entry.published
        result['url'] = entry.url

        begin
          if entry.content
            result['content'] = entry.content
              .encode('iso-8859-1', :invalid => :replace, :undef => :replace, :replace => '')
              .encode('utf-8', :invalid => :replace, :undef => :replace, :replace => '')
          elsif entry.summary
            result['content'] = entry.summary
              .encode('iso-8859-1', :invalid => :replace, :undef => :replace, :replace => '')
              .encode('utf-8', :invalid => :replace, :undef => :replace, :replace => '')
          else
            result['content'] = ''
            puts entry.title
            puts 'No content'
          end
        rescue
          puts 'Error parsing ' + site['name'] + ' - ' + entry.title
          result['content'] = ''
        end

        # puts result
        results.push(result)
      end

      return results
    end

    def get_foaf(document)
      # Look for a FOAF link
      foaf = document.at_xpath('//link[@rel="meta" and @type="application/rdf+xml" and @title="FOAF"]')
      if foaf
        puts 'FOAF', foaf['href']

        data = Net::HTTP.get(URI(foaf['href']))

        ## TODO: parse RDF into something useful.
      end
    end

  end
end