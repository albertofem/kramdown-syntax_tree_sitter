# frozen_string_literal: true

require 'kramdown'

module Kramdown
  module Converter # rubocop:disable Style/Documentation
    module SyntaxHighlighter
      # This highlighter is not yet fully configured to highlight code.
      #
      # Currently it merely escapes the code so that it can be safely inserted into HTML
      # text.
      module TreeSitter
        def self.call(converter, raw_text, _, type, _)
          rendered_text = converter.escape_html raw_text
          # Code blocks are additionally wrapped in HTML code tags
          type == :block ? "<pre><code>#{rendered_text}</code></pre>" : rendered_text
        end
      end
    end

    add_syntax_highlighter(:'tree-sitter', SyntaxHighlighter::TreeSitter)
  end
end