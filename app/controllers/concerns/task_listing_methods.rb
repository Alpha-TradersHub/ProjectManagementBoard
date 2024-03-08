module TaskListingMethods
  extend ActiveSupport::Concern

  def overdue
    @tasks = Task.overdue
    render template: 'api/tasks/index'
  end

  def tasks_by_status
    unless params[:status].present? &&  Task.statuses.keys.include?(params[:status])
      render json: { success: false, errors: ['Invalid status params'] },
             status: :unprocessable_entity and return
    end

    @tasks = Task.with_status(params[:status])
    render template: 'api/tasks/index'
  end

  def completed
    unless params[:start_date].present? && params[:start_date].present? && valid_date?(params[:start_date]) && valid_date?(params[:end_date]) && (params[:end_date].to_date > params[:start_date].to_date)
      render json: { success: false, errors: ['invalid start/end date'] }, status: :unprocessable_entity and return
    end

    @tasks = Task.completed_between(params[:start_date], params[:end_date])
    render template: 'api/tasks/index'
  end

  def statistics
    render json: { success: true, data: Task.statistics }, status: :ok
  end

  private

  def valid_date?(date_string)
    Date.parse(date_string)
    true
  rescue ArgumentError
    false
  end
end