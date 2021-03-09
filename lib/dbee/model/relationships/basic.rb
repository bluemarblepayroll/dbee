# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module Dbee
  class Model
    class Relationships
      # A relationship from one model to another.
      class Basic
        acts_as_hashable

        attr_reader :constraints, :model, :name

        def initialize(name:, constraints: [], model: nil)
          @name = name
          raise ArgumentError, 'name is required' if name.to_s.empty?

          @constraints = Constraints.array(constraints || []).uniq
          @model = model

          freeze
        end

        def model_name
          model || name
        end

        def hash
          [self.class.hash, name.hash, constraints.hash, model.hash].hash
        end

        def ==(other)
          other.instance_of?(self.class) &&
            other.name == name &&
            other.constraints == constraints &&
            other.model == model
        end
        alias eql? ==
      end
    end
  end
end
