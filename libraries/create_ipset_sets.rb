#
# Cookbook Name:: iptables-ng
# Recipe:: manage
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
    def create_ipset_sets()
      sets = {}

      Dir["/etc/iptables.d/sets/*"].each do |path|
        set = ::File.basename(path)
        sets[set] = ::File.read(path)
      end
 
      ipset_restore = ''
      sets.each do |k, v|
        ipset_restore << "#{v.chomp}\n"
      end

      Chef::Resource::File.new(node['iptables-ng']["script_sets"], run_context).tap do |file|
        file.owner('root')
        file.group('root')
        file.mode(00600)
        file.content(ipset_restore)
        file.run_action(:create)
      end
    end
  end
end
