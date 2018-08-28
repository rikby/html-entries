require 'test/unit'
require 'mocha/test_unit'
require 'nokogiri'
require_relative '../../lib/page'

module HtmlEntry
  class TestPage < Test::Unit::TestCase

    # Test fetching nodes on a page
    def test_following_sibling
      document = Nokogiri::HTML(content)

      block = Page::fetch_node(document, {:css => '#block'})
      nodes = Page::fetch_nodes(block, {:xpath => 'a/following-sibling::ul/li'})

      assert_equal(2, nodes.count)
    end

    protected

    def content
      <<-'HTML'
<li id="block">
  <a>base</a>
  <ul>
    <li><a>node #1</a></li>
    <li><a>node #2</a></li>
  </ul>
<li>
      HTML
    end
  end
end
