module HtmlEntry
  module Page
    module TestEntryFetcher
      ##
      # Tests for TestEntityFetcher
      #
      module DoesFetchFuncNode
        as_trait do
          # Test fetching value from with function
          def test_fetch_func_node
            obj              = EntityFetcher.new
            obj.instructions = instructions_func_node

            data = obj.fetch document: Nokogiri::HTML(content)

            assert_equal 10, data[:up]
            assert_equal 3, data[:down]
            assert_equal 7, data[:diff]
          end

          private

          # @return [Array]
          def instructions_func_node
            [
              {
                selector: '.vote-up',
                data:     {
                  up: { type: :value, filter: :to_i }
                }
              },
              {
                selector: '.vote-down',
                data:     {
                  down: { type: :value, filter: :to_i }
                }
              },
              {
                data: {
                  diff: {
                    type:     :function,
                    function: proc do |_name, _instruction, data, _options|
                      data[:up] - data[:down]
                    end
                  }
                }
              }
            ]
          end
        end
      end
    end
  end
end
