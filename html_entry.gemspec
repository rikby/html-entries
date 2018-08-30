require_relative 'lib/html_entry/version'

Gem::Specification.new do |s|
  s.name        = 'html_entry'
  s.version     = HtmlEntry::VERSION
  s.date        = '2018-08-29'
  s.summary     = 'HTML entries fetcher'
  s.description = 'A simple gem which allows to organize fetching entries \
                  from plain HTML.'
  s.authors     = ['Kirby Rs']
  s.email       = 'bizkirby@gmail.com'
  s.files       = Dir['lib/**/*.rb']
  s.homepage    =
    'https://github.com/rikby/html-entries'
  s.license     = 'GPL-3.0'
end
