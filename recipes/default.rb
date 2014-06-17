

#
# Cookbook Name:: iptables-ng
# Recipe:: default
#
# Copyright 2013, Chris Aumann
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

include_recipe 'iptables-ng::install'

# Apply sets from node attributes
node['iptables-ng']['sets'].each do |name, options|
  # Apply sets
  iptables_ng_set "#{name}-attribute-set" do
    name      name
    type      options.select {|k,v| k == "type"}["type"].to_s
    options   options.reject {|k,v| k == "type"}
  end
end

# Apply rules from node attributes
node['iptables-ng']['rules'].each do |table, chains|

  next unless chains

  chains.each do |chain, p|
    # policy is read only, duplicate it
    policy = p.dup
    
    # Apply chain policy
    iptables_ng_chain "attribute-policy-#{chain}" do
      chain  chain
      table  table
      policy policy.delete('default')
    end
    
    # Apply rules
    policy.each do |name, r|
      iptables_ng_rule "#{name}-#{table}-#{chain}-attribute-rule" do
        chain      chain
        table      table
        rule       r['rule']
        ip_version r['ip_version'] if r['ip_version']
      end
    end
  end
end

unless node['iptables-ng']['sets'].nil?
  execute "update sets if needed" do
    command "exit"
    notifies :create, 'ruby_block[create_sets]', :delayed
    notifies :create, 'ruby_block[restore_sets]', :delayed
  end
end

unless node['iptables-ng']['rules'].nil?
  execute "update rules if needed" do
    command "exit"
    notifies :create, 'ruby_block[create_rules]', :delayed
    notifies :create, 'ruby_block[restart_iptables]', :delayed
  end
end
