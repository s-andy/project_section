require 'redmine'

require_dependency 'project_section_hook'

Rails.logger.info 'Starting Project Section Plugin for Redmine'

Rails.configuration.to_prepare do
    unless Redmine::MenuManager::MenuHelper.included_modules.include?(SectionMenuHelperPatch)
        Redmine::MenuManager::MenuHelper.send(:include, SectionMenuHelperPatch)
    end
    unless ApplicationHelper.included_modules.include?(SectionApplicationHelperPatch)
        ApplicationHelper.send(:include, SectionApplicationHelperPatch)
    end
    unless ProjectsHelper.included_modules.include?(SectionProjectsHelperPatch)
        ProjectsHelper.send(:include, SectionProjectsHelperPatch)
    end
    unless ActionView::Base.included_modules.include?(ProjectSectionHelper)
        ActionView::Base.send(:include, ProjectSectionHelper)
    end
    unless ProjectsController.included_modules.include?(SectionProjectsControllerPatch)
        ProjectsController.send(:include, SectionProjectsControllerPatch)
    end
    unless Project.included_modules.include?(SectionProjectPatch)
        Project.send(:include, SectionProjectPatch)
    end
    unless Version.included_modules.include?(SectionVersionPatch)
        Version.send(:include, SectionVersionPatch)
    end

    unless IssueCustomField.included_modules.include?(SectionCustomFieldPatch)
        IssueCustomField.send(:include, SectionCustomFieldPatch)
    end
    unless ProjectCustomField.included_modules.include?(SectionCustomFieldPatch)
        ProjectCustomField.send(:include, SectionCustomFieldPatch)
    end
    unless VersionCustomField.included_modules.include?(SectionCustomFieldPatch)
        VersionCustomField.send(:include, SectionCustomFieldPatch)
    end
end

Redmine::Plugin.register :project_section do
    name 'Project sections'
    author 'Andriy Lesyuk'
    author_url 'http://www.andriylesyuk.com/'
    description 'Adds support for project sections, which allow to categorize projects and more.'
    url 'http://projects.andriylesyuk.com/projects/project-section'
    version '0.1.0'

    permission :select_project_section, {}, :require => :loggedin

    menu :admin_menu, :project_sections,
                    { :controller => 'project_sections', :action => 'index' },
                      :caption => :label_project_section_plural,
                      :after => :projects
end
