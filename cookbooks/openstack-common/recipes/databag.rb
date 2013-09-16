#
# Cookbook Name:: openstack-common
# Attributes:: default
#
# Copyright 2013, Futurewei, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# 
# import initial data from databag with customized user data.
#
defaultbag = "openstack"
if !Chef::DataBag.list.key?(defaultbag)
    Chef::Application.fatal!("databag '#{defaultbag}' doesn't exist.")
    return
end

myitem = 'env_default'.freeze if defined?("#{node[mycluster]}")

puts "+++++++++++++++++++++++++++++"
puts "The current databag is #{defaultbag}, databagitem is #{myitem}"
puts "+++++++++++++++++++++++++++++"

if !search(defaultbag, "id:#{myitem}")
    Chef::Application.fatal!("databagitem '#{databagitem}' doesn't exist.")
    return
end

mydata = data_bag_item(defaultbag, myitem)
# use unsecreted text username and password at chef server.
node.override['openstack']['developer_mode'] = mydata['credential']['text']

# The coordinated release of OpenStack codename
node.override['openstack']['release'] = mydata['release']

# Openstack repo setup
# ubuntu
node.override['openstack']['apt']['components'] = [ "precise-updates/#{node['openstack']['release']}", "main" ]

# redhat
node.override['openstack']['yum']['openstack']['url']="http://repos.fedorapeople.org/repos/openstack/openstack-#{node['openstack']['release']}/epel-#{node['platform_version'].to_i}/"

# Tenant and user
node.override['openstack']['identity']['admin_token'] = mydata['credential']['identity']['token']['admin']
node.override['openstack']['identity']['tenants'] = ["#{ mydata['credential']['identity']['tenants']['admin']}", "#{ mydata['credential']['identity']['tenants']['service']}"]
node.override["openstack"]["identity"]["roles"] = ["#{ mydata['credential']['identity']['roles']['admin']}", "#{ mydata['credential']['identity']['roles']['member']}"]

puts "************************"
puts "node['openstack']['identity']['tenants']= #{node['openstack']['identity']['tenants']}"
puts "node['openstack']['identity']['roles']= #{node['openstack']['identity']['roles']}"
puts "************************"


node.override['openstack']['identity']['admin_tenant_name'] = mydata['credential']['identity']['tenants']['admin']
node.override['openstack']['identity']['admin_user'] = mydata['credential']['identity']['users']['admin']['username']
node.override['openstack']['identity']['admin_password'] = mydata['credential']['identity']['users']['admin']['password']

# services with related usernames and passwords
node['openstack']['services'].each_key do |service|
    node.override['openstack']['services']["#{service}"] = mydata['services']["#{service}"]
    if "#{service}" != "identity" and "#{service}" != "dashboard"
        node.override["openstack"]["identity"]["#{service}"]["username"] = mydata["credential"]["identity"]["users"]["#{service}"]["username"]
        node.override['openstack']['identity']["#{service}"]['password'] = mydata['credential']['identity']['users']["#{service}"]['password']
        node.override['openstack']['identity']["#{service}"]['role'] = mydata['credential']['identity']['roles']['admin']
    end
end


# ======================== OpenStack Endpoints ================================
# Identity (keystone)
node.override['openstack']['endpoints']['identity-api']['host'] = mydata['endpoints']['identity']['service']['host']
node.override['openstack']['endpoints']['identity-api']['scheme'] = mydata['endpoints']['identity']['service']['scheme']
#node.override['openstack']['endpoints']['identity-api']['port'] = "5000"
#node.override['openstack']['endpoints']['identity-api']['path'] = "/v2.0"

node.override['openstack']['endpoints']['identity-admin']['host'] = mydata['endpoints']['identity']['admin']['host']
node.override['openstack']['endpoints']['identity-admin']['scheme'] = mydata['endpoints']['identity']['admin']['scheme']
#node.override['openstack']['endpoints']['identity-admin']['port'] = "35357"
#node.override['openstack']['endpoints']['identity-admin']['path'] = "/v2.0"

# Compute (Nova)
node.override['openstack']['endpoints']['compute-api']['host'] = mydata['endpoints']['compute']['service']['host']
node.override['openstack']['endpoints']['compute-api']['scheme'] = mydata['endpoints']['compute']['service']['scheme']
#node.override['openstack']['endpoints']['compute-api']['port'] = "8774"
#node.override['openstack']['endpoints']['compute-api']['path'] = "/v2/%(tenant_id)s"

# The OpenStack Compute (Nova) EC2 API endpoint
node.override['openstack']['endpoints']['compute-ec2-api']['host'] = mydata['endpoints']['ec2']['service']['host']
node.override['openstack']['endpoints']['compute-ec2-api']['scheme'] = mydata['endpoints']['ec2']['service']['scheme']
#node.override['openstack']['endpoints']['compute-ec2-api']['port'] = "8773"
#node.override['openstack']['endpoints']['compute-ec2-api']['path'] = "/services/Cloud"

# The OpenStack Compute (Nova) EC2 Admin API endpoint
node.override['openstack']['endpoints']['compute-ec2-admin']['host'] = mydata['endpoints']['ec2']['admin']['host']
node.override['openstack']['endpoints']['compute-ec2-admin']['scheme'] = mydata['endpoints']['ec2']['admin']['scheme']
#node.override['openstack']['endpoints']['compute-ec2-admin']['port'] = "8773"
#node.override['openstack']['endpoints']['compute-ec2-admin']['path'] = "/services/Admin"

# The OpenStack Compute (Nova) XVPvnc endpoint
node.override['openstack']['endpoints']['compute-xvpvnc']['host'] = mydata['endpoints']['compute']['xvpvnc']['host']
node.override['openstack']['endpoints']['compute-xvpvnc']['scheme'] = mydata['endpoints']['compute']['xvpvnc']['scheme']
#node.override['openstack']['endpoints']['compute-xvpvnc']['port'] = "6081"
#node.override['openstack']['endpoints']['compute-xvpvnc']['path'] = "/console"

# The OpenStack Compute (Nova) novnc endpoint
node.override['openstack']['endpoints']['compute-novnc']['host'] = mydata['endpoints']['compute']['novnc']['host']
node.override['openstack']['endpoints']['compute-novnc']['scheme'] = mydata['endpoints']['compute']['novnc']['scheme']
#node.override['openstack']['endpoints']['compute-novnc']['port'] = "6080"
#node.override['openstack']['endpoints']['compute-novnc']['path'] = "/vnc_auto.html"


# Network (Quantum)
node.override['openstack']['endpoints']['network-api']['host'] = mydata['endpoints']['network']['service']['host']
node.override['openstack']['endpoints']['network-api']['scheme'] = mydata['endpoints']['network']['service']['scheme']
#node.override['openstack']['endpoints']['network-api']['port'] = "9696"
# quantumclient appends the protocol version to the endpoint URL, so the

# Image (Glance)
node.override['openstack']['endpoints']['image-api']['host'] = mydata['endpoints']['image']['service']['host']
node.override['openstack']['endpoints']['image-api']['scheme'] = mydata['endpoints']['image']['service']['scheme']
#node.override['openstack']['endpoints']['image-api']['port'] = "9292"
#node.override['openstack']['endpoints']['image-api']['path'] = "/v2"

# Image (Glance) Registry
node.override['openstack']['endpoints']['image-registry']['host'] = mydata['endpoints']['image']['registry']['host']
node.override['openstack']['endpoints']['image-registry']['scheme'] = mydata['endpoints']['image']['registry']['scheme']
node.override['openstack']['endpoints']['image-registry']['port'] = "9191"
node.override['openstack']['endpoints']['image-registry']['path'] = "/v2"

# Volume (Cinder)
node.override['openstack']['endpoints']['volume-api']['host'] = mydata['endpoints']['volume']['service']['host']
node.override['openstack']['endpoints']['volume-api']['scheme'] = mydata['endpoints']['volume']['service']['scheme']
#node.override['openstack']['endpoints']['volume-api']['port'] = "8776"
#node.override['openstack']['endpoints']['volume-api']['path'] = "/v1/%(tenant_id)s"

# Metering (Ceilometer)
node.override['openstack']['endpoints']['metering-api']['host'] = mydata['endpoints']['metering']['service']['host']
node.override['openstack']['endpoints']['metering-api']['scheme'] = mydata['endpoints']['metering']['service']['scheme']
#node.override['openstack']['endpoints']['metering-api']['port'] = "8777"
#node.override['openstack']['endpoints']['metering-api']['path'] = "/v1"


# ======================== OpenStack DB Support ================================
# set database attributes
#node.override['openstack']['db']['server_role'] = "os-ops-database"
node.override['openstack']['db']['service_type'] = mydata['db']['service_type']
node.override['openstack']['db']['port'] = mydata['db']["#{node['openstack']['db']['service_type']}"]['port']
node.override['openstack']['db']['bind_address'] = mydata['db']["#{node['openstack']['db']['service_type']}"]['bind_address']

# Database used by the OpenStack Compute (Nova) service
node.override['openstack']['db']['compute']['db_type'] = node['openstack']['db']['service_type']
node.override['openstack']['db']['compute']['host'] = node['openstack']['db']['bind_address']
node.override['openstack']['db']['compute']['port'] = node['openstack']['db']['port']
#node.override['openstack']['db']['compute']['db_name'] = "nova"

# Database used by the OpenStack Identity (Keystone) service
node.override['openstack']['db']['identity']['db_type'] = node['openstack']['db']['service_type']
node.override['openstack']['db']['identity']['host'] = node['openstack']['db']['bind_address']
node.override['openstack']['db']['identity']['port'] = node['openstack']['db']['port']
#node.override['openstack']['db']['identity']['db_name'] = "keystone"

# Database used by the OpenStack Image (Glance) service
node.override['openstack']['db']['image']['db_type'] = node['openstack']['db']['service_type']
node.override['openstack']['db']['image']['host'] = node['openstack']['db']['bind_address']
node.override['openstack']['db']['image']['port'] = node['openstack']['db']['port']
#node.override['openstack']['db']['image']['db_name'] = "glance"

# Database used by the OpenStack Network (Quantum) service
node.override['openstack']['db']['network']['db_type'] = node['openstack']['db']['service_type']
node.override['openstack']['db']['network']['host'] = node['openstack']['db']['bind_address']
node.override['openstack']['db']['network']['port'] = node['openstack']['db']['port']
#node.override['openstack']['db']['network']['db_name'] = "quantum"

# Database used by the OpenStack Volume (Cinder) service
node.override['openstack']['db']['volume']['db_type'] = node['openstack']['db']['service_type']
node.override['openstack']['db']['volume']['host'] = node['openstack']['db']['bind_address']
node.override['openstack']['db']['volume']['port'] = node['openstack']['db']['port']
#node.override['openstack']['db']['volume']['db_name'] = "cinder"

# Database used by the OpenStack Dashboard (Horizon)
node.override['openstack']['db']['dashboard']['db_type'] = node['openstack']['db']['service_type']
node.override['openstack']['db']['dashboard']['host'] = node['openstack']['db']['bind_address']
node.override['openstack']['db']['dashboard']['port'] = node['openstack']['db']['port']
#node.override['openstack']['db']['dashboard']['db_name'] = "horizon"

# Database used by OpenStack Metering (Ceilometer)
node.override['openstack']['db']['metering']['db_type'] = node['openstack']['db']['service_type']
node.override['openstack']['db']['metering']['host'] = node['openstack']['db']['bind_address']
node.override['openstack']['db']['metering']['port'] = node['openstack']['db']['port']
#node.override['openstack']['db']['metering']['db_name'] = "ceilometer"

# node.override database attributes
#node.override['openstack']['mq']['server_role'] = "os-ops-messaging"
node.override['openstack']['mq']['service_type'] = mydata['mq']['service_type']
node.override['openstack']['mq']['bind_address'] = mydata['mq']["#{node['openstack']['mq']['service_type']}"]['bind_address']
node.override['openstack']['mq']['port'] = mydata['mq']["#{node['openstack']['mq']['service_type']}"]['port']
node.override['openstack']['mq']['user'] = mydata['credential']['mq']["#{node['openstack']['mq']['service_type']}"]['username']
node.override['openstack']['mq']['password'] = mydata['credential']['mq']["#{node['openstack']['mq']['service_type']}"]['password']
#node.override['openstack']['mq']['vhost'] = "/"
