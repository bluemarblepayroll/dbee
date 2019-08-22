# frozen_string_literal: true

require './lib/dbee/version'

Gem::Specification.new do |s|
  s.name        = 'dbee'
  s.version     = Dbee::VERSION
  s.summary     = 'Adhoc Reporting SQL Generator'

  s.description = <<-DESCRIPTION
    Dbee provides a simple-to-use query API.  The query API can produce SQL using other ORMs, such as Arel/ActiveRecord.  The targeted use-case for Dbee is ad-hoc reporting, so the total SQL feature-set that Dbee supports is rather limited.
  DESCRIPTION

  s.authors     = ['Matthew Ruggio']
  s.email       = ['mruggio@bluemarblepayroll.com']
  s.files       = `git ls-files`.split("\n")
  s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.homepage    = 'https://github.com/bluemarblepayroll/dbee'
  s.license     = 'MIT'

  s.required_ruby_version = '>= 2.3.8'

  s.add_development_dependency('guard-rspec', '~>4.7')
  s.add_development_dependency('pry', '~>0')
  s.add_development_dependency('rake', '~> 12')
  s.add_development_dependency('rspec')
  s.add_development_dependency('rubocop', '~>0.63.1')
  s.add_development_dependency('simplecov', '~>0.17.0')
  s.add_development_dependency('simplecov-console', '~>0.4.2')
end
