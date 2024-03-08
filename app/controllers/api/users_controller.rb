# frozen_string_literal: true

module Api
  class UsersController < ApplicationController
    before_action :set_user, only: [:tasks]

    def create
      @user = User.new(user_params)
      return if @user.save

      render json: { success: false, errors: @user.errors }, status: :unprocessable_entity
    end

    def tasks
      @tasks = @user.tasks
      render template: 'api/tasks/index'
    end

    private

    def set_user
      @user = User.find_by(id: params[:id])

      return if @user.present?

      render json: { success: false, errors: ['User not found'] }, status: :not_found
    end

    def user_params
      params.require(:user).permit(:name)
    end
  end
end
