lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'html_entry/version'

Gem::Specification.new do |spec|
  spec.name          = 'html_entry'
  spec.version       = HtmlEntry::VERSION
  spec.date          = '2018-08-29'
  spec.summary       = 'HTML entries fetcher'
  spec.description   = 'A simple gem which allows to organize fetching entries \
    from plain HTML.'
  spec.authors       = ['Kirby Rs']
  spec.email         = 'bizkirby@gmail.com'
  spec.files         = Dir['lib/**/*.rb']
  spec.require_paths = ['lib']
  spec.homepage      = 'https://github.com/rikby/html-entries'
  spec.license       = 'GPL-3.0'
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
