class Sanitize
  module Config
    whitelist_object_or_embed = lambda do |env|
      node = env[:node]
      name = node.name.to_s.downcase

      return nil unless name == 'param' || name == 'embed'
      return nil unless node.parent.name.to_s.downcase == 'object'

      if name == 'param'
        return nil unless movie_node = node.parent.search('param[@name="movie"]')[0]
        url = movie_node['value']
      elsif name == 'embed'
        url = node['src']
      end

      whitelist_object_urls = SkipEmbedded::InitialSettings['whitelist_object_urls'] || []

      if url && whitelist_object_urls.any? { |whitelist_object_url| url.index(whitelist_object_url) == 0 }
        return {
          :whitelist_nodes => [node, node.parent] + node.parent.children.to_a
        }
      end
    end

    SKIP = {
      :elements => ["a", "abbr", "acronym", "address", "b", "big", "blockquote", "br", "caption", "cite", "code", "dd", "del", "dfn", "div", "dt", "em", "h1", "h2", "h3", "h4", "h5", "h6", "hr", "i", "img", "ins", "kbd", "li", "ol", "p", "pre", "samp", "small", "span", "strike", "strong", "sub", "sup", "table", "tbody", "td", "th", "tr", "tt", "u", "ul", "var"],
      :attributes => {
        :all => ["abbr", "align", "alt", "border", "cellpadding", "cellspacing", "cite", "class", "datetime", "height", "href", "name", "src", "style", "summary", "target", "title", "width", "xml:lang"]
      },
      :protocols => {
        'a' => {'href' => ['ftp', 'http', 'https', 'mailto', :relative]},
        'blockquote' => {'cite' => ['http', 'https', :relative]},
        'img' => {'src' => ['http', 'https', :relative]},
        'q' => {'cite' => ['http', 'https', :relative]}
      },
      :transformers => [whitelist_object_or_embed]
    }
  end
end
