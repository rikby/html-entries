require 'test/unit'
require 'mocha/test_unit'
require 'nokogiri'
require_relative '../../../lib/page/entity_fetcher'

module HtmlEntry
  module Page
    class TestEntityFetcher < Test::Unit::TestCase
      # Test get/set instructions
      def test_set_instructions
        obj              = EntityFetcher.new
        value            = [{:aa => 'aa'}]
        obj.instructions = value
        assert_equal(value, obj.get_instructions)
      end

      # Test fetching label text
      def test_fetch_text
        html             = Nokogiri::HTML(content)
        obj              = EntityFetcher.new
        obj.instructions = [
            {
                :selector => '.test-block a.deep-in',
                :data     => {:name1 => {:type => :value}}
            }
        ]
        assert_equal ({:name1 => 'Link label 1'}), obj.fetch(document: html)
      end

      # Test fetching label text
      def test_fetch_simple_instruction
        html             = Nokogiri::HTML(content)
        obj              = EntityFetcher.new
        obj.instructions = [
            {
                :selector => '.test-block a.deep-in',
                :data     => {:name1 => {}} # {:type => :value} is omitted
            }
        ]
        assert_equal ({:name1 => 'Link label 1'}), obj.fetch(document: html)
      end

      # Test fetching non-stripped value
      def test_fetch_non_stripped_text
        html             = Nokogiri::HTML(content)
        obj              = EntityFetcher.new
        obj.instructions = [
            {
                :data     => {:name1 => {:filter => :no_strip}},
                :selector => '.test-block a.deep-in',
            }
        ]
        assert_equal(
            "\n        \n          Link label 1\n        \n    ",
            obj.fetch(document: html)[:name1])
      end

      # Test fetching Nokogiri::XML::Element instead text
      def test_fetch_element
        html             = Nokogiri::HTML(content)
        obj              = EntityFetcher.new
        obj.instructions = [{
                                :data     => {:name1 => {:filter => :element}},
                                :selector => '.test-block a.deep-in',
                            }]
        assert_instance_of Nokogiri::XML::Element, obj.fetch(document: html)[:name1]
      end

      # Test fetching html text of found node
      def test_fetch_node_text
        html             = Nokogiri::HTML(content)
        obj              = EntityFetcher.new
        obj.instructions =
            [{
                 :data     => {:name1 => {:filter => :node_text}},
                 :selector => '.test-block a.deep-in',
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
                :data     => {
                    :url =>
                        {
                            :type      => :attribute,
                            :attribute => 'href',
                        },
                },
                :selector => '.test-block a.deep-in',
            }]
        assert_equal '/test/path/main', obj.fetch(document: html)[:url]
      end

      # Test fetching two data elements
      def test_fetch_two_data_elements
        html             = Nokogiri::HTML(content)
        obj              = EntityFetcher.new
        obj.instructions = [{
                                :data     => {
                                    :url   =>
                                        {
                                            :type      => :attribute,
                                            :attribute => 'href',
                                        },
                                    :name1 => {}
                                },
                                :selector => '.test-block a.deep-in',
                            }]
        assert_equal '/test/path/main', obj.fetch(document: html)[:url]
        assert_equal 'Link label 1', obj.fetch(document: html)[:name1]
      end

      # Test fetching two data elements
      def test_fetch_two_nodes_data
        html             = Nokogiri::HTML(<<-HTML
<div id="two_nodes_data">
    <ul>
        <li class="two_nodes_data_foo">foo one</li>
        <li class="two_nodes_data_bar" bar="bar two">
            <!--empty-->
        </li>
    </ul>
</div>
        HTML
        )
        obj              = EntityFetcher.new
        obj.instructions = [
            {
                :selector => '#two_nodes_data .two_nodes_data_foo',
                :data     => {
                    :foo => {},
                },
            },
            {
                :selector => '#two_nodes_data .two_nodes_data_bar',
                :data     =>
                    {
                        :bar => {
                            :type      => :attribute,
                            :attribute => 'bar',
                        },
                    },
            },
        ]

        assert_equal 'foo one', obj.fetch(document: html)[:foo]
        assert_equal 'bar two', obj.fetch(document: html)[:bar]
      end

      # Test fetching value of duplicated node
      def test_fetch_node_first
        html             = Nokogiri::HTML(content)
        obj              = EntityFetcher.new
        obj.instructions = [
            {
                :data     => {:name1 => {}},
                :selector => '.double-block a.duplicate',
            }]
        assert_equal 'Link label 22 first', obj.fetch(document: html)[:name1]
      end

      # Test two nodes (plenty node)
      def test_fetch_selector_nodes
        html             = Nokogiri::HTML(content)
        obj              = EntityFetcher.new
        obj.instructions = [
            {
                :selector => '.double-block a.duplicate',
                :data     => {
                    :name1 => {},
                    :link  => {
                        :type      => :attribute,
                        :attribute => 'href',
                    },
                }
            },
        ]
        expected         = [
            {:name1 => 'Link label 22 first', :link => '/test/path'},
            {:name1 => 'Link label 22 second', :link => '/test/another-path'}]
        assert_equal expected, obj.fetch(document: html, plenty: true)
      end

      # Test two nodes with two different selectors (plenty node)
      def test_fetch_nodes_two_selectors
        html             = Nokogiri::HTML(content)
        obj              = EntityFetcher.new
        obj.instructions = [
            {
                :selector => '.test-block-2 .entity-block a',
                :data     => {
                    :label1 => {},
                    :link   => {
                        :type      => :attribute,
                        :attribute => 'href',
                    },
                }
            },
            {
                :selector => '.test-block-2 .entity-block h6',
                :data     => {
                    :title1 => {},
                }
            }
        ]
        expected         = [
            {:title1 => 'Title 1', :link => '/some/1', :label1 => 'Label-1'},
            {:title1 => 'Title 2', :link => '/some/2', :label1 => 'Label-2'}]
        assert_equal expected, obj.fetch(document: html, plenty: true)
      end

      # Test fetching value from with function
      def test_fetch_func_node
        html             = Nokogiri::HTML(content)
        obj              = EntityFetcher.new
        obj.instructions = [
            {
                :selector => '.vote-up',
                :data     => {
                    :up => {:type => :value},
                }
            },
            {
                :selector => '.vote-down',
                :data     => {
                    :down => {:type => :value},
                }
            },
            {
                :data => {
                    :diff => {
                        :type     => :function,
                        :function => Proc.new {|name, instruction, data, options|
                          data[:up].to_i - data[:down].to_i
                        },
                    }
                },
            }
        ]
        data             = obj.fetch(document: html)
        assert_equal '10', data[:up]
        assert_equal '3', data[:down]
        assert_equal 7, data[:diff]
      end

      protected

      ##
      # Get HTML content
      #
      # @return [String]

      def content
        return @content if nil != @content

        @content = File.open(__dir__ + '/../_fixture/entity_fetcher.html').read
      end
    end
  end
end
