# Yaoc

Indentation of this gem is to learn and train a little ruby.

## Installation

Add this line to your application's Gemfile:

    gem 'yaoc'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install yaoc

## Usage

Uptodate doc's look into the specs.

### The resulting classes have hash enabled constructors?

```ruby

require 'yaoc'

User = Struct.new(:id, :firstname, :lastname, :role) do
  def initialize(params={})
    super()

    params.each do |attr, value|
      self.public_send("#{attr}=", value)
    end if params
   end
end

OldUser = Struct.new(:id, :fullname, :r_role) do
  def initialize(params={})
    super()

    params.each do |attr, value|
      self.public_send("#{attr}=", value)
    end if params
   end
end

mapper = Yaoc::ObjectMapper.new(User, OldUser).tap do |mapper|
  mapper.add_mapping do
    fetcher :public_send
    rule to: :role, from: :r_role

    rule to: :firstname,
         from: :fullname,
         converter: ->(source, result){ fill_result_with_value(result, :firstname, source.fullname.split().first) },
         reverse_converter: ->(source, result){ fill_result_with_value(result, :fullname,  "#{source.firstname} #{source.lastname}") }

    rule to: :lastname,
         from: :fullname,
         converter: ->(source, result){ fill_result_with_value(result, :lastname, source.fullname.split().last ) },
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
         converter: ->(source, result){ fill_result_with_value(result, :firstname,  source.fullname.split().first ) },
         reverse_converter: ->(source, result){ fill_result_with_value(result, :fullname, "#{source.firstname} #{source.lastname}") }

    rule to: :lastname,
         from: :fullname,
         converter: ->(source, result){ fill_result_with_value(result, :lastname,  source.fullname.split().last) },
         reverse_converter: ->(source, result){ result }

    rule to: :id
  end
end

old_user2 = OldUser2.new(1, "myfirst mysecond",  "admin" )
new_user2 = mapper.load(old_user)

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
OldUser3 = Struct.new(:id, :fullname, :r_role)
User3 = Struct.new(:id, :firstname, :lastname, :role)


mapper = Yaoc::ObjectMapper.new(User3, OldUser3).tap do |mapper|
  mapper.add_mapping do
    fetcher :public_send

    strategy :to_array_mapping
    reverse_strategy :to_array_mapping

    rule to: 0, from: :id,
         reverse_to: 0, reverse_from: :id

    rule to: 1,
         from: :fullname,

         converter: ->(source, result){ fill_result_with_value(result, 1, source.fullname.split().first)  },
         reverse_converter: ->(source, result){ fill_result_with_value(result, 1,  "#{source.firstname} #{source.lastname}") }

    rule to: 2,
         from: :fullname,

         converter: ->(source, result){ result[2]  = source.fullname.split().last },
         reverse_converter: ->(source, result){ result }

    rule to: 3, from: :r_role,
         reverse_to: 2, reverse_from: :role

  end
end

old_user3 = OldUser3.new(1, "myfirst mysecond",  "admin" )
new_user3 = mapper.load(old_user)

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

User4 = Struct.new(:id, :firstname, :lastname, :roles) do
  def initialize(params={})
    super()

    params.each do |attr, value|
      self.public_send("#{attr}=", value)
    end if params
  end
end

OldUser4 = Struct.new(:o_id, :o_firstname, :o_lastname, :o_roles) do
  def initialize(params={})
    super()

    params.each do |attr, value|
      self.public_send("#{attr}=", value)
    end if params
  end
end


Role = Struct.new(:id, :name) do
  def initialize(params={})
    super()

    params.each do |attr, value|
      self.public_send("#{attr}=", value)
    end if params
  end
end

OldRole = Struct.new(:o_id, :o_name) do
  def initialize(params={})
    super()

    params.each do |attr, value|
      self.public_send("#{attr}=", value)
    end if params
  end
end


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
         converter: ->(source, result){ fill_result_with_value(result, :roles,  (source.o_roles || []).map{|role|  role_mapper.load(role)}) },
         reverse_converter: ->(source, result){ fill_result_with_value(result, :o_roles, (source.roles || []).map{|role|  role_mapper.dump(role)}) }

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

## Contributing

1. Fork it ( http://github.com/slowjack2k/yaoc/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
