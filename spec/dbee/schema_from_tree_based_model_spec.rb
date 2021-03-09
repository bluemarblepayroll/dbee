# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'spec_helper'
require 'fixtures/models'

describe Dbee::SchemaFromTreeBasedModel do
  let(:tree_config) do
    Dbee::Model.make(yaml_fixture('models.yaml')['Theaters, Members, and Movies Tree Based'])
  end
  let(:schema_config) do
    yaml_fixture('models.yaml')['Theaters, Members, and Movies from Tree']
  end

  it 'converts the theaters model' do
    expected_schema = Dbee::Schema.new(schema_config)
    expect(described_class.convert(tree_config)).to eq expected_schema
  end

  it 'does not raise any errors when converting the readme model' do
    tree_config = Dbee::Model.make(yaml_fixture('models.yaml')['Readme Tree Based'])

    expect { described_class.convert(tree_config) }.not_to raise_error
  end
end
