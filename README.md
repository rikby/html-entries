# HTML Entries
This Ruby gem may help to fetch entries data from HTML by provided intructions.

## Installation

Console:
```
$ gem install html_entry
```
Gemfile:
```ruby
gem 'html_entry', '~> 0.1.0'
```

## Using

### Extended examples
Please take a look an extended version of "Quick Start" in the file [tests/example/fetch_url.rb](tests/example/fetch_url.rb).

Please review tests to get different examples in these files:
- [tests/html_entry/test_page_fetcher.rb](tests/html_entry/test_page_fetcher.rb)
- [tests/html_entry/test_page_fetcher/test_children.rb](tests/html_entry/test_page_fetcher/test_children.rb)
- [tests/html_entry/test_page_fetcher/test_multi_data.rb](tests/html_entry/test_page_fetcher/test_multi_data.rb)

### Quick Start

This example may show how to fetch TOP questions from https://stackoverflow.com/ home page.

```ruby
require 'pp'
require 'nokogiri'
require 'open-uri'
require 'html_entry'

fetcher              = HtmlEntry::PageFetcher.new
fetcher.instructions = {
    # This block can be fetched by using CSS selector contains an entry (or entries).
    # There are might be several blocks, as in this example.
    block: {
        type:     :selector,
        selector: '#question-mini-list .question-summary',
    },
    # Further, we have to describe entity attributes
    entity:
           [
               # If fetched node/s contains several attributes data,
               # you may describe all of them.
               # In this example: question "summary" and "url".
               {
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
                       votes: {
                           filter: :to_i
                       }
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
votes:    #{item[:votes]}

OUTPUT
end
puts 'Element data:'
puts
pp items.last
```

Output
```
Question: "Can't see the alerts I created on Azure Portal"
votes:    4

[ ... ]

Element data:

{:summary=>"Scrapy on aws ec2 ubuntu redirect for booking.com",
 :url=>"/questions/52056897/scrapy-on-aws-ec2-ubuntu-redirect-for-booking-com",
 :votes=>2,
}
```
