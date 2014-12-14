require_dependency 'version'

module SectionVersionPatch

    def self.included(base)
        base.send(:include, InstanceMethods)
    end

    module InstanceMethods

        def available_custom_fields
            all_custom_fields = super
            unsectioned_custom_fields = all_custom_fields.select{ |custom_field| custom_field.sections.empty? }
            if project.section
                unsectioned_custom_fields + (all_custom_fields & project.section.version_custom_fields)
            else
                unsectioned_custom_fields
            end
        end

    end

end
