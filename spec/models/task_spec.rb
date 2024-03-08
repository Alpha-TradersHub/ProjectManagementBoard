# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Task, type: :model do
  describe 'associations' do
    it 'should belong to user' do
      expect(Task.reflect_on_association(:user).macro).to eq(:belongs_to)
    end
  end

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:due_date) }
  end

  describe 'enums' do
    it { should define_enum_for(:status).with_values(todo: 0, in_progress: 1, testing: 2, completed: 3) }
    it { should define_enum_for(:priority).with_values(low: 0, medium: 1, high: 2) }
  end

  describe 'default scope' do
    it 'orders tasks by priority in descending order and due_date in ascending order' do
      high_priority_task = FactoryBot.create(:task, priority: :high, due_date: Time.zone.tomorrow)
      low_priority_task = FactoryBot.create(:task, priority: :low, due_date: Time.zone.yesterday)

      expect(Task.all).to eq([high_priority_task, low_priority_task])
    end
  end

  describe 'before_save callback' do
    it 'calls check_completion before saving' do
      task = FactoryBot.build(:task)
      expect(task).to receive(:check_completion)
      task.save
    end
  end

  describe 'scopes' do
    describe '.overdue' do
      it 'returns tasks with overdue due_date' do
        overdue_task = FactoryBot.create(:task, due_date: Time.zone.yesterday)
        non_overdue_task = FactoryBot.create(:task, due_date: Time.zone.tomorrow)

        expect(Task.overdue).to include(overdue_task)
        expect(Task.overdue).not_to include(non_overdue_task)
      end
    end

    describe '.with_status' do
      it 'returns tasks with the specified status' do
        in_progress_task = FactoryBot.create(:task, status: :in_progress)
        testing_task = FactoryBot.create(:task, status: :testing)

        expect(Task.with_status(:in_progress)).to include(in_progress_task)
        expect(Task.with_status(:in_progress)).not_to include(testing_task)
      end
    end

    describe '.completed_between' do
      it 'returns tasks completed between the specified dates' do
        completed_task_within_range = FactoryBot.create(:task, status: :completed)

        expect(Task.completed_between(1.week.ago, Time.zone.tomorrow)).to include(completed_task_within_range)
        expect(Task.completed_between(1.week.ago, 1.day.ago)).not_to include(completed_task_within_range)
      end
    end
  end

end
