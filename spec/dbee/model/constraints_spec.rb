# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'spec_helper'

CONSTRAINT_CONFIG = { name: :a }.freeze
CONSTRAINT_FACTORIES = {
  Dbee::Model::Constraints::Reference => CONSTRAINT_CONFIG.merge(parent: :b, type: :reference),
  Dbee::Model::Constraints::Static => CONSTRAINT_CONFIG.merge(value: :b, type: :static)
}.freeze

describe Dbee::Model::Constraints do
  CONSTRAINT_FACTORIES.each_pair do |constant, config|
    it "should instantiate #{constant} objects" do
      expect(described_class.make(config)).to be_a(constant)
    end
  end
end
