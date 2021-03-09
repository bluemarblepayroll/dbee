# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'acts_as_hashable'
require 'dry/inflector'
require 'forwardable'

require_relative 'dbee/base'
require_relative 'dbee/constant_resolver'
require_relative 'dbee/dsl_schema_builder'
require_relative 'dbee/key_chain'
require_relative 'dbee/key_path'
require_relative 'dbee/model'
require_relative 'dbee/providers'
require_relative 'dbee/query'
require_relative 'dbee/schema'
require_relative 'dbee/schema_creator'
require_relative 'dbee/schema_from_tree_based_model'

# Top-level namespace that provides the main public API.
module Dbee
  class << self
    # Use this to override the built in Dry::Inflector instance.
    # This is useful is you have your own grammar/overrides you need to load.
    # See the referenced gem here: https://github.com/dry-rb/dry-inflector
    attr_writer :inflector

    def inflector
      @inflector ||= Dry::Inflector.new
    end

    def sql(schema_or_model, query_input, provider)
      raise ArgumentError, 'a provider is required' unless provider

      schema_compat = SchemaCreator.new(schema_or_model, query_input)
      provider.sql(schema_compat.schema, schema_compat.query)
    end
  end
end
