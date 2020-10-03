require_dependency 'application_helper'

module SectionApplicationHelperPatch

    def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
            unloadable

            alias_method :page_header_title_without_sections, :page_header_title
            alias_method :page_header_title, :page_header_title_with_sections

            alias_method :project_tree_options_for_select, :project_tree_options_for_select_with_section

            alias_method :link_to_project_without_sections, :link_to_project
            alias_method :link_to_project, :link_to_project_with_sections

            # Not before Redmine 3.4
            alias_method :render_projects_for_jump_box, :render_projects_for_jump_box_with_sections if method_defined?(:render_projects_for_jump_box)
        end
    end

    module InstanceMethods

        # Uses many things from #page_header_title
        def page_header_title_with_sections
            if @section && params[:controller] == 'sections'
                sections = []
                ancestors = @section.ancestors.to_a
                if ancestors.any?
                    sections << link_to_section(ancestors.shift, {}, :class => 'section root')
                    if ancestors.size > 2
                        sections << '&hellip;'
                        ancestors = ancestors[-2, 2]
                    end
                    sections += ancestors.collect{ |section| link_to_section(section, {}, :class => 'section ancestor') }
                end

                separator = content_tag(:span, ' &raquo; '.html_safe, :class => 'separator')
                breadcrumbs = sections.any? ? sections.join(separator).html_safe + separator : ''

                content_tag(:span, breadcrumbs.html_safe, :class => 'breadcrumbs') +
                content_tag(:span, h(@section), :class => 'current-section current-project') +
                content_tag(:span, ' &rsaquo; '.html_safe, :class => 'section-separator separator')
            elsif @project.nil? || @project.new_record?
                page_header_title_without_sections
            elsif @project.section
                section_ancestors = @project.section.self_and_ancestors.to_a
                project_ancestors = @project.root? ? [] : @project.ancestors.visible.all.to_a

                sections = []
                sections << link_to_section(section_ancestors.shift, {}, :class => 'section root')
                if section_ancestors.any?
                    if section_ancestors.size > 1 || project_ancestors.size > 1
                        sections << '&hellip;'
                        section_ancestors = section_ancestors[-1, 1] if section_ancestors.size > 1
                    end
                    sections += section_ancestors.collect{ |section| link_to_section(section, {}, :class => 'section ancestor') }
                end

                projects = []
                if project_ancestors.any?
                    projects << link_to_project(project_ancestors.shift, { :jump => current_menu_item }, :class => 'project root')
                    if project_ancestors.size > 1
                        projects << '&hellip;'
                        project_ancestors = project_ancestors[-1, 1]
                    end
                    projects += project_ancestors.collect{ |project| link_to_project(project, { :jump => current_menu_item }, :class => 'project ancestor') }
                end

                separator = content_tag(:span, ' &raquo; '.html_safe, :class => 'separator')
                if projects.any?
                    breadcrumbs = sections.join(separator).html_safe + content_tag(:span, ' &rsaquo; '.html_safe, :class => 'section-separator separator') +
                                  projects.join(separator).html_safe + separator
                else
                    breadcrumbs = sections.join(separator).html_safe + content_tag(:span, ' &rsaquo; '.html_safe, :class => 'section-separator separator')
                end

                content_tag(:span, breadcrumbs.html_safe, :class => 'breadcrumbs') +
                content_tag(:span, h(@project), :class => 'current-project')
            else
                page_header_title_without_sections
            end
        end

        # Largely a copy of #project_tree_options_for_select
        def project_tree_options_for_select_with_section(projects, options = {})
            select_options = ''
            if blank_text = options[:include_blank]
                if blank_text == true
                    blank_text = '&nbsp;'.html_safe
                end
                select_options << content_tag(:option, blank_text, :value => '')
            end
            project_tree_with_sections(projects) do |project, level, prefix|
                tag_options = { :value => project.id }
                if project == options[:selected] || (options[:selected].respond_to?(:include?) && options[:selected].include?(project))
                    tag_options[:selected] = 'selected'
                else
                    tag_options[:selected] = nil
                end

                if block_given?
                    custom_options = yield(project)
                    if custom_options.has_key?(:value) && custom_options[:value] =~ %r{projects/}
                        custom_options[:value] = sectioned_project_url(project, current_menu_item == :overview ? {} : { :jump => current_menu_item })
                    end
                    tag_options.merge!(custom_options)
                end

                if level == 0 && prefix.present?
                    name_prefix = prefix + ' &rsaquo; '
                else
                    name_prefix = level > 0 ? ('&nbsp;' * 2 * level + '&#187; ') : ''
                end

                select_options << content_tag(:option, name_prefix.html_safe + h(project), tag_options)
            end
            select_options.html_safe
        end

        def link_to_project_with_sections(project, options = {}, html_options = nil)
            if project.active? && project.section && options.is_a?(Hash) && (!options.has_key?(:action) || options[:action] == 'show')
                link_to(project.name, sectioned_project_url(project, { :only_path => true }.merge(options)), html_options)
            else
                link_to_project_without_sections(project, options, html_options)
            end
        end

        # Largely a copy of #render_projects_for_jump_box
        def render_projects_for_jump_box_with_sections(projects, selected = nil)
            jump = params[:jump].presence || current_menu_item
            drdn_items = ''.html_safe
            project_tree_with_sections(projects) do |project, level, prefix|
                padding = level * 16
                name_prefix = (level == 0 && prefix.present?) ? prefix + ' &rsaquo; ' : ''
                text = content_tag(:span, name_prefix.html_safe + project.name, :style => "padding-left: #{padding}px;")
                drdn_items << link_to(text, sectioned_project_url(project, :jump => jump), :title => project.name, :class => (project == selected ? 'selected' : nil))
            end
            drdn_items
        end

    end

end
