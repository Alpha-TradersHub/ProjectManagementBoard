# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::UsersController, type: :routing do
  describe "routing" do
    it "routes to #create" do
      expect(post: "api/users").to route_to({
        controller: "api/users",
        action: "create",
        format: :json
      })
    end

    it "routes to #tasks" do
      expect(get: "api/users/1/tasks").to route_to({
        controller: "api/users",
        action: "tasks",
        format: :json
      }, id: "1")
    end
  end
end
