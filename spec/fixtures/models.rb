# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module Models
  class Movie < Dbee::Base; end

  class PhoneNumber < Dbee::Base; end

  class Demographic < Dbee::Base
    child :phone_numbers
  end

  class MemberBase < Dbee::Base
    child :demos, model: 'Models::Demographic', foreign_key: :member_id

    child :movies, foreign_key: :member_id
  end

  class Member < MemberBase
    table 'members'

    child :favorite_comic_movies, model: Movie, static: { name: :genre, value: 'comic' }

    child :favorite_mystery_movies, model: Movie, constraints: [
      { type: :static, name: :genre, value: 'mystery' }
    ]

    child :favorite_comedy_movies, model: Movie, constraints: {
      type: :static, name: :genre, value: 'comedy'
    }
  end

  class TheaterBase < Dbee::Base
    child :members, foreign_key: :tid, constraints: [
      { type: :reference, name: :partition, parent: :partition }
    ]
  end

  class Theater < TheaterBase
    table 'theaters'

    parent :parent_theater, model: self

    child :member_derived_tests
  end

  class MemberDerivedTest < Dbee::Base
    query({
            # allow model to be a class reference?
            model: 'theaters.members',
            fields: [
              { key_path: :members_column }
            ]
          })
  end

  class A < Dbee::Base
    table 'table_set_to_a'
  end

  class B < A
    table 'table_set_to_b'
  end

  class C < A; end

  class D < A
    table ''
  end

  class E < B
    table 'table_set_to_e'
  end
end

module ReadmeDataModels
  class PhoneNumber < Dbee::Base
    table :phones
  end

  class Note < Dbee::Base; end

  class Patient < Dbee::Base
    child :notes

    child :work_phone_number, model: PhoneNumber, static: {
      name: :phone_number_type, value: 'work'
    }

    child :cell_phone_number, model: PhoneNumber, constraints: [
      { type: :static, name: :phone_number_type, value: 'cell' }
    ]

    child :fax_phone_number, model: PhoneNumber, constraints: [
      { type: :static, name: :phone_number_type, value: 'fax' }
    ]
  end

  class Practice < Dbee::Base
    association :patients, constraints: {
      type: :reference, name: :practice_id, parent: :id
    }
  end
end

module Cycles
  class BaseA < Dbee::Base
    association :b1, model: 'Cycles::B'
  end

  class A < BaseA
    table :as

    association :b2, model: 'Cycles::B'
  end

  class B < Dbee::Base
    association :c

    association :d
  end

  class C < Dbee::Base
    association :a
  end

  class D < Dbee::Base
    association :a
  end
end

# Examples of Rails Single Table Inheritance.
module PartitionerExamples
  class Owner < Dbee::Base
    child :dogs
  end

  class Animal < Dbee::Base; end

  class Dog < Animal
    partitioner :type, 'Dog'

    partitioner :deleted, false
  end
end
