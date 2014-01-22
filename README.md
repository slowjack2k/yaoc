# Yaoc

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

User = Struct.new(:id, :name) do
  def initialize(params={})
    super()

    params.each do |attr, value|
      self.public_send("#{attr}=", value)
    end if params
   end
end

mapper = Yaoc::ObjectMapper.new(User).tap do |mapper|
  mapper.add_mapping do
    rule to: :name, from: :fullname
    rule to: :id
  end
end


user = mapper.load({id: 1, fullname: "myname" })


```

## Contributing

1. Fork it ( http://github.com/<my-github-username>/yaoc/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
