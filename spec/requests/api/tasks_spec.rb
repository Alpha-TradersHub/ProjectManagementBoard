# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "/tasks", type: :request do
  let(:valid_attributes) {
    {
        "title": "login",
        "description": "Implement login",
        "due_date": "21/12/2024",
        "priority": "medium"
    }
  }

  let(:invalid_attributes) {
       {
            "title": nil,
            "description": "Implement login",
            "due_date": "21/12/2024",
            "priority": "medium"
        }
  }

  let(:valid_headers) {
    {}
  }

  let(:user) { FactoryBot.create(:user) }
  let(:task) { FactoryBot.create(:task) }
  let!(:overdue_task) { FactoryBot.create(:task, due_date: 1.day.ago) }
  let!(:in_progress_task) { FactoryBot.create(:task, status: :in_progress) }
  let!(:completed_task) { FactoryBot.create(:task, status: :completed, completed_date: 2.days.ago) }


  describe "GET /index" do
    it "renders a successful response" do
      Task.create! valid_attributes
      get api_tasks_url, headers: valid_headers, as: :json
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      task = Task.create! valid_attributes
      get api_task_url(task), as: :json
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Task" do
        expect {
          post api_tasks_url,
               params: { task: valid_attributes }, headers: valid_headers, as: :json
        }.to change(Task, :count).by(1)
      end

      it "renders a JSON response with the new task" do
        post api_tasks_url,
             params: { task: valid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end

    context "with invalid parameters" do
      it "does not create a new Task" do
        expect {
          post api_tasks_url,
               params: { task: invalid_attributes }, as: :json
        }.to change(Task, :count).by(0)
      end

      it "renders a JSON response with errors for the new task" do
        post api_tasks_url,
             params: { task: invalid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) {
        {
            "title": "updated",
            "description": "Implement login changed",
            "due_date": "10/04/2024",
            "status": "in_progress"
        }
      }

      it "updates the requested task" do
        task = Task.create! valid_attributes
        patch api_task_url(task),
              params: { task: new_attributes }, headers: valid_headers, as: :json
        task.reload

        expect(task.title).to eq(new_attributes[:title])
      end

      it "renders a JSON response with the task" do
        task = Task.create! valid_attributes
        patch api_task_url(task),
              params: { task: new_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end

    context "with invalid parameters" do
      it "renders a JSON response with errors for the task" do
        task = Task.create! valid_attributes
        patch api_task_url(task),
              params: { task: invalid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested task" do
      task = Task.create! valid_attributes
      expect {
        delete api_task_url(task), headers: valid_headers, as: :json
      }.to change(Task, :count).by(-1)
    end
  end

  describe 'POST /api/tasks/assign' do
    it 'assigns a task to a user' do
      post "/api/tasks/#{task.id}/assign", params: { user_id: user.id }

      expect(response).to have_http_status(:ok)
      expect(response).to render_template('api/tasks/update')
      expect(task.reload.user).to eq(user)
    end

    it 'returns not_found if user with provided user_id is not present' do
      post "/api/tasks/#{task.id}/assign", params: { user_id: nil }

      expect(response).to have_http_status(:not_found)
      expect(json_response['success']).to be_falsey
      expect(json_response['errors']).to be_present
    end
  end

  describe 'PUT /api/tasks/update_progress' do
    it 'updates the progress of a task' do
      put "/api/tasks/#{task.id}/progress", params: { id: task.id, progress: 50 }

      expect(response).to have_http_status(:ok)
      expect(response).to render_template('api/tasks/update')
      expect(task.reload.progress).to eq(50)
    end

    it 'returns unprocessable_entity if progress update fails' do
      put "/api/tasks/#{task.id}/progress", params: { id: task.id, progress: 'invalid' }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_response['success']).to be_falsey
      expect(json_response['errors']).to be_present
    end

    it 'returns unprocessable_entity if progress parameter is missing' do
      put "/api/tasks/#{task.id}/progress", params: { id: task.id }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_response['success']).to be_falsey
      expect(json_response['errors']).to include('Request missing progress percentage')
    end
  end

  describe 'GET /api/tasks/overdue' do
    it 'returns overdue tasks' do
      get '/api/tasks/overdue'

      expect(response).to have_http_status(:ok)
      expect(response).to render_template('api/tasks/index')
      expect(json_response.size).to eq(1)
      expect(json_response[0]['id']).to eq(overdue_task.id)
    end
  end

  describe 'GET /api/tasks/tasks_by_status' do
    it 'returns tasks with the specified status' do
      get '/api/tasks/status/in_progress'

      expect(response).to have_http_status(:ok)
      expect(response).to render_template('api/tasks/index')
      expect(json_response.size).to eq(2)
      expect(json_response.map{|x| x["id"]}
      ).to include(in_progress_task.id)
    end

    it 'returns unprocessable_entity if status param is missing' do
      get '/api/tasks/status/test'

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_response['success']).to be_falsey
      expect(json_response['errors']).to include('Invalid status params')
    end
  end

  describe 'GET /api/tasks/completed' do
    it 'returns completed tasks between start_date and end_date' do
      start_date = 3.days.ago.to_date
      end_date = Time.zone.tomorrow
      get '/api/tasks/completed', params: { start_date: start_date, end_date: end_date }

      expect(response).to have_http_status(:ok)
      expect(response).to render_template('api/tasks/index')
      expect(json_response.size).to eq(1)
      expect(json_response[0]['id']).to eq(completed_task.id)
    end

    it 'returns unprocessable_entity if start/end date is invalid' do
      get '/api/tasks/completed', params: { start_date: 'invalid', end_date: 'invalid' }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_response['success']).to be_falsey
      expect(json_response['errors']).to include('invalid start/end date')
    end
  end

  describe 'GET /api/tasks/statistics' do
    it 'returns statistics data' do
      get '/api/tasks/statistics'

      expect(response).to have_http_status(:ok)
      expect(json_response['success']).to be_truthy
      expect(json_response['data']).to be_present
      # Add more expectations based on the expected structure of your statistics data
    end
  end


    private

    def json_response
      JSON.parse(response.body)
    end
end
