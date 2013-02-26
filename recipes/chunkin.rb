#
# Cookbook Name:: nginx
# Recipe:: chunkin
#

tar_location = "#{Chef::Config['file_cache_path']}/chunkin.tar.gz"
module_location = "#{Chef::Config['file_cache_path']}/chunkin/#{node['nginx']['chunkin']['source_checksum']}"

remote_file tar_location do
  source node['nginx']['chunkin']['source_url']
  checksum node['nginx']['chunkin']['source_checksum']
  owner 'root'
  group 'root'
  mode 0644
end

directory module_location do
  owner "root"
  group "root"
  mode 0755
  recursive true
  action :create
end

bash "extract_chunkin" do
  cwd ::File.dirname(tar_location)
  user 'root'
  code <<-EOH
    tar -zxf #{tar_location} -C #{module_location}
    mv -f #{module_location}/chunkin-nginx-module-*/* #{module_location}
    rm -rf #{module_location}/chunkin-nginx-module-*
  EOH
  not_if { ::File.exists?("#{module_location}/config") }
end

node.run_state['nginx_configure_flags'] =
    node.run_state['nginx_configure_flags'] | ["--add-module=#{module_location}"]