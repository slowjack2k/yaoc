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
         converter: ->(source, result){ result.merge({firstname:
                                                      source.fullname.split().first }) },
         reverse_converter: ->(source, result){ result.merge({fullname:
                                                              "#{source.firstname} #{source.lastname}" }) }

    rule to: :lastname,
         from: :fullname,
         converter: ->(source, result){ result.merge({lastname:  source.fullname.split().last }) },
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

## Contributing

1. Fork it ( http://github.com/<my-github-username>/yaoc/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
