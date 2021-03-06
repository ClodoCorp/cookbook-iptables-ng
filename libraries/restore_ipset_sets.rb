#
# Cookbook Name:: iptables-ng
# Recipe:: restore_sets
#
# vim: ts=2:sw=2:expandtab
#
# Copyright 2014, Vasiliy Tolstov
# Copyright 2014, Alexey Mochkin
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

# This was implemented as a internal-only provider.
# Apparently, calling a LWRP from a LWRP doesn't really work with
# subscribes / notifies. Therefore, using this workaround.
require 'chef/mixin/shell_out'
include Chef::Mixin::ShellOut
require 'pathname'

module Iptables
  # Module Manage: restore_ipset_sets function
  module Manage
    def restore_ipset_sets
      Chef::Log.info 'applying sets manually'
      %w(iptables ip6tables).each do |cmd|
        next unless Pathname.new("#{cmd}-save").exist?
        shell_out!("#{cmd}-save").stdout.each_line do |rule|
          next unless rule.include?('--match-set')
          shell_out!("#{cmd} #{rule.sub!(/^-A/, '-D')}").error!
        end
      end

      Chef::Resource::Execute.new('run ipset restore', run_context).tap do |execute|
        execute.command("ipset -exist restore < #{node['iptables-ng']['script_sets']}")
        execute.run_action(:run)
      end
    end
  end
end
