require_dependency 'project'

module SectionProjectPatch

    def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
            unloadable

            belongs_to :section, :class_name => 'ProjectSection', :foreign_key => 'section_id'

            validate :validate_section_change

            after_save :update_or_restore_section
            after_move :update_descendants

            if Rails::VERSION::MAJOR < 3
                named_scope :unsectioned, { :conditions => { :section_id => nil } }
            elsif Rails::VERSION::MAJOR < 4
                scope :unsectioned, { :conditions => { :section_id => nil } }
            else
                scope :unsectioned, lambda { where(:section_id => nil) }
            end

            safe_attributes 'section_id' unless Redmine::VERSION::MAJOR == 1 && Redmine::VERSION::MINOR == 0

            alias_method_chain :all_issue_custom_fields, :sections
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
            all_custom_fields = all_issue_custom_fields_without_sections
            unsectioned_custom_fields = all_custom_fields.select{ |custom_field| custom_field.sections.empty? }
            if section
                unsectioned_custom_fields + (all_custom_fields & section.issue_custom_fields)
            else
                unsectioned_custom_fields
            end
        end

    private

        def validate_section_change
            if changed.include?('section_id') && (child? || !User.current.allowed_to?(:select_project_section, self, :global => true))
                errors.add(:section_id, :invalid)
            end
        end

        def update_or_restore_section
            if changed.include?('section_id')
                if root?
                    Project.update_all({ :section_id => self.section_id },
                                       [ 'lft > ? AND rgt < ?', self.lft, self.rgt ])
                end
            end
        end

        def update_descendants
            if child?
                update_attribute(:section_id, parent.section_id)
            end
            Project.update_all({ :section_id => self.section_id },
                               [ 'lft > ? AND rgt < ?', self.lft, self.rgt ])
        end

    end

end
