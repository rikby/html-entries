require 'test/unit'
require 'mocha/test_unit'
require 'nokogiri'
require_relative '../../lib/page_fetcher'

module HtmlEntry
  class TestPageFetcher < Test::Unit::TestCase
    # Test get/set instructions
    def test_set_instructions
      obj              = PageFetcher.new
      value            = {:aa => 'aa'}
      obj.instructions = value
      assert_equal(value, obj.instructions)
    end

    # Test fetching nodes on a page
    def test_fetch_nodes
      obj              = PageFetcher.new
      html             = Nokogiri::HTML(content)
      obj.instructions = {
          :entity => [
              {
                  :type     => :selector,
                  :selector => '.blocks .nodes',
                  # Instructions for entity which will be used in EntityFetcher
                  :data => {
                      :my_item => {
                          :instructions => {:selector => 'span.item-text'},
                      }
                  }

              }
          ],
      }

      # todo mock using EntityFetcher class
      expected = [
          {:my_item => 'a1'},
          {:my_item => 'a2'},
          {:my_item => 'b1'},
          {:my_item => 'b2'},
      ]
      assert_equal(
          expected,
          obj.fetch(html))
    end

    # Test fetching nodes on a page
    def test_fetch_child_nodes
      obj  = PageFetcher.new
      html = Nokogiri::HTML(content)

      obj.instructions = {
          # block where entities can be found
          :block  => {
              :type     => :selector,
              :selector => '.main-menu > div',
          },
          :entity => [
              {
                  :xpath => 'a',
                  :data  => {
                      :label => {},
                      :url   => {
                          :type      => :attribute,
                          :attribute => 'href',
                      }
                  }
              },
              {
                  :xpath => 'a/following-sibling::div',
                  :data  => {
                      :_children => {
                          :type         => :children,
                          :instructions => :the_same
                      },
                  },
              }
          ],
      }


      # todo mock using EntityFetcher class
      # region expected
      expected = [
          {
              :label     => 'Video',
              :url       => '/video',
              :_children => [
                  {
                      :label     => 'Movies',
                      :url       => '/video/movies',
                      :_children => [
                          {
                              :label => 'Action',
                              :url   => '/video/movies/action',
                          },
                          {
                              :label => 'Sci-Fi',
                              :url   => '/video/movies/sci-fi',
                          },
                      ]
                  },
                  {
                      :label     => 'Series',
                      :url       => '/video/series',
                      :_children => [
                          {
                              :label => 'Action',
                              :url   => '/video/series/action',
                          },
                          {
                              :label => 'Sci-Fi',
                              :url   => '/video/series/sci-fi',
                          },
                      ]
                  },
                  {
                      :label => 'Cartoons',
                      :url   => '/video/cartoons',
                  },
              ]
          },
          {
              :label     => 'Books',
              :url       => '/books',
              :_children => [
                  {
                      :label => 'Documentary',
                      :url   => '/books/doc',
                  },
                  {
                      :label => 'Artistic',
                      :url   => '/books/artistic',
                  },
              ]
          },
      ]
      # endregion

      assert_equal(expected, obj.fetch(html))
    end

    def test_last_page
      obj              = PageFetcher.new
      html             = Nokogiri::HTML(content)
      obj.instructions = {
          :last_page => {
              :selector => '.pager > span.active:last',
          }
      }
      assert_true(obj.last_page?(html))
    end

    protected

    ##
    # Get HTML content
    #
    # @return [String]

    def content(file: 'page_fetcher.html')
      return @content if nil != @content

      @content = File.open(__dir__ + '/_fixture/' + file).read
    end
  end
end
