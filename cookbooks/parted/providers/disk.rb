#
# Cookbook Name:: raid
# Provider:: parted
#
# Copyright 2012-2013, John Dewey
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
require 'chef/mixin/shell_out'
include Chef::Mixin::ShellOut


def last_partition_num resource
  cmd = "parted #{resource.device} --script -- p | awk '{print $1}'|tail -n 2"
  rc = shell_out(cmd)
  resource.last_num = rc.stdout
  if resource.last_num.include? "Number"
    resource.last_num = 0
    Chef::Log.info("There is not any partition created at #{resource.device} yet.")
  end
end

def partition_start_size resource
  cmd = "parted #{resource.device} --script -- p | awk '{print $3}' | tail -n 2"
  rc = shell_out(cmd)
  resource.start_size = rc.stdout.split[0]
  if resource.start_size.include? "End"
    resource.start_size = 0
  end
end

def disk_total_size resource
  cmd = "parted #{resource.device} --script -- p | grep #{resource.device} | cut -f 2 -d ':'"
  rc = shell_out(cmd)
  resource.total_size = rc.stdout.split[0]
end
  
def file_partition_size
  output = %x{df -h /}
  available_size = output.lines.to_a[1].split[3]
  if available_size == nil
    available_size = (output.lines.to_a[1].split + output.lines.to_a[2].split)[3]
  end
  file_size = ((available_size.scan(/\d+/)[0].to_f)/2).to_s + available_size.scan(/[MGTEY]/)[0]
  return file_size
end

def select_loop_device
  used_loop_device = %x{losetup -a |cut -f 1 -d ':'}.split
  total_loop_device = %x{ls /dev/loop*}.split
  available_loop = total_loop_device - used_loop_device
  return available_loop[0]
end

action :mklabel do
  execute "parted #{new_resource.device} --script -- mklabel #{new_resource.label_type}" do
    new_resource.updated_by_last_action(true)
    not_if "parted #{new_resource.device} --script -- print |grep 'Partition Table: #{new_resource.label_type}'"
  end
end

action :mkpart do
  disk_total_size new_resource
  partition_start_size new_resource
  execute "parted #{new_resource.device} --script -- mkpart #{new_resource.part_type} #{new_resource.file_system} #{new_resource.start_size} -1" do
    new_resource.updated_by_last_action(true)
    not_if {new_resource.start_size == new_resource.total_size}
  end
end

action :mkfs do
  execute "mkfs.#{new_resource.file_system} #{new_resource.device}" do
    new_resource.updated_by_last_action(true)
    not_if "file -sL #{new_resource.device} |grep #{new_resource.part_type}"
  end
end
