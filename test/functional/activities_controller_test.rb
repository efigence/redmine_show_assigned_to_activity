require File.expand_path('../../test_helper', __FILE__)

class ActivitiesControllerTest < ActionController::TestCase
  self.fixture_path = File.join(File.dirname(__FILE__), '../fixtures')
  fixtures :projects, :trackers, :issue_statuses, :issues,
           :users, :roles, :member_roles, :members,
           :enabled_modules, :journals, :journal_details

  def test_edit_issue_with_new_assigned
    get :index, :project_id => 1, :with_subprojects => 0
    assert_not_nil assigns(:events_by_day)
    assert_select "a[href='/issues/1#change-1']", :text => "Bug #1 (Feedback) Assignee set to: John Smith"
    assert_select "a[href='/issues/1#change-2']", :text => "Bug #1 Assignee set to nobody"
    assert_select "a[href='/issues/1#change-3']", :text => "Bug #1 Assignee set to: John Smith"
    assert_select "a[href='/issues/1#change-4']". :text => "Bug #1 (Closed) Assignee set to nobody"
    assert_select "a[href='/issues/1']",          :text => "Bug #1 (New): Cannot print recipes"
  end
end