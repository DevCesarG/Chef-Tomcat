#
# Cookbook:: tomcat
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

# install OpenJDK 7 JDK
package 'java-1.7.0-openjdk-devel'

# create a new tomcat group
group 'tomcat' 

# create user tomcat
user 'tomcat' do
	manage_home false
	shell '/bin/nologin'
	group 'tomcat'
	home '/opt/tomcat'
end

# download tomcat
remote_file ('apache-tomcat-8.5.23.tar.gz') do
	source 'http://apache.mirrors.ionfish.org/tomcat/tomcat-8/v8.5.23/bin/apache-tomcat-8.5.23.tar.gz'
end

# create directory /opt/tomcat
directory '/opt/tomcat' do
	action (:create)
end

# install tomcat
execute 'tar xvf apache-tomcat-8*tar.gz -C /opt/tomcat --strip-components=1'

# Give the tomcat group ownership over the entire installation directory
execute 'chgrp -R tomcat /opt/tomcat'

# Give the tomcat group read acces to all the components
execute 'chmod -R g+r /opt/tomcat/{conf,webapps,work,temp,logs}'

# Change the mode of the directory
directory '/opt/tomcat/conf' do
	mode '0070'
end

# Make the tomcat user the owner of these directories
# execute 'chown -R tomcat /opt/tomcat/{conf,webapps,work,temp,logs}'
%w[ webapps work temp logs ].each do |path|
  directory "/opt/tomcat/#{path}" do
    owner 'tomcat'
    group 'tomcat'
  end
end


template '/etc/systemd/system/tomcat.service' do
	source 'tomcat.service.erb'
end

# reload Systemd to load the Tomcat unit file
execute 'systemctl daemon-reload'

service 'tomcat' do
	action [:start, :enable]
end


