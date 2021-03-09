# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module Dbee
  module Util
    # Provides a "make_keyed_by" method which extends the Hashable gem's
    # concept of a "make" method.
    module MakeKeyedBy # :nodoc:
      # Given a hash of hashes or a hash of values of instances of this class,
      # a hash is returned where all of the values are instances of this class
      # and the keys are the string versions of the original hash.
      #
      # An ArgumentError is raised if the value's <tt>key_attrib</tt> is not
      # equal to the top level hash key. This ensures that the
      # <tt>key_attrib</tt> is the same in the incoming hash and the value.
      #
      # This is useful for cases where it makes sense in the configuration
      # (YAML) specification to represent certain objects in a hash structure
      # instead of a list.
      def make_keyed_by(key_attrib, spec_hash)
        # Once Ruby 2.5 support is dropped, this can just use the block form of
        # #to_h.
        spec_hash.map do |key, spec|
          string_key = key.to_s
          [string_key, make_value_checking_key_attib!(key_attrib, string_key, spec)]
        end.to_h
      end

      private

      def make_value_checking_key_attib!(key_attrib, key, spec)
        spec ||= {}
        if spec.is_a?(Hash)
          make(spec.merge(key_attrib => key))
        else
          if spec.send(key_attrib).to_s != key
            err_msg = "expected a #{key_attrib} of '#{key}' but got '#{spec.send(key_attrib)}'"
            raise ArgumentError, err_msg
          end
          spec
        end
      end
    end
  end
end
