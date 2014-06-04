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
end

Redmine::Plugin.register :project_section do
    name 'Project section'
    author 'Andriy Lesyuk'
    author_url 'http://www.andriylesyuk.com/'
    description 'Adds support for project sections, which allow to categorize projects and more.'
    url 'http://projects.andriylesyuk.com/projects/project-section'
    version '0.0.2'

    permission :select_project_section, {}, :require => :loggedin

    menu :admin_menu, :project_sections,
                    { :controller => 'project_sections', :action => 'index' },
                      :caption => :label_project_section_plural,
                      :after => :projects
end
