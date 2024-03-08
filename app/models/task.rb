# frozen_string_literal: true

class Task < ApplicationRecord
  belongs_to :user, optional: true

  enum status: { todo:0, in_progress:1, testing:2, completed:3}
  enum priority: { low:0, medium:1, high:2 }

  validates_presence_of :title, :due_date
  validates :progress, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }

  default_scope { order(priority: :desc, due_date: :asc) }
  scope :overdue, -> { where(due_date: ...Time.zone.today) }
  scope :with_status, ->(status) { where(status: status)}
  scope :completed_between, ->(start_date,end_date) { where(status: :completed, completed_date: start_date...end_date) }

  before_save :check_completion

  def check_completion
    if status_changed? && self.completed?
      self.completed_date = Time.zone.today
    end
  end

  def get_priority
    return :low unless due_date.present?

    remaining_days = due_date - Time.zone.today
    if remaining_days < 7
      :high
    elsif remaining_days < 14
      :medium
    else
      :low
    end
  end

  def self.statistics
    total_tasks = Task.all.count
    completed_count = Task.with_status(:completed).count
    {
      number_of_tasks: total_tasks,
      number_of_completed_tasks: completed_count,
      percentage_of_completed_tasks: ((completed_count.to_d/total_tasks)*100).round(2)

    }
  end
end
