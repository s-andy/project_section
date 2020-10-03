require_dependency 'project'

module SectionProjectPatch

    def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
            unloadable

            belongs_to :section, :class_name => 'ProjectSection', :foreign_key => 'section_id'

            validate :validate_section_change

            after_save :update_or_restore_section

            unless method_defined?(:after_move)
                after_save :update_descendants, :if => Proc.new { |project|
                    Rails::VERSION::MAJOR < 5 || (Rails::VERSION::MAJOR == 5 && Rails::VERSION::MINOR < 1) ? project.parent_id_changed? : project.saved_change_to_parent_id?
                }
            else # Redmine 2.5.xd
                after_move :update_descendants
            end

            scope :unsectioned, lambda { where(:section_id => nil) }

            safe_attributes 'section_id'

            alias_method :all_issue_custom_fields_without_sections, :all_issue_custom_fields
            alias_method :all_issue_custom_fields, :all_issue_custom_fields_with_sections
        end
    end

    module InstanceMethods

        def available_custom_fields
            all_custom_fields = super
            unsectioned_custom_fields = all_custom_fields.select{ |custom_field| custom_field.sections.empty? }
            if section
                unsectioned_custom_fields + (all_custom_fields & section.project_custom_fields)
            else
                unsectioned_custom_fields
            end
        end

        def all_issue_custom_fields_with_sections
            if section && !new_record?
                # Rewrite of the original #all_issue_custom_fields
                @all_issue_custom_fields ||= IssueCustomField.sorted.
                    where("is_for_all = ? OR id IN (" +
                              "SELECT DISTINCT cfp.custom_field_id " +
                              "FROM #{table_name_prefix}custom_fields_projects#{table_name_suffix} cfp " +
                              "WHERE cfp.project_id = ?" +
                          ") OR id IN (" +
                              "SELECT DISTINCT cfs.custom_field_id " +
                              "FROM #{table_name_prefix}custom_fields_sections#{table_name_suffix} cfs " +
                              "WHERE cfs.section_id = ?" +
                          ")", true, id, section.id)
            else
                all_issue_custom_fields_without_sections
            end
        end

    private

        def validate_section_change
            if section_id_changed? && (child? || !User.current.allowed_to?(:select_project_section, self, :global => true))
                errors.add(:section_id, :invalid)
            end
        end

        def update_or_restore_section
            if Rails::VERSION::MAJOR < 5 || (Rails::VERSION::MAJOR == 5 && Rails::VERSION::MINOR < 1) ? section_id_changed? : saved_change_to_section_id?
                if root?
                    Project.where([ 'lft > ? AND rgt < ?', self.lft, self.rgt ])
                           .update_all({ :section_id => self.section_id })
                end
            end
        end

        def update_descendants
            if child?
                Project.where(:id => self.id)
                       .update_all({ :section_id => parent.section_id })
            end
            Project.where([ 'lft > ? AND rgt < ?', self.lft, self.rgt ])
                   .update_all({ :section_id => self.section_id })
        end

    end

end
