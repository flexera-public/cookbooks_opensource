#
# Cookbook Name:: mongodb
# Recipe:: default
#
# Copyright 2010, Example Com
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

if ["centos", "redhat", "fedora"].include? node[:platform]
  Chef::Log.info("ERROR: this cookbook only supports Ubuntu at this time")
  exit(1)
end

if node[:mongodb][:release] != 'default'
  template "/etc/apt/sources.list.d/mongo_sources.list" do
    source "mongo_sources.list"
  end
# can be 'stable', 'unstable', or 'snapshot'
  package "mongodb-#{node[:mongodb][:release]}"
else
  package "mongodb"
end