# Dbee

[![Gem Version](https://badge.fury.io/rb/dbee.svg)](https://badge.fury.io/rb/dbee) [![Build Status](https://travis-ci.org/bluemarblepayroll/dbee.svg?branch=master)](https://travis-ci.org/bluemarblepayroll/dbee) [![Maintainability](https://api.codeclimate.com/v1/badges/208b36a1d13751687df9/maintainability)](https://codeclimate.com/github/bluemarblepayroll/dbee/maintainability) [![Test Coverage](https://api.codeclimate.com/v1/badges/208b36a1d13751687df9/test_coverage)](https://codeclimate.com/github/bluemarblepayroll/dbee/test_coverage) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Dbee arose out of a need for an ad-hoc reporting solution that included:

* serializable queries
* serializable data modeling
* de-coupling from our main ORM (ActiveRecord)
* Rails 5.2.1 and above compatibility

Dbee provides very simple Data Modeling and Query API's and as such it is not meant to replace a traditional ORM or your data persistence layer, but compliment them.  This library's goal is to output the SQL statement needed and **nothing** more.

Other solutions considered:

* [Squeel](https://github.com/activerecord-hackery/squeel) - Was in production use up until Rails 5, then saw compatibility issues.
* [BabySqueel](https://github.com/rzane/baby_squeel) - Tested with some success up until Rails 5.2.1, then saw compatibility issues.

Both of these solutions ended up closely coupling our domain data layer to ad-hoc reporting layer.  One of the primary motivations for this library was to completely de-couple the data modeling from persistence modeling.

## Installation

This specific library is the core modeling component of the Dbee framework, but by itself, it not completely usable.  You will need to provide a SQL generator which understands how to convert the data and query modeling to actual SQL.  This library comes with a stub: Dbee::Providers::NullProvider, while the main reference implementation is split out into its own library: [dbee-active_record](https://github.com/bluemarblepayroll/dbee-active_record). Together these two libraries comprise a complete solution.  Refer to the other library for more information on installation.

To install through Rubygems:

````
gem install install dbee
````

You can also add this to your Gemfile:

````
bundle add dbee
````

## Examples

### The Data Model API

Consider the following simple pseudo-schema:

```
TABLE practices (
  id:integer,
  active:boolean (nullable),
  name:string
)

TABLE patients (
  id:integer,
  practice_id:integer,
  first:string,
  middle:string,
  last:string,
  chart_number:string
)

TABLE notes (
  id:integer,
  patient_id:integer,
  note_type:string,
  contents:string
)

TABLE phones (
  id:integer,
  patient_id:integer,
  phone_number_type:string,
  number:string
  )
```

*Note: Do not think too much into the merits of the above schema, it is a contrived and simplified example.*

In this example: a practice has many patients, a patient has many notes, and a patient also has many phones.  It is important to note, though, that a patient can only have one unique phone number per phone number type (such as home, cell, fax, work, etc.)

There are two ways to model this schema using Dbee:

1. code-first
2. configuration-first

#### Code-First Data Modeling (With Inflection)

Code-first data modeling involves creating sub-classes of Dbee::Base that describes the tables and associations.  We could model the above example as:

````ruby
module ReadmeDataModels
  class PhoneNumber < Dbee::Base
    table :phones

    parent :patient
  end

  class Note < Dbee::Base
    parent :patient
  end

  class Patient < Dbee::Base
    child :notes

    child :work_phone_number, model: 'ReadmeDataModels::PhoneNumber',
                              static: { name: :phone_number_type, value: 'work' }

    child :cell_phone_number, model: 'ReadmeDataModels::PhoneNumber',
                              static: { name: :phone_number_type, value: 'cell' }

    child :fax_phone_number,  model: 'ReadmeDataModels::PhoneNumber',
                              static: { name: :phone_number_type, value: 'fax' }
  end

  class Practice < Dbee::Base
    child :patients
  end
end
````

The two DSL methods: parent/child are very similar to ActiveRecord's belongs_to/has_many, respectively.  Options for these methods are:

* **model**: class constant, string, or symbol to use as associated data model.  If omitted, the model name will be the relative, singular, and camelized version of the association name.
* **foreign_key**: name of the key on the child table.  If omitted for child then it will resolve as singular, underscored, de-modulized class name suffixed with '\_id'.  If omitted for parent it will resolve to 'id'.
* **primary_key**: name of the key on the parent table.  If omitted for child then it will resolve as 'id'.  If omitted for parent then it will resolve as the singular, underscored, de-modulized name of the relationship suffixed with '\_id'

##### Customizing Inflection Rules

Inflection is provided via the [Dry::Inflector gem](https://github.com/dry-rb/dry-inflector).  There are options to add custom grammar rules which you can then pass into Dbee.  For example:

````ruby
Dbee.inflector = Dry::Inflector.new do |inflections|
  inflections.plural      'virus',   'viruses' # specify a rule for #pluralize
  inflections.singular    'thieves', 'thief'   # specify a rule for #singularize
  inflections.uncountable 'dry-inflector'      # add an exception for an uncountable word
end
````

#### Code-First Data Modeling (Without Inflection)

You can use the raw `association` method you wish to fully control the entire referencing configuration.

````ruby
module ReadmeDataModels
  class PhoneNumber < Dbee::Base
    table :phones

    association :patient, model: 'ReadmeDataModels::Patient', constraints: {
      type: :reference, name: :patient_id, parent: :id
    }
  end

  class Note < Dbee::Base
    association :patient, model: 'ReadmeDataModels::Patient', constraints: {
      type: :reference, name: :patient_id, parent: :id
    }
  end

  class Patient < Dbee::Base
    association :notes, model: 'ReadmeDataModels::Note', constraints: {
      type: :reference, name: :patient_id, parent: :id
    }

    association :work_phone_number, model: 'ReadmeDataModels::PhoneNumber', constraints: [
      { type: :reference, name: :patient_id, parent: :id },
      { type: :static, name: :phone_number_type, value: 'work' }
    ]

    association :cell_phone_number, model: 'ReadmeDataModels::PhoneNumber', constraints: [
      { type: :reference, name: :patient_id, parent: :id },
      { type: :static, name: :phone_number_type, value: 'cell' }
    ]

    association :fax_phone_number, model: 'ReadmeDataModels::PhoneNumber', constraints: [
      { type: :reference, name: :patient_id, parent: :id },
      { type: :static, name: :phone_number_type, value: 'fax' }
    ]
  end

  class Practice < Dbee::Base
    association :patients, model: Patient, constraints: {
      type: :reference, name: :practice_id, parent: :id
    }
  end
end
````

The two code-first examples above should be technically equivalent.

#### Configuration-First Data Modeling

You can choose to alternatively describe your data model using configuration.  The YAML below is equivalent to the Ruby sub-classes above:

````yaml
name: practice
models:
  - name: patients
    constraints:
      - type: reference
        name: practice_id
        parent: id
    models:
      - name: notes
        constraints:
          - type: reference
            name: patient_id
            parent: id
      - name: work_phone_number
        table: phones
        constraints:
          - type: reference
            name: patient_id
            parent: id
          - type: static
            name: phone_number_type
            value: work
      - name: cell_phone_number
        table: phones
        constraints:
          - type: reference
            name: patient_id
            parent: id
          - type: static
            name: phone_number_type
            value: cell
      - name: fax_phone_number
        table: phones
        constraints:
          - type: reference
            name: patient_id
            parent: id
          - type: static
            name: phone_number_type
            value: fax
````

It is up to you to determine which modeling technique to use as both are equivalent.  Technically speaking, the code-first DSL is nothing more than syntactic sugar on top of Dbee::Model.

#### Table Partitioning

You can leverage the model partitioners for hard-coding partitioning by column=value.  The initial use-case for this was to mirror how ActiveRecord deals with (Single Table Inheritance)[https://api.rubyonrails.org/v6.0.0/classes/ActiveRecord/Base.html#class-ActiveRecord::Base-label-Single+table+inheritance].  Here is a basic example of how to partition an `animals` table for different subclasses:

##### Code-first:

````ruby
class Animal < Dbee::Base
end

class Dog < Animal
  partitioner :type, 'Dog'
end

class Cat < Animal
  partitioner :type, 'Cat'
end
````

##### Configuration-first:

````yaml
Dogs:
  name: dog
  table: animals
  partitioners:
    - name: type
      value: Dog

Cats:
  name: cat
  table: animals
  partitioners:
    - name: type
      value: Cat
````

### The Query API

The Query API (Dbee::Query) is a simplified and abstract way to model an SQL query.  A Query has the following components:

* fields (SELECT)
* filters (WHERE)
* sorters (ORDER BY)
* limit (LIMIT/TAKE)

One very important concept is that all joins are `LEFT OUTER JOIN's`.  This is an intentional simplification for our key application domain: configurable custom reporting.

#### Key Paths

You use key paths in order to identify columns.  All key paths are relative to the main data model.

#### Sample Queries

Get all practices:

````ruby
query = {
  fields: [
    { key_path: 'id' },
    { key_path: 'active' },
    { key_path: 'name' }
  ]
}
````

Get all practices, limit to 10, and sort by name (descending) then id (ascending):

````ruby
query = {
  fields: [
    { key_path: 'id' },
    { key_path: 'active' },
    { key_path: 'name' }
  ],
  sorters: [
    { key_path: 'name', direction: :descending },
    { key_path: 'id' }
  ],
  limit: 10
}
````

Get top 5 active practices and patient whose name start with 'Sm':

````ruby
query = {
  fields: [
    { key_path: 'name', display: 'Practice Name' },
    { key_path: 'patients.first', display: 'Patient First Name' },
    { key_path: 'patients.middle', display: 'Patient Middle Name' },
    { key_path: 'patients.last', display: 'Patient Last Name' },
  ],
  filters: [
    { type: :equals, key_path: 'active', value: true },
    { type: :starts_with, key_path: 'patients.last', value: 'Sm' },
  ],
  limit: 5
}
````

Get practice IDs, patient IDs, names, and cell phone numbers that starts with '555':

````ruby
query = {
  fields: [
    { key_path: 'id', display: 'Practice ID #' },
    { key_path: 'patients.id', display: 'Patient ID #' },
    { key_path: 'patients.first', display: 'Patient First Name' },
    { key_path: 'patients.middle', display: 'Patient Middle Name' },
    { key_path: 'patients.last', display: 'Patient Last Name' },
    { key_path: 'patients.cell_phone_numbers.phone_number', display: 'Patient Cell #' },
  ],
  filters: [
    { type: :equals, key_path: 'active', value: true },
    {
      type: :starts_with,
      key_path: 'patients.cell_phone_numbers.phone_number',
      value: '555'
    },
  ]
}
````

#### Executing a Query

You execute a Query against a Data Model, using a Provider.  The sample provider: Dbee::Providers::NullProvider is just meant as a stand-in.  You will need to plug in a custom provider for real-world use. [See the reference ActiveRecord plugin implementation here.](https://github.com/bluemarblepayroll/dbee-active_record)

Here are some sample executions based off the preceding examples:

##### Code-First Execution

````ruby
require 'dbee/providers/active_record_provider'

class Practice < Dbee::Base; end

provider = Dbee::Providers::ActiveRecordProvider.new

query = {
  fields: [
    { key_path: 'id' },
    { key_path: 'active' },
    { key_path: 'name' }
  ]
}

sql = Dbee.sql(Practice, query, provider)
````

##### Configuration-First Execution

````ruby
require 'dbee/providers/active_record_provider'

provider = Dbee::Providers::ActiveRecordProvider.new

model = {
  name: :practice
}

query = {
  fields: [
    { key_path: 'id' },
    { key_path: 'active' },
    { key_path: 'name' }
  ]
}

sql = Dbee.sql(model, query, provider)
````

The above examples showed how to use a plugin provider, see the plugin provider's documentation for more information about its options and use.

#### Aggregation

Fields can be configured to use aggregation by setting its `aggregator` attribute.  For example, say we wanted to count the number of patients per practice:

**Data Model**:

````yaml
name: practice
models:
  - name: patients
    constraints:
      - type: reference
        name: practice_id
        parent: id
````

**Query**:

````ruby
query = {
  fields: [
    {
      key_path: 'id',
      display: 'Practice ID #',
    },
    {
      key_path: 'name',
      display: 'Practice Name',
    },
    {
      key_path: 'patients.id',
      display: 'Total Patients',
      aggregator: :count
    },
  ]
````

An example of a materialized result would be something akin to:

Practice ID # | Practice Name   | Total Patients
------------- | --------------- | --------------
1             | Families Choice | 293
2             | Awesome Choice  | 2305
3             | Best Value      | 1200

A complete list of aggregator values can be found by inspecting the `Dbee::Query::Field::Aggregator` constant.

#### Field/Column Level Filtering & Pivoting

Fields can also have filters which provide post-filtering (on the select-level instead of at query-level.)  This can be used in conjunction with aggregate functions to provide pivoting.  For example:

**Data/Schema Example**:

patients:

id | first | last
-- | ----- | -----
1  | frank | rizzo

patient_fields:

id | patient_id | key             | value
-- | ---------- | --------------- | -----
1  | 1          | dob             | 1900-01-01
2  | 1          | drivers_license | ABC123

**Model Configuration**:

````yaml
name: patients
models:
  - name: patient_fields
    constraints:
      - type: reference
        parent: id
        name: patient_id
````

**Query**:

````ruby
query = {
  fields: [
    {
      key_path: 'id',
      display: 'ID #'
    },
    {
      key_path: 'first',
      display: 'First Name'
    },
    {
      aggregator: :max,
      key_path: 'patient_fields.value',
      display: 'Date of Birth',
      filters: [
        {
          key_path: 'patient_fields.key',
          value: 'dob'
        }
      ]
    },
    {
      aggregator: :max,
      key_path: 'patient_fields.value',
      display: 'Drivers License #',
      filters: [
        {
          key_path: 'patient_fields.key',
          value: 'drivers_license'
        }
      ]
    }
  }
}
````

Executing the query above against the data and model would yield:

ID # | First Name | Date of Birth | Drivers License #
--   | ---------- | ------------- | -----------------
1    | frank      | 1900-01-01    | ABC123


## Contributing

### Development Environment Configuration

Basic steps to take to get this repository compiling:

1. Install [Ruby](https://www.ruby-lang.org/en/documentation/installation/) (check dbee.gemspec for versions supported)
2. Install bundler (gem install bundler)
3. Clone the repository (git clone git@github.com:bluemarblepayroll/dbee.git)
4. Navigate to the root folder (cd dbee)
5. Install dependencies (bundle)

### Running Tests

To execute the test suite run:

````bash
bundle exec rspec spec --format documentation
````

Alternatively, you can have Guard watch for changes:

````bash
bundle exec guard
````

Also, do not forget to run Rubocop:

````bash
bundle exec rubocop
````

### Publishing

Note: ensure you have proper authorization before trying to publish new versions.

After code changes have successfully gone through the Pull Request review process then the following steps should be followed for publishing new versions:

1. Merge Pull Request into master
2. Update `lib/dbee/version.rb` using [semantic versioning](https://semver.org/)
3. Install dependencies: `bundle`
4. Update `CHANGELOG.md` with release notes
5. Commit & push master to remote and ensure CI builds master successfully
6. Run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Code of Conduct

Everyone interacting in this codebase, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/bluemarblepayroll/dbee/blob/master/CODE_OF_CONDUCT.md).

## License

This project is MIT Licensed.
