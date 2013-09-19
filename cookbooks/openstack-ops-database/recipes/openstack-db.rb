#
# Cookbook Name:: openstack-ops-database
# Recipe:: openstack-db
#
# Copyright 2012-2013, AT&T Services, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

class ::Chef::Recipe
  include ::Openstack
end

# sam added
mydata = data_bag_item('openstack','env_default')


db_create_with_user(
  "compute",
  node["openstack"]["db"]["compute"]["username"],
  db_password("#{mydata['credential']['mysql']['compute']['password']}")
)

db_create_with_user(
  "dashboard",
  node["openstack"]["db"]["dashboard"]["username"],
  db_password("#{mydata['credential']['mysql']['dashboard']['password']}")
)

db_create_with_user(
  "identity",
  node["openstack"]["db"]["identity"]["username"],
  db_password("#{mydata['credential']['mysql']['identity']['password']}")
)

db_create_with_user(
  "image",
  node["openstack"]["db"]["image"]["username"],
  db_password("#{mydata['credential']['mysql']['image']['password']}")
)

db_create_with_user(
  "metering",
  node["openstack"]["db"]["metering"]["username"],
  db_password("#{mydata['credential']['mysql']['metering']['password']}")
)

db_create_with_user(
  "network",
  node["openstack"]["db"]["network"]["username"],
  db_password("#{mydata['credential']['mysql']['network']['password']}")
)

db_create_with_user(
  "volume",
  node["openstack"]["db"]["volume"]["username"],
  db_password("#{mydata['credential']['mysql']['volume']['password']}")
)
