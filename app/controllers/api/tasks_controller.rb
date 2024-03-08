# frozen_string_literal: true

module Api
  class TasksController < ApplicationController
    include TaskListingMethods
    before_action :set_task, only: %i[show update destroy assign update_progress]
    before_action :set_user, only: %i[assign]

    # GET /tasks
    def index
      @tasks = Task.all
    end

    # POST /tasks
    def create
      @task = Task.new(task_creation_params)

      render 'create', status: :created and return if @task.save

      render json: { success: false, errors: @task.errors }, status: :unprocessable_entity
    end

    # PATCH/PUT /tasks/1
    def update
      return if @task.update(task_update_params)

      render json: { success: false, errors: @task.errors }, status: :unprocessable_entity
    end

    # DELETE /tasks/1
    def destroy
      if @task.destroy
        render json: { success: true, message: "Task with Id #{@task.id} deleted succesfully" }, status: :ok
      else
        render json: { success: false, errors: @task.errors }, status: :unprocessable_entity
      end
    end

    def assign
      if @task.update(user_id: @user.id)
        @task.reload
        render template: 'api/tasks/update'
      else
        render json: { success: false, errors: @task.errors }, status: :unprocessable_entity
      end
    end

    def update_progress
      unless params[:progress].present?
        render json: { success: false, errors: ['Request missing progress percentage'] },
               status: :unprocessable_entity and return
      end

      if @task.update(progress: params[:progress])
        @task.reload
        render template: 'api/tasks/update'
      else
        render json: { success: false, errors: @task.errors }, status: :unprocessable_entity
      end
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_task
      @task = Task.find_by(id: params[:id])
      return if @task.present?

      render json: { success: false, errors: ['Task not found'] }, status: :not_found
    end

    def set_user
      @user = User.find_by(id: params[:user_id])
      return if @user.present?

      render json: { success: false, errors: ['User not found'] }, status: :not_found
    end

    def task_creation_params
      params.require(:task).permit(:title, :description, :due_date, :priority)
    end

    def task_update_params
      params.require(:task).permit(:title, :description, :due_date, :status, :priority)
    end
  end
end
