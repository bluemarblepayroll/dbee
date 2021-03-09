# 3.0.0 (TBD)

### Additions

* Support for graph based models. This paves the way for representing more advanced features, such as sub-queries in a more clear way. Since graph based models are similar to DSL models, the hope is that they will be easier to work with and understand.

### Breaking Changes

* The `to_model` method on `Dbee::Base` objects has been removed. Use `to_schema` instead.
# 2.1.1 (July 14th, 2020)

* Removed guard that ensured a query has at least one field to establish a more rational base-case.

# 2.1.0 (July 13th, 2020)

### Additions:

* Added Dbee::Query::Field#aggregator (such as ave, min, max, sum, etc.)
* Added Dbee::Query::Field#filters (allows for doing select column filtering)

### Changes:

* Bumped minimum Ruby version to 2.5

# 2.0.3 (January 7th, 2020)

### Fixes:

* Constant resolution will now explicitly set inherit to false when calling `Object#const_defined?` and `Object#const_get`.  This should equate to less false positives.  For example:

```ruby
class A; end

module B
  class A; end
  class C; end
end
```

If `B::A` is the desired class, it would not be suitable to just declare an association on `A` as that would resolve explicitly to `::A`.  It also means C cannot be auto-resolved without prefixing/sharing the namespace with parent association `A`.

# 2.0.2 (November 7th, 2019)

### Additions:

* As of 2019-11-07, it is not recommended to use Ruby 2.3, but support was requested and added for Ruby 2.3.8.  This is subject to being deprecated with next version.

### Fixes:

* Constantizing during inflection will now first check Object#const_defined? and if it is missing, it will now call Object#const_missing.  This should work better with auto-loaded environments where constant names may collide, since Object#const_get will traverse down the entire hierarchy and may lead to false positives.

# 2.0.0 (September 3rd, 2019)

### Additions:

* New DSL method for declaring child associations: `child`.
* New DSL method for declaring parent associations: `parent`.
* Added global inflection using Dry::Inflector, can be overridden using Dbee.inflector = Dry::Inflector.new # or some other instance.

### Breaking changes:

Inflection was introduced with this release and hence changes some of the default naming inference behavior:

* Table name is now inferred to be the pluralized and de-modulized class name (unless explicitly declared.)
* Top level root model name is inferred to be the underscored and de-modulized class name.
* Model is now inferred to be the relative, singular, and camelized association name (unless explicitly declared.)

# 1.2.1 (September 1st, 2019)

### Fixes:

* Dbee::Base table name should default to the most-parent table name (if none are explicitly defined.)  Overriding still takes most child sub-class precedence.

# 1.2.0 (August 29th, 2019)

### Additions:

* Added partitioners to a model specification.  A Partitioner is essentially a way of explicitly specifying that a data model must meet a specific equality for a column.

### Changes:

* Model#ancestors renamed to Model#ancestors!
* Model#ancestor now returns a hash where the key is an array of strings and not just a pre-concatenated string.

# 1.1.0 (August 28th, 2019)

### Additions:

* Added better equality and sort methods for Ruby objects (added class type checks where needed.)

### Changes:

* Removed Sorter in favor of Sorter subclasses.
* Duplicate filters and sorters will be ignored in a Query.

# 1.0.3 (August 27th, 2019)

### Additions:

* Added 'parent' keyword for static constraints.  This makes it possible to have a static constraint apply to a parent and not just a child relationship.

# 1.0.2 (August 26th, 2019)

### Fixes:

* Dbee::Base subclasses can now support cycles to N-depth, where N is limited by the Query.  The recursion will go as far as the Query specifies it has to go.

### Additions:

* Equals filter is now the default type when type is omitted.
* model can now be a string so it can be lazy evaluated at run-time instead of at script evaluation time.

# 1.0.1 (August 26th, 2019)

### Fixes:

* Dbee::Base subclasses can now declare self-referential associations.  Note that it will stop the hierarchy once the cycle is detected.

### Additions:

* Static constraint is now the default type when type is omitted.

# 1.0.0 (August 22nd, 2019)

Initial release.

# 1.0.0-alpha (August 18th, 2019)

Added initial implementation.

# 0.0.1 (August 18th, 2019)

Created Repo Shell
