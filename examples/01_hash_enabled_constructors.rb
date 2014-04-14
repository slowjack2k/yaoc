require 'bundler/setup'
Bundler.require(:development)

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
         converter: ->(source, result) { Yaoc::TransformationCommand.fill_result_with_value(result, :firstname, source.fullname.split.first) },
         reverse_converter: ->(source, result) { Yaoc::TransformationCommand.fill_result_with_value(result, :fullname,  "#{source.firstname} #{source.lastname}") }

    rule to: :lastname,
         from: :fullname,
         converter: ->(source, result) { Yaoc::TransformationCommand.fill_result_with_value(result, :lastname, source.fullname.split.last ) },
         reverse_converter: ->(source, result) { result }

    rule to: :id
  end
end

old_user = OldUser.new(id: 1, fullname: "myfirst mysecond", r_role: "admin" )
new_user = mapper.load(old_user)

puts "\n" * 5

puts old_user
puts new_user

new_user.firstname = "no"
new_user.lastname = "name"

puts mapper.dump(new_user)

puts "\n" * 5
