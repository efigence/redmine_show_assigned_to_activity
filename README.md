# Redmine show assigned to activity

### With this plugin project activity list shows the changing users in issues.

## Requirements

Developed and tested on Redmine 3.1.0.

## Installation

1. Go to your Redmine installation's plugins/directory.
2. `git clone git@github.com:efigence/redmine_show_assigned_to_activity.git`
3. Restart Redmine.

## Usage

Just open your project activity page.

Few examples:
1. When you change only status, activity page will shows:
- Bug #1 (New): Cannot print recipes
2. When assigned_to will be changed then:
- Bug #1 Assignee set to: John Smith
3. If status and assigned_to will change at the same time, then:
- Bug #1 (Feedback) Assignee set to: John Smith
4. When you  set assignee to nobody and status will changed at the same time, then:
- Bug #1 (Closed) Assignee set to nobody
q