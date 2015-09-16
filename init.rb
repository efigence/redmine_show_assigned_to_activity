Redmine::Plugin.register :redmine_show_assigned_to_activity do
  name 'Redmine Show Assigned To Activity plugin'
  author 'Marcin Świątkiewicz'
  description 'With this plugin project activity list shows the changing users in issues.'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'
end
ActionDispatch::Callbacks.to_prepare do
  Journal.send(:include, RedmineShowAssignedToActivity::Patches::JournalPatch)
end
