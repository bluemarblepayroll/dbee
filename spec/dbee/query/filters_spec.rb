# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'spec_helper'

FILTERS_CONFIG = { key_path: 'a.b.c', value: :d }.freeze
FILTER_FACTORIES = {
  Dbee::Query::Filters::Contains => FILTERS_CONFIG.merge(type: :contains),
  Dbee::Query::Filters::Equals => FILTERS_CONFIG.merge(type: :equals),
  Dbee::Query::Filters::GreaterThanOrEqualTo => FILTERS_CONFIG.merge(
    type: :greater_than_or_equal_to
  ),
  Dbee::Query::Filters::GreaterThan => FILTERS_CONFIG.merge(type: :greater_than),
  Dbee::Query::Filters::LessThanOrEqualTo => FILTERS_CONFIG.merge(type: :less_than_or_equal_to),
  Dbee::Query::Filters::LessThan => FILTERS_CONFIG.merge(type: :less_than),
  Dbee::Query::Filters::NotContain => FILTERS_CONFIG.merge(type: :not_contain),
  Dbee::Query::Filters::NotEquals => FILTERS_CONFIG.merge(type: :not_equals),
  Dbee::Query::Filters::NotStartWith => FILTERS_CONFIG.merge(type: :not_start_with),
  Dbee::Query::Filters::StartsWith => FILTERS_CONFIG.merge(type: :starts_with)
}.freeze

describe Dbee::Query::Filters do
  FILTER_FACTORIES.each_pair do |constant, config|
    it "should instantiate #{constant} objects" do
      expect(described_class.make(config)).to be_a(constant)
    end
  end
end
