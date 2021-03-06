# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module Dbee
  class Model
    class Constraints
      # Base class for all constraints.
      class Base
        acts_as_hashable

        attr_reader :name, :parent

        def initialize(name: '', parent: '')
          @name   = name.to_s
          @parent = parent.to_s
        end

        def <=>(other)
          "#{self.class.name}#{name}#{parent}" <=> "#{other.class.name}#{other.name}#{other.parent}"
        end

        def hash
          "#{self.class.name}#{name}#{parent}".hash
        end

        def ==(other)
          other.instance_of?(self.class) &&
            other.name == name &&
            other.parent == parent
        end
        alias eql? ==
      end
    end
  end
end
