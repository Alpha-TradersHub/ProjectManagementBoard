# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Api::Users", type: :request do
  let(:valid_attributes) {
    { name: "test_user" }
  }

  let(:invalid_attributes) {
    {
      name: nil,
    }
  }

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new User" do
        expect {
          post api_users_url,
               params: { user: valid_attributes }, as: :json
        }.to change(User, :count).by(1)
      end

      it "renders a JSON response with the new user" do
        post api_users_url,
             params: { user: valid_attributes }, as: :json
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end

    context "with invalid parameters" do
      it "does not create a new User" do
        expect {
          post api_users_url, params: { user: invalid_attributes }, as: :json
        }.to change(User, :count).by(0)
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "renders a JSON response with errors for the new user" do
        post api_users_url,
             params: { user: invalid_attributes }, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end
  end

  describe "GET /api/users" do
    let(:expected_response) {
      { "user" => { "id" => 1, "name" => "test_user" }}
    }
    it "returns http success" do
      post "/api/users", params: { user: valid_attributes }
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)).to eq(expected_response)
    end
  end
end
