require 'spec_helper'

feature 'Fill existing objects', %q{
   In order to use this lib with pre created objects
   as a lib user
   I want to be able to fill exiting objects instead of create a new one
} do

  given(:new_user_class)do
    Yaoc::Helper::StructHE(:id, :firstname, :lastname, :roles)
  end

  given(:old_user_class)do
    Yaoc::Helper::StructHE(:o_id, :o_firstname, :o_lastname)
  end

  given(:user_converter)do

    Yaoc::ObjectMapper.new(new_user_class, old_user_class).tap do |mapper|
      mapper.add_mapping do
        fetcher :public_send

        rule to:   [:id, :firstname, :lastname],
             from: [:o_id, :o_firstname, :o_lastname]

      end
    end
  end

  given(:expected_new_user) do
    new_user_class.new(
        id: 'user_1',
        firstname: 'o firstname',
        lastname: 'o lastname',
        roles: 'admin, ruth, guest'
    )
  end

  given(:existing_user)do
    new_user_class.new(
        id: nil,
        firstname: nil,
        lastname: nil,
        roles: 'admin, ruth, guest'
    )
  end

  given(:existing_old_user)do
    old_user_class.new(
        o_id: 'existing_user_2',
        o_firstname: 'o existing_firstname',
        o_lastname: 'o existing_lastname'
    )
  end

  given(:old_user) do
    old_user_class.new(
        o_id: 'user_1',
        o_firstname: 'o firstname',
        o_lastname: 'o lastname'

    )
  end

  scenario 'creates an result object from an input_object' do
    conversion_result = user_converter.load(old_user, existing_user)

    expect(conversion_result.object_id).to eq existing_user.object_id
    expect(conversion_result).to eq expected_new_user
  end

  scenario 'dumps an result object as result object' do
    conversion_result = user_converter.dump(expected_new_user, existing_old_user)

    expect(conversion_result.object_id).to eq existing_old_user.object_id
    expect(conversion_result).to eq old_user
  end

end
