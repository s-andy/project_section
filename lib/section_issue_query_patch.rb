require_dependency 'issue_query'

module SectionIssueQueryPatch

    def self.included(base)
        base.send(:include, ProjectSectionHelper)
        base.send(:include, InstanceMethods)
        base.class_eval do
            unloadable

            alias_method :initialize_available_filters_without_sections, :initialize_available_filters
            alias_method :initialize_available_filters, :initialize_available_filters_with_sections
        end
    end

    module InstanceMethods

        def initialize_available_filters_with_sections
            initialize_available_filters_without_sections

            if project.nil?
                section_values = all_sections_values
                add_available_filter('project.section_id',
                    :type => :list,
                    :name => l(:label_attribute_of_project, :name => l(:label_project_section)),
                    :values => section_values
                ) unless section_values.empty?
            end
        end

        def all_sections_values
            @all_sections_values ||= begin
                values = []
                sections = ProjectSection.all.select{ |section| section.projects.any? }
                project_section_tree(sections) do |section, level|
                    prefix = (level > 0 ? ('--' * level + ' ') : '')
                    values << ["#{prefix}#{section.name}", section.id.to_s]
                end
                values
            end
        end

        def sql_for_project_section_id_field(field, operator, value)
            sql_operator = (operator == '=') ? 'IN' : 'NOT IN'
            "#{Issue.table_name}.project_id #{sql_operator} (SELECT #{Project.table_name}.id FROM #{Project.table_name} WHERE #{Project.table_name}.section_id = #{value.first.to_i})"
        end

    end

end
