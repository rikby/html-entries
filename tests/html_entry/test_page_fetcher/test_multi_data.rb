require 'test/unit'
require 'mocha/test_unit'
require 'nokogiri'
require_relative '../../../lib/html_entry/page_fetcher'
require_relative '../../content_fixture'


module HtmlEntry
  class TestPageFetcher_TestMultiData < Test::Unit::TestCase

    include ContentFixture

    def test_multi_nodes
      obj  = HtmlEntry::PageFetcher.new
      html = Nokogiri::HTML(
          content(__method__.to_s, __FILE__)
      )

      obj.instructions = {
          # block where entities can be found
          :block  => {
              :type     => :selector,
              :selector => '#main/ul',
          },
          :entity => [
              # gather data from different elements
              {
                  :selector => 'li.data_foo',
                  :data     => {
                      :foo => {},
                      :url => {
                          :type      => :attribute,
                          :attribute => 'href',
                      }
                  }
              },
              {
                  :selector => 'li.data_bar',
                  :data     => {
                      :type => {
                          :type      => :attribute,
                          :attribute => 'type',
                      },
                  }
              },
              {
                  :selector => 'li.data_bar a',
                  :data     => {
                      :url => {
                          :type      => :attribute,
                          :attribute => 'href',
                      },
                      :bar => {}
                  }
              },
          ],
      }

      # region expected
      expected = [
          {
              :foo  => 'foo one',
              :url  => '/bar/one',
              :type => 'type one',
              :bar  => 'bar one',
          },
          {
              :foo  => 'foo two',
              :url  => '/bar/two',
              :type => 'type two',
              :bar  => 'bar two',
          },
      ]
      # endregion

      assert_equal(expected, obj.fetch(html))
    end
  end
end
