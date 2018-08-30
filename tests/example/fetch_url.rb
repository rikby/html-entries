require 'nokogiri'
require 'pp'
require 'open-uri'
require_relative '../../lib/html_entry/page_fetcher'

page_fetcher              = HtmlEntry::PageFetcher.new
page_fetcher.instructions = {
  block: {
    type:     :selector,
    selector: '#question-mini-list .question-summary'
  },
  entity:
         [
           {
             type:     :selector,
             selector: '.summary h3 a',
             data:     {
               summary: {},
               url:     {
                 type:      :attribute,
                 attribute: 'href'
               }
             }
           },
           {
             selector: '.votes span',
             data:     {
               votes: {filter: :to_i}
             }
           },
           {
             selector: '.status span',
             data:     {
               answers: {
                 filter: :to_i
               }
             }
           },
           {
             selector: '.status.answered-accepted',
             # Allow empty nodes to determine "false" case
             allow_empty: true,
             data:        {
               accepted: {
                 type:    :boolean,
                 default: false
               }
             }
           },
           {
             selector: '.summary .tags',
             data:     {
               tags: {
                 type:         :children,
                 instructions: {
                   selector: 'a',
                   data:     {
                     tag: {},
                     url: {
                       type:      :attribute,
                       attribute: 'href'
                     }
                   }
                 }
               }
             }
           },
           {
             selector: '.summary .started .started-link .relativetime',
             data:     {
               created_ago: {},
               created_at:  {
                 type:      :attribute,
                 attribute: 'title'
               }
             }
           },
           {
             selector: '.summary .started',
             # Use this param sub-items go into next element.
             # this would be useful when :block instruction contains
             # several entries
             # gather_data: true,
             data: {
               author: {
                 type: :children,
                 # fetch only first node
                 children_plenty: false,
                 instructions:
                                  [
                                    {
                                      selector: 'a:nth-child(2)',
                                      data:     {
                                        name: {},
                                        url:  {
                                          type:      :attribute,
                                          attribute: 'href'
                                        }
                                      }
                                    },
                                    {
                                      # use :xpath instead of :selector
                                      # to avoid fetching deep child "<span>" nodes
                                      xpath: 'span',
                                      data:  {
                                        score: {}
                                      }
                                    }
                                  ]
               }
             }
           }
         ]
}

items = page_fetcher.fetch Nokogiri::HTML(
  open('https://stackoverflow.com/?asdf=asdf')
)

# show items (first two and last two) in terminal

items.each_with_index do |item, _i|
  begin
    puts <<-OUTPUT.strip_heredoc
      Question: "#{item[:summary]}"
      posted by #{item[:author][:name]} #{item[:created_ago]}
      tags:     #{item[:tags].map {|e| e[:tag]}.join(', ')}
      accepted: #{(!item.key(:accepted) && item[:accepted] ? true.to_s : false.to_s)}

    OUTPUT
  rescue StandardError => e
    pp item
    pp e
    exit 55
  end
end
puts '---- Element data: ----'
pp items.last
