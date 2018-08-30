require 'test/unit'
require 'mocha/test_unit'
require 'nokogiri'
require_relative '../../../lib/html_entry/page_fetcher'
require_relative '../../content_fixture'


module HtmlEntry
  class TestPageFetcher_TestChildren < Test::Unit::TestCase

    include ContentFixture

    def test_one_level
      obj  = HtmlEntry::PageFetcher.new
      html = Nokogiri::HTML(
          content(__method__.to_s, __FILE__)
      )

      obj.instructions = {
          # block where entities can be found
          :block  => {
              :type     => :selector,
              :selector => '#main/li',
          },
          :entity => [
              # data instructions of main element
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
              # children instructions
              # each found element will be processed by the same entity instructions
              # because :instructions => :the_same
              {
                  :xpath => 'a/following-sibling::ul/li',
                  # gather_data must be set because each <a> tag placed into a different document
                  :merge => true,
                  :data  => {
                      :_children => {
                          :type         => :children,
                          :instructions => :the_same,
                      },
                  },
              }
          ],
      }

      # region expected
      expected = [
          {
              :label => 'Home',
              :url   => '/home',
          },
          {
              :label     => 'Plenty',
              :url       => '/plenty',
              :_children => [
                  {
                      :label => 'Plenty One',
                      :url   => '/plenty/one',
                  },
                  {
                      :label => 'Plenty Two',
                      :url   => '/plenty/two'
                  },
              ]
          }
      ]
      # endregion

      assert_equal(expected, obj.fetch(html))
    end

    def test_multi_level
      obj  = HtmlEntry::PageFetcher.new
      html = Nokogiri::HTML(
          content(__method__.to_s, __FILE__)
      )

      obj.instructions = {
          # block where entities can be found
          :block  => {
              :type     => :selector,
              :selector => '#main/li',
          },
          :entity => [
              # data instructions of main element
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
              # children instructions
              # each found element will be processed by the same entity instructions
              # because :instructions => :the_same
              {
                  :xpath => 'a/following-sibling::ul/li',
                  # gather_data must be set because each <a> tag placed into a different document
                  :merge => true,
                  :data  => {
                      :_children => {
                          :type         => :children,
                          :instructions => :the_same,
                      },
                  },
              }
          ],
      }

      # region expected
      expected = [
          {
              :label     => 'one',
              :url       => '/1',
              :_children => [
                  {
                      :label => 'one/one',
                      :url   => '/1/1',
                  },
                  {
                      :label     => 'one/two',
                      :url       => '/1/2',
                      :_children => [
                          {
                              :label => 'one/two/one',
                              :url   => '/1/2/1',
                          },
                          {
                              :label => 'one/two/two',
                              :url   => '/1/2/2',
                          },
                          {
                              :label     => 'one/two/three',
                              :url       => '/1/2/3',
                              :_children => [
                                  {
                                      :label => 'one/two/three/one',
                                      :url   => '/1/2/3/1',
                                  },
                                  {
                                      :label => 'one/two/three/two',
                                      :url   => '/1/2/3/2',
                                  },
                              ]
                          },
                      ]
                  },
                  {
                      :label => 'one/three',
                      :url   => '/1/3',
                  },
              ]
          }
      ]
      # endregion

      assert_equal(expected, obj.fetch(html))
    end
  end
end
