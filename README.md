# HTML Entries
This Ruby gem may help to fetch entries data by provided intructions from HTML.

## Installation

Install the gem:
```
$ gem install html-entry
```

## Using
```ruby
require 'pp'
require 'nokogiri'
require 'open-uri'
require 'html-entries'

fetcher              = HtmlEntry::PageFetcher.new
fetcher.instructions = {
    block: {
        type:     :selector,
        selector: '#question-mini-list .question-summary',
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
                           attribute: 'href',
                       },
                   }
               },
               {
                   selector: '.votes > .mini-counts > span',
                   data:     {
                       votes: {}
                   }
               },
               {
                   selector:    '.summary .tags',
                   data:        {
                       tags: {
                           type:         :children,
                           instructions: {
                               selector: 'a',
                               data:     {
                                   tag: {},
                                   url: {
                                       type:      :attribute,
                                       attribute: 'href',
                                   },
                               }
                           }
                       },
                   }
               },
               {
                   selector: '.summary .started .started-link .relativetime',
                   data:     {
                       created_ago: {},
                       created_at: {
                           type:      :attribute,
                           attribute: 'title',
                       },
                   }
               },
               {
                   selector:    '.summary .started',
                   # Use this param sub-items go into next element.
                   # this would be useful when :block instruction contains
                   # several entries
                   # gather_data: true,
                   data:        {
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
                                                 attribute: 'href',
                                             },
                                         }
                                     },
                                     {
                                         # use :xpath instead of :selector
                                         # to avoid fetching deep child "<span>" nodes
                                         xpath: 'span',
                                         data:     {
                                             score: {},
                                         }
                                     },
                                 ]
                       },
                   }
               },
           ]
}

items = fetcher.fetch Nokogiri::HTML(
    open('https://stackoverflow.com/')
)

# show items in terminal
items.each do |item|
  puts <<-OUTPUT
Question: "#{item[:summary]}"
posted by #{item[:author][:name]} #{item[:created_ago]}
tags:     #{item[:tags].map{|e| e[:tag]}.join(', ')}

OUTPUT
end
puts 'Element data:'
puts
pp items.last
```

Output
```
Question: "Can't see the alerts I created on Azure Portal"
posted by groovejet 50 secs ago
tags:     azure, azure-application-insights, azureportal

Question: "Get text height inside table cells"
posted by Dolorosa 55 secs ago
tags:     jquery, html, css, table

[ ... ]

Question: "Scrapy on aws ec2 ubuntu redirect for booking.com"
posted by MrNetroful 1 hour ago
tags:     python, python-3.x, amazon-ec2, web-scraping, scrapy

Element data:

{:summary=>"Scrapy on aws ec2 ubuntu redirect for booking.com",
 :url=>"/questions/52056897/scrapy-on-aws-ec2-ubuntu-redirect-for-booking-com",
 :votes=>"2",
 :tags=>
  [{:tag=>"python", :url=>"/questions/tagged/python"},
   {:tag=>"python-3.x", :url=>"/questions/tagged/python-3.x"},
   {:tag=>"amazon-ec2", :url=>"/questions/tagged/amazon-ec2"},
   {:tag=>"web-scraping", :url=>"/questions/tagged/web-scraping"},
   {:tag=>"scrapy", :url=>"/questions/tagged/scrapy"}],
 :created_ago=>"1 hour ago",
 :created_at=>"2018-08-28 13:05:47Z",
 :author=>
  {:name=>"MrNetroful", :url=>"/users/7990631/mrnetroful", :score=>"42"}}
=end
```
