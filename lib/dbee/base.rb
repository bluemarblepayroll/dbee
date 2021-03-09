# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require_relative 'dsl/association_builder'
require_relative 'dsl/association'
require_relative 'dsl/methods'
require_relative 'dsl/reflectable'

module Dbee
  # Instead of using the configuration-first approach, you could use this super class for
  # Model declaration.
  class Base
    extend Dsl::Reflectable
    extend Dsl::Methods

    BASE_CLASS_CONSTANT = Dbee::Base

    class << self
      # Returns the smallest needed Dbee::Schema for the provided key_chain.
      def to_schema(key_chain)
        DslSchemaBuilder.new(self, key_chain).to_schema
      end

      def inherited_table_name
        subclasses(BASE_CLASS_CONSTANT).find(&:table_name?)&.table_name ||
          inflected_table_name(reversed_subclasses(BASE_CLASS_CONSTANT).first.name)
      end

      def inherited_associations
        reversed_subclasses(BASE_CLASS_CONSTANT).each_with_object({}) do |subclass, memo|
          memo.merge!(subclass.associations_by_name)
        end.values
      end

      def inherited_partitioners
        reversed_subclasses(BASE_CLASS_CONSTANT).inject([]) do |memo, subclass|
          memo + subclass.partitioners
        end
      end

      def inflected_class_name
        inflector.underscore(inflector.demodulize(name))
      end

      private

      def inflected_table_name(name)
        inflector.pluralize(inflector.underscore(inflector.demodulize(name)))
      end
    end
  end
end
