module ProjectSectionHelper

    def project_section_tree(sections, &block)
        ancestors = []
        sections.sort_by(&:lft).each do |section|
            while ancestors.any? && !section.is_descendant_of?(ancestors.last)
                ancestors.pop
            end
            yield(section, ancestors.size)
            ancestors << section
        end
    end

    def project_tree_with_sections(projects, &block)
        (ProjectSection.roots + Project.unsectioned.roots).sort_by(&:name).each do |root|
            if root.is_a?(ProjectSection)
                root.self_and_descendants.sort_by(&:lft).each do |section|
                    ancestors = []
                    section.projects.sort_by(&:lft).each do |project|
                        while ancestors.any? && !project.is_descendant_of?(ancestors.last)
                            ancestors.pop
                        end
                        if projects.include?(project)
                            prefix = section.self_and_ancestors.collect{ |section| h(section) }.join(' &#187; ')
                            yield(project, ancestors.size, prefix)
                        end
                        ancestors << project
                    end
                end
            else
                ancestors = []
                root.self_and_descendants.sort_by(&:lft).each do |project|
                    while ancestors.any? && !project.is_descendant_of?(ancestors.last)
                        ancestors.pop
                    end
                    yield(project, ancestors.size) if projects.include?(project)
                    ancestors << project
                end
            end
        end
    end

    def sectioned_project_url(project, options = {})
        if project.section && (!options.has_key?(:action) || options[:action] == 'show')
            url = "#{Redmine::Utils.relative_url_root}/project/#{project.section.to_path}/#{project.to_param}"
            url = "#{Setting.protocol}://#{Setting.host_name}" + url if options.delete(:only_path) == false
            args = options.reject{ |option, value| [ :controller, :action, :section, :id ].include?(option.to_sym) }
            url << '?' + args.collect{ |name, value| CGI.escape(name.to_s) + '=' + CGI.escape(value.to_s) }.join('&') if args.any?
            url
        else
            url_for({ :controller => 'projects', :action => 'show', :id => project }.merge(options))
        end
    end

    def section_url(section, options = {})
        url = "#{Redmine::Utils.relative_url_root}/section/#{section.to_path}"
        url = "#{Setting.protocol}://#{Setting.host_name}" + url if options.delete(:only_path) == false
        args = options.reject{ |option| [ :controller, :action, :section ].include?(option) }
        url << '?' + args.collect{ |name, value| CGI.escape(name.to_s) + '=' + CGI.escape(value.to_s) }.join('&') if args.any?
        url
    end

    def link_to_section(section, options = {}, html_options = nil)
        link_to(h(section), section_url(section, options), html_options)
    end

    def section_link_full(section, options = {}, html_options = nil)
        section.self_and_ancestors.collect{ |section| link_to_section(section, options, html_options) }.join(' &#187; ').html_safe
    end

    def parent_project_section_select_tag(sections, section = nil, options = {})
        object_name = options.delete(:object) || :project
        field_name = options.delete(:field) || :section_id
        select_options = ''
        select_options << '<option value=""></option>'
        select_options << project_section_tree_options_for_select(sections, options.merge(:selected => section))
        content_tag(:select, select_options.html_safe, :name => "#{object_name}[#{field_name}]", :id => "#{object_name}_#{field_name}")
    end

    def project_section_tree_options_for_select(sections, options = {}, &block)
        selected_option = options.delete(:selected)
        skip_empty = options.delete(:skip_empty)
        content = ''
        project_section_tree(sections) do |section, level|
            if !skip_empty || section.projects.size > 0
                tag_options = { :value => section.id }
                tag_options[:selected] = 'selected' if section == selected_option
                tag_options.merge!(yield(section)) if block_given?
                full_name = section.self_and_ancestors.collect{ |section| h(section) }.join(' &#187; ').html_safe
                content << content_tag(:option, full_name, options.merge(tag_options))
            end
        end
        content.html_safe
    end

end
