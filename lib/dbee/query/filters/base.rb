# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module Dbee
  class Query
    class Filters
      # Defines the shared implementation for all filters.
      class Base
        acts_as_hashable

        attr_reader :key_path, :value

        def initialize(key_path:, value: nil)
          raise ArgumentError, 'key_path is required' if key_path.to_s.empty?

          @key_path = KeyPath.get(key_path)
          @value    = value

          freeze
        end

        def hash
          "#{self.class.name}#{key_path}#{value}".hash
        end

        def ==(other)
          other.instance_of?(self.class) &&
            other.key_path == key_path &&
            other.value == value
        end
        alias eql? ==

        def <=>(other)
          "#{self.class.name}#{key_path}#{value}" <=>
            "#{other.class.name}#{other.key_path}#{other.value}"
        end
      end
    end
  end
end
