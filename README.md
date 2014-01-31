# Yaoc [![Code Climate](https://codeclimate.com/github/slowjack2k/yaoc.png)](https://codeclimate.com/github/slowjack2k/yaoc) [![Build Status](https://travis-ci.org/slowjack2k/yaoc.png?branch=master)](https://travis-ci.org/slowjack2k/yaoc) [![Coverage Status](https://coveralls.io/repos/slowjack2k/yaoc/badge.png?branch=master)](https://coveralls.io/r/slowjack2k/yaoc?branch=master) [![Gem Version](https://badge.fury.io/rb/yaoc.png)](http://badge.fury.io/rb/yaoc)

Converting one ruby object into another with some rules.

## Installation

Add this line to your application's Gemfile:

    gem 'yaoc'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install yaoc

## Usage

For uptodate doc's take a look into the specs.

### The resulting classes have hash enabled constructors?

```ruby

require 'yaoc'

include Yaoc::Helper

User = StructHE(:id, :firstname, :lastname, :role)

OldUser = StructHE(:id, :fullname, :r_role)

mapper = Yaoc::ObjectMapper.new(User, OldUser).tap do |mapper|
  mapper.add_mapping do
    fetcher :public_send
    rule to: :role, from: :r_role

    rule to: :firstname,
         from: :fullname,
         converter: ->(source, result){ Yaoc::TransformationCommand.fill_result_with_value(result, :firstname, source.fullname.split().first) },
         reverse_converter: ->(source, result){ Yaoc::TransformationCommand.fill_result_with_value(result, :fullname,  "#{source.firstname} #{source.lastname}") }

    rule to: :lastname,
         from: :fullname,
         converter: ->(source, result){ Yaoc::TransformationCommand.fill_result_with_value(result, :lastname, source.fullname.split().last ) },
         reverse_converter: ->(source, result){ result }

    rule to: :id
  end
end

old_user = OldUser.new({id: 1, fullname: "myfirst mysecond", r_role: "admin" })
new_user = mapper.load(old_user)

puts old_user
puts new_user

new_user.firstname = "no"
new_user.lastname = "name"

puts mapper.dump(new_user)

#<struct OldUser id=1, fullname="myfirst mysecond", r_role="admin">
#<struct User id=1, firstname="myfirst", lastname="mysecond", role="admin">
#<struct OldUser id=1, fullname="no name", r_role="admin">


```

### The resulting classes have no hash enabled constructor?

```ruby

require 'yaoc'

include Yaoc::Helper

OldUser2 = Struct.new(:id, :fullname, :r_role)

User2 = Struct.new(:id, :firstname, :lastname, :role)

reverse_source = ->(attrs){
  OldUser2.new.tap do |old_user|
    attrs.each_pair do |key, value|
      old_user.public_send "#{key}=", value
    end
  end
}

source = ->(attrs){
  User2.new.tap do |old_user|
    attrs.each_pair do |key, value|
      old_user.public_send "#{key}=", value
    end
  end
}

mapper = Yaoc::ObjectMapper.new(source, reverse_source).tap do |mapper|
  mapper.add_mapping do
    fetcher :public_send
    rule to: :role, from: :r_role

    rule to: :firstname,
         from: :fullname,
         converter: ->(source, result){ Yaoc::TransformationCommand.fill_result_with_value(result, :firstname,  source.fullname.split().first ) },
         reverse_converter: ->(source, result){ Yaoc::TransformationCommand.fill_result_with_value(result, :fullname, "#{source.firstname} #{source.lastname}") }

    rule to: :lastname,
         from: :fullname,
         converter: ->(source, result){ Yaoc::TransformationCommand.fill_result_with_value(result, :lastname,  source.fullname.split().last) },
         reverse_converter: ->(source, result){ result }

    rule to: :id
  end
end

old_user2 = OldUser2.new(1, "myfirst mysecond",  "admin" )
new_user2 = mapper.load(old_user2)

puts old_user2
puts new_user2

new_user2.firstname = "no"
new_user2.lastname = "name"

puts mapper.dump(new_user2)


#<struct OldUser2 id=1, fullname="myfirst mysecond", r_role="admin">
#<struct User2 id=1, firstname="myfirst", lastname="mysecond", role="admin">
#<struct OldUser2 id=1, fullname="no name", r_role="admin">

```

### But my classes have positional constructor, what now?

```ruby

require 'yaoc'

include Yaoc::Helper

puts "\n" * 5

OldUser3 = Struct.new(:id, :fullname, :r_role)
User3 = Struct.new(:id, :firstname, :lastname, :role)

# alternative to proc for converter
converter = Yaoc::TransformationCommand.create(to: 1,
                                               from: :fullname,
                                               deferred: false,
                                               fetcher_proc: ->(source, fetcher, from){source.fullname.split().first} )

reverse_converter = Yaoc::TransformationCommand.create(to: 1,
                                                       from: :first_and_lastname,
                                                       deferred: false,
                                                       fetcher_proc: ->(source, fetcher, from){ "#{source.firstname} #{source.lastname}"} )

mapper = Yaoc::ObjectMapper.new(User3, OldUser3).tap do |mapper|
  mapper.add_mapping do
    fetcher :public_send

    strategy :to_array_mapping
    reverse_strategy :to_array_mapping

    rule to: 0, from: :id,
         reverse_to: 0, reverse_from: :id

    rule to: 1,
         from: :fullname,

         converter: converter,
         reverse_converter: reverse_converter

    rule to: 2,
         from: :fullname,

         converter: ->(source, result){ result[2]  = source.fullname.split().last },
         reverse_converter: ->(source, result){ result }

    rule to: 3, from: :r_role,
         reverse_to: 2, reverse_from: :role

  end
end

old_user3 = OldUser3.new(1, "myfirst mysecond",  "admin" )
new_user3 = mapper.load(old_user3)

puts old_user3
puts new_user3

new_user3.firstname = "no"
new_user3.lastname = "name"

puts mapper.dump(new_user3)


#<struct OldUser3 id=1, fullname="myfirst mysecond", r_role="admin">
#<struct User3 id=1, firstname="myfirst", lastname="mysecond", role="admin">
#<struct OldUser3 id=1, fullname="no name", r_role="admin">

```

### And how to use it with compositions?

```ruby

require 'yaoc'

include Yaoc::Helper


puts "\n" * 5


User4 = StructHE(:id, :firstname, :lastname, :roles)

OldUser4 = StructHE(:o_id, :o_firstname, :o_lastname, :o_roles)


Role = StructHE(:id, :name)

OldRole = StructHE(:o_id, :o_name)


role_mapper = Yaoc::ObjectMapper.new(Role, OldRole).tap do |mapper|
  mapper.add_mapping do
    fetcher :public_send

    rule to: :id, from: :o_id
    rule to: :name, from: :o_name

  end
end

user_mapper = Yaoc::ObjectMapper.new(User4, OldUser4).tap do |mapper|
  mapper.add_mapping do
    fetcher :public_send

    rule to: [:id, :firstname, :lastname],
         from: [:o_id, :o_firstname, :o_lastname]

    rule to: :roles,
         from: :o_roles,
         object_converter: role_mapper,
         is_collection: true

  end
end


old_user4 = OldUser4.new(o_id: 1,
                         o_firstname: "firstname",
                         o_lastname:"lastname",
                         o_roles: [OldRole.new(o_id: 1, o_name: "admin"), OldRole.new(o_id: 2, o_name: "guest")] )
new_user4 = user_mapper.load(old_user4)

puts old_user4
puts new_user4

puts user_mapper.dump(new_user4)

#<struct OldUser4 o_id=1, o_firstname="firstname", o_lastname="lastname",
# o_roles=[#<struct OldRole o_id=1, o_name="admin">, #<struct OldRole o_id=2, o_name="guest">]>
#<struct User4 id=1, firstname="firstname", lastname="lastname",
# roles=[#<struct Role id=1, name="admin">, #<struct Role id=2, name="guest">]>
#<struct OldUser4 o_id=1, o_firstname="firstname", o_lastname="lastname",
# o_roles=[#<struct OldRole o_id=1, o_name="admin">, #<struct OldRole o_id=2, o_name="guest">]>

```

### And how can I add values to existing objects?

```ruby
require 'yaoc'

include Yaoc::Helper

puts "\n" * 5

OldUser5 = StructHE(:id, :name)

RoleThing = StructHE(:id, :role)

User5 = StructHE(:id, :name,  :role)


user_mapper = Yaoc::ObjectMapper.new(User5, OldUser5).tap do |mapper|
  mapper.add_mapping do
    fetcher :public_send
    rule to: [:id, :name]
  end
end

role_mapper = Yaoc::ObjectMapper.new(User5, RoleThing).tap do |mapper|
  mapper.add_mapping do
    fetcher :public_send
    rule to: [:role]
  end
end

old_role = RoleThing.new(id: 1, role: "my_role")
old_user5 = OldUser5.new(id: 1, name: "my fullname")

new_user5 = user_mapper.load(old_user5)

role_mapper.load(old_role, new_user5)

# OR
#
# mapper_chain = Yaoc::MapperChain.new(user_mapper, role_mapper)
# new_user5 = mapper_chain.load([old_user5, old_role])


puts old_user5
puts old_role
puts new_user5

#<struct OldUser5 id=1, name="my fullname">
#<struct RoleThing id=1, role="my_role">
#<struct User5 id=1, name="my fullname", role="my_role">

```

### How can I lazy load some expensive to convert attributes?

```ruby
require 'yaoc'

include Yaoc::Helper

puts "\n" * 5


OldUser6 = StructHE(:id) do

  def names=(new_names)
    @names = new_names
  end

  def names
    puts 'some expensive operation in progress ...'
    sleep 10
    @names
  end

end
User6 = StructHE(:id, :names)


user_mapper = Yaoc::ObjectMapper.new(User6, OldUser6).tap do |mapper|
  mapper.add_mapping do
    fetcher :public_send
    rule to: [:id, :names],
         lazy_loading: [false, true]
  end
end

old_user6 = OldUser6.new(id: 'my_id_1', names: ['one', 'two', 'three', 'four'])
new_user6 = user_mapper.load(old_user6)

puts new_user6.id.inspect
puts new_user6.names.inspect
puts new_user6


puts "\n" * 5

# "my_id_1"
# some expensive operation in progress ...
# ["one", "two", "three", "four"]
#<struct User6 id="my_id_1", names=["one", "two", "three", "four"]>

```

## Contributing

1. Fork it ( http://github.com/slowjack2k/yaoc/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
