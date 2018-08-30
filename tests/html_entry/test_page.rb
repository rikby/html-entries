require 'test/unit'
require 'mocha/test_unit'
require 'nokogiri'
require_relative '../../lib/html_entry/page'

module HtmlEntry
  ##
  # Tests for HtmlEntry::Page
  #
  class TestPage < Test::Unit::TestCase
    ##
    # Test fetching nodes on a page
    #
    def test_xpath_following_sibling
      nodes = Page.fetch_nodes(
        Page.fetch_node(Nokogiri::HTML(content), css: '#block'),
        xpath: 'a/following-sibling::ul/li'
      )

      assert_equal(2, nodes.count)
    end

    protected

    def content
      <<-HTML
      <ul>
        <li id="block">
          <a>base</a>
          <ul>
            <li><a>node #1</a></li>
            <li><a>node #2</a></li>
          </ul>
        <li>
      <ul>
      HTML
    end
  end
end
