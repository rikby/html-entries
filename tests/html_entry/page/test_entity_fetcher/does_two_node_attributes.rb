module HtmlEntry
  module Page
    module TestEntryFetcher
      ##
      # Tests for TestEntityFetcher
      #
      module DoesTwoNodeAttributes
        as_trait do
          # Test fetching two data elements
          def test_two_node_attributes
            html = Nokogiri::HTML content_two_nodes

            obj              = EntityFetcher.new
            obj.instructions = instructions_2node_attributes

            assert_equal 'foo one', obj.fetch(document: html)[:foo]
            assert_equal 'bar two', obj.fetch(document: html)[:bar]
          end

          private

          # @return [Array]
          def instructions_2node_attributes
            [
              {
                selector: '#two_nodes_data .two_nodes_data_foo',
                data:     {
                  foo: {}
                }
              },
              {
                selector: '#two_nodes_data .two_nodes_data_bar',
                data:     {
                  bar: {
                    type:      :attribute,
                    attribute: 'bar'
                  }
                }
              }
            ]
          end

          def content_two_nodes
            <<-HTML
              <div id="two_nodes_data">
                  <ul>
                      <li class="two_nodes_data_foo">foo one</li>
                      <li class="two_nodes_data_bar" bar="bar two">
                          <!--empty-->
                      </li>
                  </ul>
              </div>
            HTML
          end
        end
      end
    end
  end
end
