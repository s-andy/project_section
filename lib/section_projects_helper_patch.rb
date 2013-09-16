require_dependency 'projects_helper'

module SectionProjectsHelperPatch

    def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
            unloadable

            alias_method_chain :render_project_hierarchy, :sections
        end
    end

    module InstanceMethods

        def render_project_hierarchy_with_sections(projects)
            hierarchy = ''
            @sections = ProjectSection.all(:order => 'lft')
            if @sections.any?
                hierarchy << '<div class="box" style="text-align: right;">'
                hierarchy << '<select onchange="if (this.value != \'\') { window.location = this.value; }">'
                hierarchy << '<option value="' + url_for(:controller => 'projects', :action => 'index') + '">' + l(:label_all_sections) + '</option>'
                hierarchy << '<option value="" disabled="disabled">---</option>'
                hierarchy << project_section_tree_options_for_select(@sections, :selected => @section, :skip_empty => true) do |section|
                    { :value => section_url(section) }
                end
                hierarchy << '</select>'
                hierarchy << '</div>'
            end
            hierarchy << render_project_hierarchy_without_sections((@section ?
                                                                    @section.projects.visible.sort_by(&:lft) :
                                                                    Project.visible.unsectioned.sort_by(&:lft)) & projects)
            @sections = @section.descendants if @section
            if @sections.any?
                section_ancestors = []
                @sections.each do |section|
                    while section_ancestors.any? && !section.is_descendant_of?(section_ancestors.last)
                        section_ancestors.pop
                    end
                    heading_level = 3 + (section_ancestors.size <= 3 ? section_ancestors.size : 3)
                    heading = content_tag('h' + heading_level.to_s, section_link_full(section, {}, :class => 'sections'), :class => 'section')
                    body = render_project_hierarchy_without_sections(section.projects.visible.sort_by(&:lft) & projects)
                    hierarchy << heading + body unless body.empty?
                    section_ancestors << section
                end
            end
            hierarchy.html_safe
        end

    end

end
