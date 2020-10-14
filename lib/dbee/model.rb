# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require_relative 'model/base'
require_relative 'model/constraints'
require_relative 'model/derived'
require_relative 'model/partitioner'
require_relative 'model/table_based'

module Dbee
  # Top-level factory that allows for the making of models.
  class Model
    acts_as_hashable_factory

    register 'derived',     Dbee::Model::Derived
    register 'table_based', Dbee::Model::TableBased
    register '',            Dbee::Model::TableBased # default
  end
end
