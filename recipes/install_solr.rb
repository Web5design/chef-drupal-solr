## Cookbook Name:: deploy-drupal
## Recipe:: install_solr
##

include_recipe 'tomcat::default'

SOLR_CONTEXT_FILE       = node['tomcat']['context_dir'] + "/" +
                          node['deploy-drupal']['solr']['app_name'] + ".xml"

SOLR_ARCHIVE            = "apache-solr-" + node['deploy-drupal']['solr']['version']


# directory containing solr.war file
# if war file is removed tomcat undeploys application
directory node['deploy-drupal']['solr']['root_dir'] do
  owner node['tomcat']['user']
  group node['tomcat']['group']
  mode 0775
  recursive true
end

# solr/home directory
directory node['deploy-drupal']['solr']['home_dir'] do
  owner node['tomcat']['user']
  group node['tomcat']['group']
  mode 0775
  recursive true
end

bash "download-solr-#{node['deploy-drupal']['solr']['version']}" do
  user node['tomcat']['user']
  cwd node['deploy-drupal']['solr']['root_dir']
  code <<-EOH
    curl #{node['deploy-drupal']['solr']['url']} | tar xz
    cp #{SOLR_ARCHIVE}/example/webapps/solr.war .
    cp -Rf #{SOLR_ARCHIVE}/example/solr/. #{node['deploy-drupal']['solr']['home_dir']}/
  EOH
  creates node['deploy-drupal']['solr']['home_dir'] + "/conf/schema.xml"
  notifies :restart, "service[tomcat]", :delayed
end

template SOLR_CONTEXT_FILE do
  owner node['tomcat']['user']
  group node['tomcat']['group']
  mode 0644
  source "solr_context.xml.erb"
  notifies :restart, "service[tomcat]"
end