require 'nokogiri'
require_relative '../error'

module HtmlEntry
  module Page
    ##
    # This class responsible for getting values according to an instruction
    #
    # @see tests/html_entry/page/test_entity_fetcher.rb

    class ValuesCollector
      ##
      # Extra options
      #
      # @type [Hash]

      @options = {}

      ##
      # Collected data
      #
      # @type [Hash]

      @data = {}

      attr_reader :data

      def initialize(options = {})
        @options = options
        @data    = {}
      end

      ##
      # Fetch value of element
      #
      # @param [Symbol] name
      # @param [Hash] instruction
      # @param [Nokogiri::XML::Element] node
      # @return [String, Nokogiri::XML::Element]

      def fetch(name, instruction, node)
        if node && (instruction[:type] == :attribute)
          value = get_node_attribute(
            node,
            instruction
          )
        elsif instruction[:type] == :function
          value = call_function(name, instruction)
        elsif instruction[:type] == :boolean || instruction[:type] == :bool
          value = !!node
        elsif node && instruction[:type] == :children
          value = children(
            name:        name,
            instruction: instruction,
            node:        node,
            plenty:      if instruction[:children_plenty].nil?
                           true
                         else
                           instruction[:children_plenty]
                         end
          )
        elsif node && (instruction[:type] == :value || instruction[:type].nil?)
          # empty type should be determined as :value
          value = node
        elsif instruction.is_a?(Hash) && !instruction[:default].nil?
          value = instruction[:default]
        elsif node.nil?
          value = nil
        else
          raise HtmlEntry::Error, 'Unknown instruction type or XML/HTML value not found.'
        end

        value = filter_value(value, instruction)
        if data[name].instance_of?(Array) && value.instance_of?(Array)
          data[name] = [data[name], value].flatten
        else
          unless data[name].nil? && (!instruction[:overwrite])
            raise "Value already set for data key name '#{name}'."
          end
          data[name] = value
        end

        data[name]
      end

      protected

      ##
      # Fetch value of element
      #
      # @param [Symbol] name
      # @param [Hash] instruction
      # @param [Nokogiri::XML::Element] node
      # @return [Hash, Array]
      #
      def children(instruction:, node:, plenty: nil, name: nil)
        instruction = if instruction[:instructions] == :the_same
                        @options[:instructions]
                      else
                        instruction[:instructions]
                      end

        fetcher              = Page::EntityFetcher.new
        fetcher.instructions = instruction
        fetcher.fetch document: node,
                      plenty:   plenty.nil? ? true : plenty
      end

      ##
      # Filter value
      #
      # @param [Nokogiri::XML::Element] value
      # @param [Hash] instruction
      # @return [String, Nokogiri::XML::Element]
      #
      def filter_value(value, instruction)
        filter(value, instruction[:filter])
      end

      ##
      # Filter fetched value
      #
      # @param [Nokogiri::XML::Element] value
      # @param [Symbol] filter
      # @return [String, Nokogiri::XML::Element]
      #
      def filter(value, filter = nil)
        # return as is, :filter can be omitted in instruction
        return value if filter == :element

        # return text with tags
        return value.to_s.strip if filter == :node_text

        # return text without tags by default
        value = value.text if value.instance_of?(Nokogiri::XML::Element)

        # return integer
        return value.to_i if filter == :to_i

        # return non-stripped text
        return value.to_s if filter == :no_strip

        return value.strip if value.is_a? String

        value
      end

      ##
      # @param [Nokogiri::XML::Element] node
      # @param [Hash] instruction
      # @return [String]

      def get_node_attribute(node, instruction)
        node[instruction[:attribute]]
      end

      ##
      # Call custom function
      #
      # @param [Hash] instruction
      # @return [*]

      def call_function(name, instruction)
        if instruction[:function].instance_of? Proc
          instruction[:function].call name, instruction, data, @options
        else
          HtmlEntry::Error.new ':function is not instance of Proc'
        end
      end
    end
  end
end
