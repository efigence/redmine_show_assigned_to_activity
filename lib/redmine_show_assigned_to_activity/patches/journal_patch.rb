require_dependency 'journal'
module RedmineShowAssignedToActivity
  module Patches
    module JournalPatch

      def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable

          acts_as_event :title => :event_title,
                        :description => :notes,
                        :author => :user,
                        :group => :issue,
                        :type => Proc.new {|o| (s = o.new_status) ? (s.is_closed? ? 'issue-closed' : 'issue-edit') : 'issue-note' },
                        :url => Proc.new {|o| {:controller => 'issues', :action => 'show', :id => o.issue.id, :anchor => "change-#{o.id}"}}

          acts_as_activity_provider :type => 'issues',
                                    :author_key => :user_id,
                                    :scope => @conditions
        end
      end

      module InstanceMethods

        def event_title
          title = default_title if details.blank? || !details.map(&:prop_key).include?("assigned_to_id")
          title = title_for_status if !new_status.blank? && new_assigned.blank?
          title = title_for_assigned if new_status.blank? && !new_assigned.blank? && (new_assigned != "nobody")
          title = title_for_assigned_and_status if !new_status.blank? && !new_assigned.blank?
          title = title_for_empty_assigned if title.blank?
          event_conditions
          title
        end

        def event_conditions
          conditions = conditions_for_status if !new_status.blank? && new_assigned.blank?
          conditions = conditions_for_assigned if new_status.blank? && !new_assigned.blank?
          conditions = conditions_for_assigned_and_status if !new_status.blank? && !new_assigned.blank?
          @conditions = conditions
        end

        def new_assigned
          old = old_value_for(self.details)
          a = new_value_for('assigned_to_id')
          a = a ? User.find(a) : nil
          old || a
        end

        def old_value_for(details)
          if details.map(&:prop_key).include?("assigned_to_id")
            "nobody" if details.find_by(prop_key: "assigned_to_id").try(:value).blank?
          end
        end

        def default_title
          "#{issue.tracker} ##{issue.id} #{issue.status.try(:name)}: #{issue.subject}"
        end

        def title_for_status
          "#{issue.tracker} ##{issue.id} (#{new_status}): #{issue.subject}"
        end

        def title_for_assigned
          "#{issue.tracker} ##{issue.id} #{l(:text_assigned_to)}#{new_assigned}"
        end

        def title_for_assigned_and_status
          if new_assigned == "nobody"
            "#{issue.tracker} ##{issue.id} (#{new_status}) #{l(:text_assigned_to_nobody)}"
          else
            "#{issue.tracker} ##{issue.id} (#{new_status}) #{l(:text_assigned_to)}#{new_assigned}"
          end
        end

        def title_for_empty_assigned
          "#{issue.tracker} ##{issue.id} #{l(:text_assigned_to_nobody)}"
        end

        def conditions_for_status
          Journal.preload({:issue => :project}, :user).
            joins("LEFT OUTER JOIN #{JournalDetail.table_name} ON #{JournalDetail.table_name}.journal_id = #{Journal.table_name}.id").
            where("#{Journal.table_name}.journalized_type = 'Issue' AND" +
                  " (#{JournalDetail.table_name}.prop_key = 'status_id' OR #{Journal.table_name}.notes <> '')").uniq
        end

        def conditions_for_assigned
          Journal.preload({:issue => :project}, :user).
            joins("LEFT OUTER JOIN #{JournalDetail.table_name} ON #{JournalDetail.table_name}.journal_id = #{Journal.table_name}.id").
            where("#{Journal.table_name}.journalized_type = 'Issue' AND" +
                  " (#{JournalDetail.table_name}.prop_key = 'assigned_to_id')").uniq
        end

        def conditions_for_assigned_and_status
          Journal.preload({:issue => :project}, :user).
            joins("LEFT OUTER JOIN #{JournalDetail.table_name} ON #{JournalDetail.table_name}.journal_id = #{Journal.table_name}.id").
            where("#{Journal.table_name}.journalized_type = 'Issue' AND" +
                  " (#{JournalDetail.table_name}.prop_key = 'status_id' OR #{Journal.table_name}.notes <> '')" + 
                  " (#{JournalDetail.table_name}.prop_key = 'assigned_to_id')").uniq
        end
      end
    end
  end
end
