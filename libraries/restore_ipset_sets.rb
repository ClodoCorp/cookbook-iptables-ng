#
# Cookbook Name:: iptables-ng
# Recipe:: restore_sets
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

# This was implemented as a internal-only provider.
# Apparently, calling a LWRP from a LWRP doesnt' really work with
# subscribes / notifies. Therefore, using this workaround.

module Iptables
  module Manage
    def restore_ipset_sets()
      Chef::Log.info 'applying sets manually'
      Chef::Resource::Execute.new("run ipset restore", run_context).tap do |execute|
        execute.command("ipset restore < #{node['iptables-ng']['script_sets']}")
        execute.run_action(:run)
      end
    end
  end
end

