# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it 'should have many tasks' do
      expect(User.reflect_on_association(:tasks).macro).to eq(:has_many)
    end
  end

  describe 'validations' do
    it 'should be invalid without name' do
       user = FactoryBot.build(:user,name:nil)
       expect(user).to_not be_valid
    end

    it 'should be valid without name' do
      user = FactoryBot.build(:user,name: 'John')
      expect(user).to be_valid
   end
  end
end
