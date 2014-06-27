#
# Cookbook Name:: iptables-ng
# Provider:: set
#
# Copyright 2014, Vasiliy Tolstov
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
use_inline_resources if defined?(use_inline_resources)

def whyrun_supported?
  true
end

action :create do
  edit_set(:create)
end

action :create_if_missing do
  edit_set(:create_if_missing)
end

action :delete do
  edit_set(:delete)
end

def edit_set(exec_action)
  set_file = "create #{new_resource.name} #{new_resource.type}"

  new_resource.options.each do |opt|
    set_file = set_file + ' ' + opt.join(' ')
  end

  set_file += "\n"

  directory '/etc/iptables.d/sets/' do
    owner 'root'
    group 'root'
    mode 00700
    recursive true
    not_if { exec_action == :delete }
  end

  set_path = "/etc/iptables.d/sets/#{new_resource.name}"

  r = file set_path do
    owner 'root'
    group 'root'
    mode 00600
    content set_file
    notifies :create, 'ruby_block[create_sets]', :immediately
    notifies :create, 'ruby_block[restore_sets]', :immediately
    action exec_action
  end

  new_resource.updated_by_last_action(true) if r.updated_by_last_action?
end
