# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require_relative 'relationships/basic'
require_relative '../util/make_keyed_by'

module Dbee
  class Model
    # Top-level class that allows for the making of relationships.
    class Relationships
      acts_as_hashable_factory
      extend Dbee::Util::MakeKeyedBy

      register 'basic', Basic
      register '',      Basic # When type is not present this will be the default
    end
  end
end
