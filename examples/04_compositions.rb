require 'bundler/setup'
Bundler.require(:development)

require 'yaoc'

include Yaoc::Helper

puts "\n" * 5

User4 = StructHE(:id, :firstname, :lastname, :roles)

OldUser4 = StructHE(:o_id, :o_firstname, :o_lastname, :o_roles)

Role = StructHE(:id, :name)

OldRole = StructHE(:o_id, :o_name)

Yaoc::ObjectMapper.new(Role, OldRole).tap do |mapper|
  mapper.add_mapping do
    register_as :role_mapper
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
         object_converter: :role_mapper,
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

puts "\n" * 5
