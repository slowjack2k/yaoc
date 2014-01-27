require "spec_helper"

feature "Map objects reusing other existing converters", %q{
   In order to map objects with other converters
   as a lib user
   I want to map object from an input object to an output object and reverse with a given converter
} do


  given(:new_role_class){
    Yaoc::Helper::StructHE(:id, :name)
  }

  given(:old_role_class){
    Yaoc::Helper::StructHE(:o_id, :o_name)
  }

  given(:role_converter){
    Yaoc::ObjectMapper.new(new_role_class, old_role_class).tap do |mapper|
      mapper.add_mapping do
        fetcher :public_send

        rule to:   [:id, :name],
             from: [:o_id, :o_name]

      end
    end
  }

  given(:new_user_class){
    Yaoc::Helper::StructHE(:id, :firstname, :lastname, :roles)
  }

  given(:old_user_class){
    Yaoc::Helper::StructHE(:o_id, :o_firstname, :o_lastname, :o_roles)
  }

  given(:user_converter){
    other_converter = role_converter
    is_col = is_collection

    Yaoc::ObjectMapper.new(new_user_class, old_user_class).tap do |mapper|
      mapper.add_mapping do
        fetcher :public_send

        rule to:   [:id, :firstname, :lastname],
             from: [:o_id, :o_firstname, :o_lastname]

        rule to: :roles,
             from: :o_roles,
             object_converter: other_converter,
             is_collection: is_col
      end
    end
  }


  context "composition is a collection" do
    given(:is_collection){
      true
    }

    given(:old_user) {
      old_user_class.new(
          o_id: "user_1",
          o_firstname: "o firstname",
          o_lastname: "o lastname",
          o_roles: [
              old_role_class.new(o_id: "role_1", o_name: "admin"),
              old_role_class.new(o_id: "role_2", o_name: "ruth"),
              old_role_class.new(o_id: "role_3", o_name: "guest"),
          ]
      )
    }

    given(:expected_new_user) {
      new_user_class.new(
          id: "user_1",
          firstname: "o firstname",
          lastname: "o lastname",
          roles: [
              new_role_class.new(id: "role_1", name: "admin"),
              new_role_class.new(id: "role_2", name: "ruth"),
              new_role_class.new(id: "role_3", name: "guest"),
          ]
      )
    }

    scenario "creates a new user from the old one" do
      expect(user_converter.load(old_user)).to eq expected_new_user
    end

    scenario "dumps an result object as result object" do
      expect(user_converter.dump(expected_new_user)).to eq old_user
    end

  end

  context "composition is a single value" do
    given(:is_collection){
      false
    }

    given(:old_user) {
      old_user_class.new(
          o_id: "user_1",
          o_firstname: "o firstname",
          o_lastname: "o lastname",
          o_roles: old_role_class.new(o_id: "role_1", o_name: "admin, ruth, guest")

      )
    }

    given(:expected_new_user) {
      new_user_class.new(
          id: "user_1",
          firstname: "o firstname",
          lastname: "o lastname",
          roles: new_role_class.new(id: "role_1", name: "admin, ruth, guest")
      )
    }

    scenario "creates a new user from the old one" do
      expect(user_converter.load(old_user)).to eq expected_new_user
    end

    scenario "dumps an result object as result object" do
      expect(user_converter.dump(expected_new_user)).to eq old_user
    end

  end

end