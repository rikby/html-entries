module HtmlEntry
  module Page
    module TestEntryFetcher
      ##
      # Tests for TestEntityFetcher
      #
      module DoesFetchNodesTwoSelectors
        as_trait do
          # Test two nodes with two different selectors (plenty node)
          def test_fetch_nodes_two_selectors
            html             = Nokogiri::HTML content
            obj              = EntityFetcher.new
            obj.instructions = instructions_two_selectors
            expected         = [
              { title1: 'Title 1', link: '/some/1', label1: 'Label-1' },
              { title1: 'Title 2', link: '/some/2', label1: 'Label-2' }
            ]
            assert_equal expected, obj.fetch(document: html, plenty: true)
          end

          private

          # @return [Array]
          def instructions_two_selectors
            [
              {
                selector: '.test-block-2 .entity-block a',
                data:     {
                  label1: {},
                  link:   {
                    type:      :attribute,
                    attribute: 'href'
                  }
                }
              },
              {
                selector: '.test-block-2 .entity-block h6',
                data:     {
                  title1: {}
                }
              }
            ]
          end
        end
      end
    end
  end
end
