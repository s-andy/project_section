module SectionCustomFieldPatch

    def self.included(base)
        base.class_eval do
            unloadable
            has_and_belongs_to_many :sections,
                                    :class_name => 'ProjectSection',
                                    :join_table => "#{table_name_prefix}custom_fields_sections#{table_name_suffix}",
                                    :association_foreign_key => 'section_id',
                                    :foreign_key => 'custom_field_id'
        end
    end

end
