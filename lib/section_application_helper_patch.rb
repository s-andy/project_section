require_dependency 'application_helper'

module SectionApplicationHelperPatch

    def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
            unloadable

            alias_method :project_tree_options_for_select, :project_tree_with_sections_options_for_select

            alias_method_chain :page_header_title, :sections
            alias_method_chain :link_to_project,   :sections
        end
    end

    module InstanceMethods

        # Uses many things from #page_header_title
        def page_header_title_with_sections
            if @section && params[:controller] == 'sections'
                sections = []
                ancestors = @section.ancestors
                if ancestors.any?
                    sections << link_to_section(ancestors.shift, {}, :class => 'section root')
                    if ancestors.size > 2
                        sections << '&hellip;'
                        ancestors = ancestors[-2, 2]
                    end
                    sections += ancestors.collect{ |section| link_to_section(section, {}, :class => 'section ancestor') }
                end
                sections << h(@section)
                sections.join(' &raquo; ').html_safe + ' &rsaquo;'.html_safe
            elsif @project.nil? || @project.new_record?
                page_header_title_without_sections
            elsif @project.section
                section_ancestors = @project.section.self_and_ancestors
                project_ancestors = @project.root? ? [] : @project.ancestors.visible.all

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
                projects << h(@project)

                sections.join(' &raquo; ').html_safe + ' &rsaquo; '.html_safe + projects.join(' &raquo; ').html_safe
            else
                page_header_title_without_sections
            end
        end

        # Largely a copy of #project_tree_options_for_select
        def project_tree_with_sections_options_for_select(projects, options = {})
            select_options = ''
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
                link_to(h(project), sectioned_project_url(project, options), html_options)
            else
                link_to_project_without_sections(project, options, html_options)
            end
        end

    end

end
