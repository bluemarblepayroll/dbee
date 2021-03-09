# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'spec_helper'
require 'fixtures/models'

describe Dbee::DslSchemaBuilder do
  specify 'theaters example' do
    model_name      = 'Theaters, Members, and Movies from DSL'
    expected_config = yaml_fixture('models.yaml')[model_name]

    expected_schema = Dbee::Schema.new(expected_config)

    key_paths = %w[
      members.a
      members.demos.phone_numbers.a
      members.movies.b
      members.favorite_comic_movies.c
      members.favorite_mystery_movies.d
      members.favorite_comedy_movies.e
      parent_theater.members.demos.phone_numbers.f
      parent_theater.members.movies.g
      parent_theater.members.favorite_comic_movies.h
      parent_theater.members.favorite_mystery_movies.i
      parent_theater.members.favorite_comedy_movies.j
    ]
    key_chain = Dbee::KeyChain.new(key_paths)

    actual_schema = Models::Theater.to_schema(key_chain)
    expect(actual_schema).to eq(expected_schema)
  end

  describe 'with a derived model' do
    it 'compiles correctly' do
      model_name      = 'Theaters with a Derived Model'
      expected_config = yaml_fixture('models.yaml')[model_name]

      expected_schema = Dbee::Schema.new(expected_config)

      key_paths = %w[
        members.foo
        member_derived_tests.members_column
      ]
      key_chain = Dbee::KeyChain.new(key_paths)

      actual_schema = Models::Theater.to_schema(key_chain)
      expect(actual_schema).to eq(expected_schema)
    end

    it 'compiles correctly when the query is a callable' do
      model_name      = 'Theaters with a Derived Model with a Callable Query'
      expected_config = yaml_fixture('models.yaml')[model_name]

      expected_schema = Dbee::Schema.new(expected_config)

      key_paths = %w[
        members.foo
        member_derived_callable_tests.members_column
      ]
      key_chain = Dbee::KeyChain.new(key_paths)

      actual_schema = Models::Theater.to_schema(key_chain)
      expect(actual_schema).to eq(expected_schema)
    end
  end

  it 'honors key_chain to flatten cyclic references' do
    model_name      = 'Cycle Example'
    expected_config = yaml_fixture('models.yaml')[model_name]

    expected_schema = Dbee::Schema.new(expected_config)

    key_paths = %w[
      b1.c.a.z
      b1.d.a.y
      b2.c.a.x
      b2.d.a.w
      b2.d.a.b1.c.z
    ]

    key_chain = Dbee::KeyChain.new(key_paths)

    actual_schema = Cycles::A.to_schema(key_chain)
    expect(actual_schema).to eq(expected_schema)
  end

  describe 'partitioners' do
    it 'honors partitioners on a root model' do
      model_name      = 'Partitioner Example 1'
      expected_config = yaml_fixture('models.yaml')[model_name]
      expected_schema = Dbee::Schema.new(expected_config)

      key_paths = %w[id]
      key_chain = Dbee::KeyChain.new(key_paths)

      actual_schema = PartitionerExamples::Dog.to_schema(key_chain)

      expect(actual_schema).to eq(expected_schema)
    end

    it 'honors partitioners on a child model' do
      model_name      = 'Partitioner Example 2'
      expected_config = yaml_fixture('models.yaml')[model_name]
      expected_schema = Dbee::Schema.new(expected_config)

      key_paths = %w[id dogs.id]
      key_chain = Dbee::KeyChain.new(key_paths)

      actual_schema = PartitionerExamples::Owner.to_schema(key_chain)

      expect(actual_schema).to eq(expected_schema)
    end
  end

  context 'README examples' do
    specify 'code-first and configuration-first models are equal' do
      config        = yaml_fixture('models.yaml')['Readme']
      config_schema = Dbee::Schema.new(config)

      key_chain = Dbee::KeyChain.new(%w[
                                       patients.a
                                       patients.notes.b
                                       patients.work_phone_number.c
                                       patients.cell_phone_number.d
                                       patients.fax_phone_number.e
                                     ])

      code_schema = ReadmeDataModels::Practice.to_schema(key_chain)

      expect(config_schema).to eq(code_schema)
    end
  end
end
