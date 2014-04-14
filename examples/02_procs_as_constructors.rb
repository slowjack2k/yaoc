require 'bundler/setup'
Bundler.require(:development)

require 'yaoc'

include Yaoc::Helper

puts "\n" * 5

OldUser2 = Struct.new(:id, :fullname, :r_role)

User2 = Struct.new(:id, :firstname, :lastname, :role)

reverse_source = ->(attrs)do
  OldUser2.new.tap do |old_user|
    attrs.each_pair do |key, value|
      old_user.public_send "#{key}=", value
    end
  end
end

source = ->(attrs)do
  User2.new.tap do |old_user|
    attrs.each_pair do |key, value|
      old_user.public_send "#{key}=", value
    end
  end
end

mapper = Yaoc::ObjectMapper.new(source, reverse_source).tap do |mapper|
  mapper.add_mapping do
    fetcher :public_send
    rule to: :role, from: :r_role

    rule to: :firstname,
         from: :fullname,
         converter: ->(source, result){ Yaoc::TransformationCommand.fill_result_with_value(result, :firstname,  source.fullname.split.first ) },
         reverse_converter: ->(source, result){ Yaoc::TransformationCommand.fill_result_with_value(result, :fullname, "#{source.firstname} #{source.lastname}") }

    rule to: :lastname,
         from: :fullname,
         converter: ->(source, result){ Yaoc::TransformationCommand.fill_result_with_value(result, :lastname,  source.fullname.split.last) },
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

puts "\n" * 5
