# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'spec_helper'

describe Dbee::Model::TableBased do
  specify 'table defaults to name' do
    config = { name: 'theaters' }
    model = described_class.make(config)

    expect(model.table).to eq(config[:name])
  end

  specify 'table can be explicitly set' do
    config = { name: 'favorite_comedy_movies', table: 'movies' }
    model = described_class.make(config)

    expect(model.table).to eq(config[:table])
  end
end
