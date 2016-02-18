require 'tempfile'

module Jekyll
  class VimHighlightBlock < Liquid::Block
    # The regular expression for params (taken from highlight tag).
    # - Start with the file extension.
    # - Follow that by zero or more space separated options that take one
    #   of three forms: name, name=value, or name="<quoted list>"
    #
    # <quoted list> is a space-separated list of numbers
    PARAMS = /^([a-zA-Z0-9.+#-]+)((\s+\w+(=(\w+|"([0-9]+\s)*[0-9]+"))?)*)$/

    def initialize(tag_name, markup, tokens)
      super

      if markup.strip =~ PARAMS
        @file_extension = Regexp.last_match(1).downcase
        @highlight_options = {}
        if defined?(Regexp.last_match(2)) && Regexp.last_match(2) != ''
          # Split along 3 possible forms -- key="<quoted list>", key=value, or key
          Regexp.last_match(2).scan(/(?:\w="[^"]*"|\w=\w|\w)+/) do |opt|
            key, value = opt.split('=')
            # If a quoted list, convert to array
            if value && value.include?("\"")
              value.delete!('"')
              value = value.split
            end
            @highlight_options[key.to_sym] = value || true
          end
        end
        @highlight_options[:linenos] = "inline" if @highlight_options.key?(:linenos) && @highlight_options[:linenos] == true
      else
        raise SyntaxError.new <<-eos
Syntax Error in tag 'vim_highlight' while parsing the following markup:
        #{markup}
Valid syntax: vim_highlight <file_extension> [linenos]
        eos
      end
    end

    def render(context)
      code = super.to_s.gsub(/\A(\n|\r)+|(\n|\r)+\z/, '')
      add_code_tag(render_with_vim(code))
    end

    def render_with_vim(code)
      output = vim_output(code)
      needle = 'vimCodeElement'
      start_position = output.index(needle) + needle.length + 2
      end_position = output.index('</pre>') - 1
      output[start_position..end_position]
    end

    def vim_output(code)
      tempfile = Tempfile.new(['vimhighlight-temp', '.' + @file_extension])
      tempfile.write(code)
      tempfile.close
      vim_to_html(tempfile.path)
      IO.read(tempfile.path + '.html')
    end

    def vim_output2(code)
      hash = Digest::MD5.hexdigest(code)
      file_path = File.join(Dir.tmpdir(), hash + '.' + @file_extension)
      IO.write(file_path, code)
      vim_to_html(file_path)
      puts 'vim completed'
      IO.read(file_path + '.html')
    end

    def vim_to_html(file_path)
      `gvim -f +"syn on" +"run! syntax/2html.vim" +"wq" +"q" #{file_path}`
    end

    def add_code_tag(code)
      "<figure class=\"highlight\"><pre><code>#{code.chomp}</code></pre></figure>"
    end
  end
end

Liquid::Template.register_tag('vim_highlight', Jekyll::VimHighlightBlock)
