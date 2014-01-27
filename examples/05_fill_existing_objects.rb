require 'bundler/setup'
Bundler.require(:development)

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

puts old_user5
puts old_role
puts new_user5



puts "\n" * 5




