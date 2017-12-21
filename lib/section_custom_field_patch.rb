module SectionCustomFieldPatch

    def self.included(base)
        base.class_eval do
            unloadable

            has_and_belongs_to_many :sections,
                                    :class_name => 'ProjectSection',
                                    :join_table => "#{table_name_prefix}custom_fields_sections#{table_name_suffix}",
                                    :association_foreign_key => 'section_id',
                                    :foreign_key => 'custom_field_id'

            safe_attributes 'section_ids' if respond_to?(:safe_attributes) # Redmine 3.4
        end
    end

end
