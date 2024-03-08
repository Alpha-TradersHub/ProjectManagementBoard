# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::TasksController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "api/tasks").to route_to({
        controller: "api/tasks",
        action: "index",
        format: :json
      })
    end

    it "routes to #show" do
      expect(get: "api/tasks/1").to route_to({
        controller: "api/tasks",
        action: "show",
        format: :json
      }, id: "1")
    end


    it "routes to #tasks_by_status" do
      expect(get: "api/tasks/status/todo").to route_to({
        controller: "api/tasks",
        action: "tasks_by_status",
        format: :json
      }, status: "todo")
    end


    it "routes to #create" do
      expect(post: "api/tasks").to route_to({
        controller: "api/tasks",
        action: "create",
        format: :json
      })
    end

    it "routes to #assign" do
      expect(post: "api/tasks/1/assign").to route_to({
        controller: "api/tasks",
        action: "assign",
        format: :json
      }, id: "1")
    end

    it "routes to #update via PUT" do
      expect(put: "api/tasks/1").to route_to({
        controller: "api/tasks",
        action: "update",
        format: :json
      }, id: "1")
    end

    it "routes to #progress via PUT" do
      expect(put: "api/tasks/1/progress").to route_to({
        controller: "api/tasks",
        action: "update_progress",
        format: :json
      }, id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "api/tasks/1").to route_to({
        controller: "api/tasks",
        action: "update",
        format: :json
      }, id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "api/tasks/1").to route_to({
        controller: "api/tasks",
        action: "destroy",
        format: :json
      }, id: "1")
    end

    it "routes to #overdue" do
      expect(get: "/api/tasks/overdue").to route_to({
        controller: "api/tasks",
        action: "overdue",
        format: :json
      })
    end

    it "routes to #completed" do
      expect(get: "/api/tasks/completed").to route_to({
        controller: "api/tasks",
        action: "completed",
        format: :json
      })
    end

    it "routes to #statistics" do
      expect(get: "/api/tasks/statistics").to route_to({
        controller: "api/tasks",
        action: "statistics",
        format: :json
      })
    end
  end
end
