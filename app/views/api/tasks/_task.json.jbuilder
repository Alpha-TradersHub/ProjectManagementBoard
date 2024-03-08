json.id task.id
json.title task.title
json.description task.description
json.priority task.priority
json.due_date task.due_date
json.completed_date task.completed_date
json.status task.status
json.progress_percentage task.progress
if task.user.present?
  json.partial! "api/users/user", user: task.user
else
  json.assignee "unassigned"
end
