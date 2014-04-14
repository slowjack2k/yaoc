require 'bundler/setup'
Bundler.require(:development)

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




