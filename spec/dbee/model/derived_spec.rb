# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'spec_helper'

describe Dbee::Model::Derived do
  it 'can be made' do
    subject = described_class.make(name: 'theaters', query: {})
    expect(subject).to be_a described_class
  end

  it 'requires a query' do
    expect do
      described_class.make(name: 'theaters', query: nil)
    end.to raise_error ActsAsHashable::Hashable::HydrationError, /query is required/
  end

  it 'does not allow a table' do
    expect do
      described_class.make(name: 'theaters', table: 'theaters')
    end.to raise_error ActsAsHashable::Hashable::HydrationError
  end
end
