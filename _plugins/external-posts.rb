require 'feedjira'
require 'httparty'
require 'jekyll'
require 'nokogiri'
require 'time'
require 'uri'
require 'fileutils'

module ExternalPosts
  class ExternalPostsGenerator < Jekyll::Generator
    safe true
    priority :high

    def generate(site)
      return if site.config['external_sources'].nil?

      site.config['external_sources'].each do |src|
        puts "Fetching external posts from #{src['name']}:"
        begin
          if src['rss_url']
            fetch_from_rss(site, src)
          elsif src['posts']
            fetch_from_urls(site, src)
          end
        rescue StandardError => e
          Jekyll.logger.warn("ExternalPosts:", "Failed to fetch '#{src['name']}' (#{e.class}: #{e.message})")
        end
      end
    end

    def fetch_from_rss(site, src)
      xml = HTTParty.get(src['rss_url']).body
      return if xml.nil?
      feed = Feedjira.parse(xml)
      process_entries(site, src, feed.entries)
    rescue StandardError => e
      Jekyll.logger.warn("ExternalPosts:", "Failed to fetch RSS #{src['rss_url']} (#{e.class}: #{e.message})")
    end

    def process_entries(site, src, entries)
      entries.each do |e|
        puts "...fetching #{e.url}"
        create_document(site, src['name'], e.url, {
          title: e.title,
          content: e.content,
          summary: e.summary,
          published: e.published
        })
      end
    end

    def create_document(site, source_name, url, content)
      # Define slug
      if content[:title].gsub(/[^\w]/, '').strip.empty?
        slug = "#{source_name.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')}-#{url.split('/').last}"
      else
        slug = content[:title].downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
        slug = "#{source_name.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')}-#{url.split('/').last}" if slug.empty?
      end
    
      posts_path = posts_dir(site)
      FileUtils.mkdir_p(site.in_source_dir(posts_path))
      path = site.in_source_dir(posts_path, "#{slug}.md")
    
      doc = Jekyll::Document.new(
        path, { :site => site, :collection => site.collections['posts'] }
      )
    
      doc.data['external_source'] = source_name
      doc.data['title']        = content[:title]
      doc.data['feed_content'] = content[:content]
      doc.data['date']         = content[:published]
      doc.data['redirect']     = url
    
      # Save the intro if present
      doc.data['intro'] = content[:intro] if content[:intro]
    
      # Overwrite the description with the intro if provided
      if content[:intro]
        doc.data['description'] = content[:intro]
      else
        doc.data['description'] = content[:summary]
      end
    
      site.collections['posts'].docs << doc
    end
    

    def fetch_from_urls(site, src)
      src['posts'].each do |post|
        puts "...fetching #{post['url']}"
        content = fetch_content_from_url(post['url'])
        next unless content
        content[:published] = parse_published_date(post['published_date'])

        # ADDED: If there's an intro, store it in content[:intro]
        #        and optionally override the entire fetched content with the intro.
        if post['intro']
          content[:intro] = post['intro']

          # If you want the final post to ONLY display the intro, uncomment:
          # content[:content] = post['intro']
          # content[:summary] = post['intro']
        end

        create_document(site, src['name'], post['url'], content)
      end
    end

    def parse_published_date(published_date)
      case published_date
      when String
        Time.parse(published_date).utc
      when Date
        published_date.to_time.utc
      else
        raise "Invalid date format for #{published_date}"
      end
    end

    def fetch_content_from_url(url)
      html = HTTParty.get(url).body
      parsed_html = Nokogiri::HTML(html)
    
      # 1) Try og:title
      og_title = parsed_html.at('meta[property="og:title"]')&.attr('content')&.strip
    
      # 2) Try twitter:title
      twitter_title = parsed_html.at('meta[name="twitter:title"]')&.attr('content')&.strip
    
      # 3) Fallback to the <title> tag
      doc_title = parsed_html.at('head title')&.text&.strip
    
      # 4) Fallback to the first <h1> in the body
      h1_title = parsed_html.at('h1')&.text&.strip
    
      # Pick the first non-empty candidate
      final_title = og_title unless og_title.nil? || og_title.empty?
      final_title ||= twitter_title unless twitter_title.nil? || twitter_title.empty?
      final_title ||= doc_title unless doc_title.nil? || doc_title.empty?
      final_title ||= h1_title unless h1_title.nil? || h1_title.empty?
      final_title ||= "No title found"

      # If Notion's generic title is found, parse from the URL
      notion_generic_titles = [
        "Your connected workspace for wiki, docs & projects | Notion",
        "Notion - The all-in-one workspace for your notes, tasks, wikis, and databases."
      ]
      if notion_generic_titles.include?(final_title) || final_title.include?("Notion")
        parsed_title = parse_title_from_notion_url(url)
        final_title = parsed_title unless parsed_title.nil? || parsed_title.empty?
      end
    
      # For summary/description
      description = parsed_html.at('head meta[name="description"]')&.attr('content') || ''
    
      # For the post content
      body_content = parsed_html.at('body')&.inner_html || ''
    
      {
        title: final_title,
        content: body_content,
        summary: description
      }
    rescue StandardError => e
      Jekyll.logger.warn("ExternalPosts:", "Failed to fetch #{url} (#{e.class}: #{e.message})")
      nil
    end

    # Helper method to parse Notion title from URL slug
    def parse_title_from_notion_url(url)
      uri = URI(url)
      path = uri.path
      path = path[1..-1] if path.start_with?('/')
      parts = path.split('-')
      # If the last part looks like a Notion ID, remove it
      last_part = parts.last
      if last_part&.match?(/\A[a-f0-9\-]+(\?.*)?\z/i)
        parts.pop
      end
      parts.join(' ')
    end

    private

    def posts_dir(site)
      base = site.config['collections_dir']
      base = base.nil? || base.empty? ? '' : base
      File.join(base, '_posts')
    end

  end
end
