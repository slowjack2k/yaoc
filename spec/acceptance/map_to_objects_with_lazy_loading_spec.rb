require "spec_helper"

feature "Map objects to classes with lazy loading", %q{
   In order to defer object mapping
   as a lib user
   I want to map object from an input object to an output object with lazy loading support
} do

  given(:mapper)do
    Yaoc::ObjectMapper.new(new_user_class, old_user_class).tap do |mapper|
      mapper.add_mapping do
        fetcher :public_send
        rule to: [:id, :names],
             lazy_loading: [false, true]
      end
    end
  end

  given(:new_user_class)do
    Yaoc::Helper::StructHE(:id, :names)
  end

  given(:old_user_class)do
    Yaoc::Helper::StructHE(:id, :names)
  end

  given(:existing_old_user)do
    old_user_class.new(
        id: 'existing_user_2',
        names: ['first_name', 'second_name']
    )
  end

  given(:existing_user)do
    new_user_class.new(
        id: 'existing_user_2',
        names: ['first_name', 'second_name']
    )
  end

  scenario "creates an result object from an input_object deferred" do
    converted_user = mapper.load(existing_old_user)
    new_names = ["new_name1", "new_name2"]

    existing_old_user.names = new_names # show defer through changes after loading an object

    expect(converted_user.names).to eq new_names
  end

  scenario "dumps an result object as source object defered" do
    converted_user = mapper.dump(existing_user)
    new_names = ["new_name1", "new_name2"]

    existing_user.names = new_names # show defer through changes after loading an object

    expect(converted_user.names).to eq new_names
  end

end
