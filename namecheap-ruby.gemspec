# -*- encoding: utf-8 -*-
Gem::Specification.new do |gem|
  gem.authors       = ["Matthew B. Jones"]
  gem.email         = ["matt@makifund.com"]
  gem.description   = "A ruby client for the NameCheap.com API."
  gem.summary       = "A ruby client for the NameCheap.com API."
  gem.homepage      = "http://github.com/matthewbjones/namecheap-ruby"

  gem.files         = ["lib/namecheap-ruby.rb", "lib/namecheap/client.rb"]
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "namecheap-ruby"
  gem.require_paths = ["lib"]
  gem.version       = "0.0.1"

  gem.add_dependency('httparty', ["< 1.0", ">= 0.5"])

  gem.add_development_dependency('rake')
  gem.add_development_dependency('rspec')
  gem.add_development_dependency('fakeweb')
end