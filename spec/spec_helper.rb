# frozen_string_literal: true

#
# Copyright (c) 2018-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'yaml'
require 'pry'

RSpec.configure do |config|
  # Allow for disabling auto focus mode in certain environments like CI to
  # prevent false positives when only a subset of the suite passes.
  config.filter_run_when_matching :focus unless ENV['DISABLE_RSPEC_FOCUS'] == 'true'
end

unless ENV['DISABLE_SIMPLECOV'] == 'true'
  require 'simplecov'
  require 'simplecov-console'

  SimpleCov.formatter = SimpleCov::Formatter::Console
  SimpleCov.start do
    add_filter %r{\A/spec/}
  end
end

require './lib/dbee'

def fixture_path(*filename)
  File.join('spec', 'fixtures', filename)
end

def yaml_fixture(*filename)
  YAML.safe_load(fixture(*filename))
end

def fixture(*filename)
  File.open(fixture_path(*filename), 'r:bom|utf-8').read
end

def yaml_fixture_files(*directory)
  Dir[File.join('spec', 'fixtures', *directory, '*.yaml')].map do |filename|
    [
      filename,
      yaml_file_read(filename)
    ]
  end.to_h
end

def yaml_file_read(*filename)
  YAML.safe_load(file_read(*filename))
end

def file_read(*filename)
  File.open(File.join(*filename), 'r:bom|utf-8').read
end
