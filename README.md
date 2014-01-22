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

User = Struct.new(:id, :name) do
  def initialize(params={})
    super()

    params.each do |attr, value|
      self.public_send("#{attr}=", value)
    end if params
   end
end

OldUser = Struct.new(:id, :fullname) do
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
    rule to: :name, from: :fullname
    rule to: :id
  end
end

old_user = OldUser.new({id: 1, fullname: "myname" })
new_user = mapper.load(old_user)


```

## Contributing

1. Fork it ( http://github.com/<my-github-username>/yaoc/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
