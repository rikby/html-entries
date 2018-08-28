module HtmlEntry
  module Page
    ##
    # Get node by XPath or CSS selector
    #
    # @param [Nokogiri::HTML::Document] document
    # @param [Hash] instruction
    # @return [Nokogiri::XML::Element]

    def fetch_node(document, instruction)
      nodes = fetch_nodes(document, instruction)
      nodes.first if nodes
    end

    ##
    # Get nodes by XPath or CSS selector
    #
    # @param [Nokogiri::HTML::Document|Nokogiri::XML::Element] document
    # @param [Hash] instruction
    # @return [Nokogiri::XML::NodeSet]

    def fetch_nodes(document, instruction)
      unless document.instance_of?(Nokogiri::HTML::Document) || document.instance_of?(Nokogiri::XML::Element)
        raise '"document" must be an instance of Nokogiri::HTML::Document.'
      end
      if instruction[:selector]
        document.css(instruction[:selector])
      elsif instruction[:css]
        document.css(instruction[:css])
      elsif instruction[:xpath]
        if defined? document.xpath
          document.xpath(instruction[:xpath])
        else
          raise 'Cannot use this document.'
        end
      end
    end

    module_function :fetch_nodes, :fetch_node
  end
end
