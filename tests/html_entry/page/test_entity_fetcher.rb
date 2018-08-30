require 'test/unit'
require 'mocha/test_unit'
require 'nokogiri'
require 'modularity'
require_relative '../../../lib/html_entry/page/entity_fetcher'
require_relative 'test_entity_fetcher/does_fetch_func_node'
require_relative 'test_entity_fetcher/does_fetch_nodes_two_selectors'
require_relative 'test_entity_fetcher/does_two_node_attributes'

module HtmlEntry
  ##
  # Page module
  #
  module Page
    ##
    # Tests for EntityFetcher class
    #
    class TestEntityFetcher < Test::Unit::TestCase
      include HtmlEntry::Page::TestEntryFetcher::DoesFetchNodesTwoSelectors
      include HtmlEntry::Page::TestEntryFetcher::DoesFetchFuncNode
      include HtmlEntry::Page::TestEntryFetcher::DoesTwoNodeAttributes

      # Test get/set instructions
      def test_set_instructions
        obj              = EntityFetcher.new
        value            = [{ aa: 'aa' }]
        obj.instructions = value
        assert_equal(value, obj.instructions)
      end

      # Test fetching label text
      def test_fetch_text
        html             = Nokogiri::HTML(content)
        obj              = EntityFetcher.new
        obj.instructions = [
          {
            selector: '.test-block a.deep-in',
            data:     { name1: { type: :value } }
          }
        ]
        assert_equal ({ name1: 'Link label 1' }), obj.fetch(document: html)
      end

      # Test fetching label text
      def test_fetch_simple_instruction
        html             = Nokogiri::HTML(content)
        obj              = EntityFetcher.new
        obj.instructions = [
          {
            selector: '.test-block a.deep-in',
            data:     { name1: {} } # {:type => :value} is omitted
          }
        ]
        assert_equal ({ name1: 'Link label 1' }), obj.fetch(document: html)
      end

      # Test fetching non-stripped value
      def test_fetch_non_stripped_text
        html             = Nokogiri::HTML(content)
        obj              = EntityFetcher.new
        obj.instructions = [
          {
            data:     { name1: { filter: :no_strip } },
            selector: '.test-block a.deep-in'
          }
        ]
        assert_equal(
          "\n        \n          Link label 1\n        \n    ",
          obj.fetch(document: html)[:name1]
        )
      end

      # Test fetching Nokogiri::XML::Element instead text
      def test_fetch_element
        html             = Nokogiri::HTML(content)
        obj              = EntityFetcher.new
        obj.instructions = [{
                              data:     { name1: { filter: :element } },
                              selector: '.test-block a.deep-in'
                            }]
        assert_instance_of Nokogiri::XML::Element, obj.fetch(document: html)[:name1]
      end

      # Test fetching html text of found entry
      def test_fetch_node_text
        html             = Nokogiri::HTML(content)
        obj              = EntityFetcher.new
        obj.instructions =
          [{
             data:     { name1: { filter: :node_text } },
             selector: '.test-block a.deep-in'
           }]
        expected         = <<-HTML
    <a class="deep-in" href="/test/path/main">
        <span>
          Link label 1
        </span>
    </a>
        HTML
        assert_equal expected.strip, obj.fetch(document: html)[:name1].strip
      end

      # Test fetching attribute
      def test_fetch_attribute
        html             = Nokogiri::HTML(content)
        obj              = EntityFetcher.new
        obj.instructions = [
          {
            data:     {
              url: {
                type:      :attribute,
                attribute: 'href'
              }
            },
            selector: '.test-block a.deep-in'
          }
        ]
        assert_equal '/test/path/main', obj.fetch(document: html)[:url]
      end

      # Test fetching two entity attributes
      def test_fetch_two_attributes
        html             = Nokogiri::HTML(content)
        obj              = EntityFetcher.new
        obj.instructions = [
          {
            data:     {
              url:   {
                type:      :attribute,
                attribute: 'href'
              },
              name1: {}
            },
            selector: '.test-block a.deep-in'
          }
        ]

        entry = obj.fetch(document: html)
        assert_equal '/test/path/main', entry[:url]
        assert_equal 'Link label 1', entry[:name1]
      end

      # Test fetching value of duplicated entry
      def test_fetch_node_first
        html             = Nokogiri::HTML(content)
        obj              = EntityFetcher.new
        obj.instructions = [
          {
            data:     { name1: {} },
            selector: '.double-block a.duplicate'
          }
        ]
        assert_equal 'Link label 22 first', obj.fetch(document: html)[:name1]
      end

      # Test two nodes (plenty entry)
      def test_fetch_selector_nodes
        html             = Nokogiri::HTML(content)
        obj              = EntityFetcher.new
        obj.instructions = [
          {
            selector: '.double-block a.duplicate',
            data:     {
              name1: {},
              link:  {
                type:      :attribute,
                attribute: 'href'
              }
            }
          }
        ]
        expected         = [
          { name1: 'Link label 22 first', link: '/test/path' },
          { name1: 'Link label 22 second', link: '/test/another-path' }
        ]
        assert_equal expected, obj.fetch(document: html, plenty: true)
      end

      protected

      ##
      # Get HTML content
      #
      # @return [String]
      #
      def content
        return @content unless @content.nil?

        @content = File.open(__dir__ + '/../_fixture/entity_fetcher.html').read
      end
    end
  end
end
