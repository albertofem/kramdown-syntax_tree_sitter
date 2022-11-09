# frozen_string_literal: true

require 'kramdown'
require 'kramdown/syntax_tree_sitter'
require 'minitest/autorun'

PYTHON_STANDARD_MARKDOWN = <<~MARKDOWN
  ~~~python
  print('Hello, World!')
  ~~~
MARKDOWN

PYTHON_TREE_SITTER_MARKDOWN = <<~MARKDOWN
  ~~~source.python
  print('Hello, World!')
  ~~~
MARKDOWN

HTML_TREE_SITTER_MARKDOWN = <<~MARKDOWN
  ~~~text.html.basic
  <strong>The ampersand ('&amp;') should be HTML escaped.</strong>
  ~~~
MARKDOWN

PYTHON_TREE_SITTER_INLINE_MARKDOWN = <<~MARKDOWN
  The code `print('Hello, World!')`{: class="language-source.python" } is valid Python.
MARKDOWN

BAD_SYNTAX_PYTHON_TREE_SITTER_MARKDOWN = <<~MARKDOWN
  ~~~source.python
  print('Hello, World!''"))
  ~~~
MARKDOWN

PYTHON_NO_HIGHLIGHT_HTML = <<~HTML
  <pre><code class="language-python">print('Hello, World!')
  </code></pre>
HTML

PYTHON_ROUGE_HTML = <<~HTML
  <div class="language-python highlighter-rouge"><div class="highlight">\
  <pre class="highlight"><code><span class="k">print</span><span class="p">(</span>\
  <span class="s">'Hello, World!'</span><span class="p">)</span>
  </code></pre></div></div>
HTML

PYTHON_TREE_SITTER_HTML = <<~HTML
  <div class="language-source.python highlighter-tree-sitter">\
  <pre><code>print('Hello, World!')
  </code></pre></div>
HTML

PYTHON_TREE_SITTER_INLINE_HTML = <<~HTML
  <p>The code <code class="language-source.python highlighter-tree-sitter">\
  print('Hello, World!')</code> is valid Python.</p>
HTML

HTML_TREE_SITTER_HTML = <<~HTML
  <div class="language-text.html.basic highlighter-tree-sitter"><pre><code>\
  &lt;strong&gt;The ampersand ('&amp;amp;') should be HTML escaped.&lt;/strong&gt;
  </code></pre></div>
HTML

BAD_SYNTAX_PYTHON_TREE_SITTER_HTML = <<~HTML
  <div class="language-source.python highlighter-tree-sitter">\
  <pre><code>print('Hello, World!''"))
  </code></pre></div>
HTML

PYTHON_MISSING_LANGUAGE_PARSER_MSG = 'Error retrieving language configuration for ' \
                                     "scope 'source.python': Language not found"

TEST_DIR_PATH = File.expand_path File.join(__dir__, '..')
REAL_PARSERS_PATH = File.join TEST_DIR_PATH, 'tree_sitter_parsers'
FAKE_PARSERS_PATH = File.join TEST_DIR_PATH, 'tree_sitter_parsers_fake'

# Helper function for invoking Kramdown to render Markdown into HTML using a
# specific syntax highlighter.
def convert_to_html(markdown, highlighter, highlighter_opts = {})
  Kramdown::Document.new(
    markdown,
    syntax_highlighter: highlighter,
    syntax_highlighter_opts: highlighter_opts
  ).to_html
end

module Kramdown
  class TestSyntaxHighlighting < Minitest::Test
    def test_that_tree_sitter_has_a_version_number
      refute_nil Converter::SyntaxHighlighter::TreeSitter::VERSION
    end

    def test_that_it_can_use_no_highlighting
      actual = convert_to_html PYTHON_STANDARD_MARKDOWN, nil

      assert_equal PYTHON_NO_HIGHLIGHT_HTML, actual
    end

    def test_that_it_can_use_rouge_highlighting
      actual = convert_to_html PYTHON_STANDARD_MARKDOWN, :rouge

      assert_equal PYTHON_ROUGE_HTML, actual
    end

    def test_that_it_can_use_tree_sitter_highlighting
      actual = convert_to_html(
        PYTHON_TREE_SITTER_MARKDOWN,
        :'tree-sitter',
        { tree_sitter_parsers_dir: REAL_PARSERS_PATH }
      )

      assert_equal PYTHON_TREE_SITTER_HTML, actual
    end

    def test_that_it_can_use_tree_sitter_inline_highlighting
      actual = convert_to_html(
        PYTHON_TREE_SITTER_INLINE_MARKDOWN,
        :'tree-sitter',
        { tree_sitter_parsers_dir: REAL_PARSERS_PATH }
      )

      assert_equal PYTHON_TREE_SITTER_INLINE_HTML, actual
    end

    def test_that_it_can_use_tree_sitter_html_escaped_highlighting
      actual = convert_to_html(
        HTML_TREE_SITTER_MARKDOWN,
        :'tree-sitter',
        { tree_sitter_parsers_dir: REAL_PARSERS_PATH }
      )

      assert_equal HTML_TREE_SITTER_HTML, actual
    end

    def test_that_it_can_use_tree_sitter_highlighting_on_bad_syntax
      actual = convert_to_html(
        BAD_SYNTAX_PYTHON_TREE_SITTER_MARKDOWN,
        :'tree-sitter',
        { tree_sitter_parsers_dir: REAL_PARSERS_PATH }
      )

      assert_equal BAD_SYNTAX_PYTHON_TREE_SITTER_HTML, actual
    end

    def test_that_it_fails_gracefully_if_unable_to_locate_tree_sitter_parsers_directory
      actual = assert_raises Exception do
        convert_to_html(
          PYTHON_TREE_SITTER_MARKDOWN,
          :'tree-sitter',
          { tree_sitter_parsers_dir: FAKE_PARSERS_PATH }
        )
      end

      assert_instance_of RuntimeError, actual
      assert_equal PYTHON_MISSING_LANGUAGE_PARSER_MSG, actual.message
    end
  end
end
