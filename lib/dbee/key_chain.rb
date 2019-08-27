# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require_relative 'key_path'

module Dbee
  # A KeyChain is a collection of KeyPath objects.  It knows how to deal with aggregate methods,
  # such as equality of a set of KeyPath objects and finding an ancestor path in all the
  # KeyPath objects' ancestor paths. You can pass in either KeyPath instances or strings,
  # which will be coerced to KeyPath objects. Duplicates will also be removed.
  class KeyChain
    attr_reader :key_path_set, :ancestor_path_set

    def initialize(key_paths = [])
      @key_path_set       = key_paths.map { |k| KeyPath.get(k) }.to_set
      @ancestor_path_set  = @key_path_set.map(&:ancestor_paths).flatten.to_set

      freeze
    end

    def hash
      key_path_set.hash
    end

    def ==(other)
      key_path_set == other.key_path_set
    end
    alias eql? ==

    def ancestor_path?(*parts)
      path = parts.flatten.compact.join(KeyPath::SPLIT_CHAR)

      ancestor_path_set.include?(path)
    end
  end
end
