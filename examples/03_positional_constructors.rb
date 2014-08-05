require 'bundler/setup'
Bundler.require(:development)

require 'yaoc'

include Yaoc::Helper

puts "\n" * 5

OldUser3 = Struct.new(:id, :fullname, :r_role)
User3 = Struct.new(:id, :firstname, :lastname, :role)

converter = Yaoc::TransformationCommand.create(to: 1,
                                               from: :fullname,
                                               deferred: false,
                                               fetcher_proc: ->(source, fetcher, from) {source.fullname.split.first })

reverse_converter = Yaoc::TransformationCommand.create(to: 1,
                                                       from: :first_and_lastname,
                                                       deferred: false,
                                                       fetcher_proc: ->(source, fetcher, from) { "#{source.firstname} #{source.lastname}" })

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

         converter: ->(source, result) { result[2]  = source.fullname.split.last },
         reverse_converter: ->(source, result) { result }

    rule to: 3, from: :r_role,
         reverse_to: 2, reverse_from: :role

  end
end

old_user3 = OldUser3.new(1, 'myfirst mysecond',  'admin')
new_user3 = mapper.load(old_user3)

puts old_user3
puts new_user3

new_user3.firstname = 'no'
new_user3.lastname = 'name'

puts mapper.dump(new_user3)

puts "\n" * 5
