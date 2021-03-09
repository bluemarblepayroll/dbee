# frozen_string_literal: true

require './lib/dbee/version'

Gem::Specification.new do |s|
  s.name        = 'dbee'
  s.version     = Dbee::VERSION
  s.summary     = 'Adhoc Reporting SQL Generator'

  s.description = <<-DESCRIPTION
    Dbee provides a simple-to-use data modeling and query API.  The query API can produce SQL using other ORMs, such as Arel/ActiveRecord.  The targeted use-case for Dbee is ad-hoc reporting, so the total SQL feature-set that Dbee supports is rather limited.
  DESCRIPTION

  s.authors     = ['Matthew Ruggio']
  s.email       = ['mruggio@bluemarblepayroll.com']
  s.files       = `git ls-files`.split("\n")
  s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.bindir      = 'exe'
  s.executables = []
  s.homepage    = 'https://github.com/bluemarblepayroll/dbee'
  s.license     = 'MIT'
  s.metadata    = {
    'bug_tracker_uri' => 'https://github.com/bluemarblepayroll/dbee/issues',
    'changelog_uri' => 'https://github.com/bluemarblepayroll/dbee/blob/master/CHANGELOG.md',
    'documentation_uri' => 'https://www.rubydoc.info/gems/dbee',
    'homepage_uri' => s.homepage,
    'source_code_uri' => s.homepage
  }

  s.required_ruby_version = '>= 2.5'

  s.add_dependency('acts_as_hashable', '~>1', '>=1.2.0')
  s.add_dependency('dry-inflector', '~>0')

  s.add_development_dependency('guard-rspec', '~>4.7')
  s.add_development_dependency('pry', '~>0')
  s.add_development_dependency('pry-byebug')
  s.add_development_dependency('rake', '~> 13')
  s.add_development_dependency('rspec')
  s.add_development_dependency('rubocop', '~> 1')
  s.add_development_dependency('rubocop-rake')
  s.add_development_dependency('rubocop-rspec')
  s.add_development_dependency('simplecov', '~>0.19.0')
  s.add_development_dependency('simplecov-console', '~>0.7.0')
end
