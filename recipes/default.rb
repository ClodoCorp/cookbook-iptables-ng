#
# Cookbook Name:: iptables-ng
# Recipe:: default
#
# vim: ts=2:sw=2:expandtab
#
# Copyright 2013, Chris Aumann
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

include_recipe 'iptables-ng::install'

# Apply sets from node attributes
node['iptables-ng']['sets'].each do |name, options|
  # Apply sets
  iptables_ng_set "#{name}-attribute-set" do
    name name
    type options.select { |k, _v| k == 'type' }['type'].to_s
    options options.reject { |k, _v| k == 'type' }
  end
end

# Apply preserved rules
if !node['iptables-ng']['preserve_keyword'].empty?
  preserved_rules = Mash.new
  # Don't use this array due to autoload modules!
  #%w{security mangle raw nat filter}.each do |tbl|
  #  %w{iptables ip6tables}.each do |cmd|
  Chef::Mixin::ShellOut.shell_out("lsmod | awk -F'\\s+|_' '$1 ~ /^ip6?table/ {print $1,$2}'").stdout.each_line do |modules|
    cmd = modules.split[0]
    tbl = modules.split[1]
      Chef::Mixin::ShellOut.shell_out("#{cmd}s -t #{tbl} -S").stdout.each_line do |rule|
        next unless rule.include?(node['iptables-ng']['preserve_keyword'])
        chain = rule.split[1]
        case cmd
          when "iptables"
            v = 4
          when "ip6tables"
            v = 6
        end
        preserved_rules[tbl] = Mash.new unless preserved_rules[tbl]
        preserved_rules[tbl][chain] = Mash.new unless preserved_rules[tbl][chain]
        preserved_rules[tbl][chain]["preserved#{v}"] = Mash.new unless preserved_rules[tbl][chain]["preserved#{v}"]
        preserved_rules[tbl][chain]["preserved#{v}"]['rule'] = [] unless preserved_rules[tbl][chain]["preserved#{v}"]['rule']
        preserved_rules[tbl][chain]["preserved#{v}"]['ip_version'] = v
        preserved_rules[tbl][chain]["preserved#{v}"]['rule'] << rule.sub(/-A #{chain} (.*)/,'\1')
      end
  #  end
  end
  node.set['iptables-ng']['rules'] = Chef::Mixin::DeepMerge.merge(preserved_rules, node['iptables-ng']['rules'])
end

# Apply rules from node attributes
node['iptables-ng']['rules'].each do |table, chains|

  next unless chains

  chains.each do |chain, p|
    # policy is read only, duplicate it
    policy = p.dup

    # Apply chain policy
    iptables_ng_chain "attribute-policy-#{chain}" do
      chain chain
      table table
      policy policy.delete('default')
    end

    # Apply rules
    rule_num = 0
    policy.each do |name, r|
      iptables_ng_rule "#{sprintf('%02d', rule_num+=1)}-#{name}-#{table}-#{chain}-attribute-rule" do
        chain chain
        table table
        rule r['rule']
        ip_version r['ip_version'] if r['ip_version']
      end
    end
  end
end

ruby_block 'notify-restore-sets' do
  block do
  end
  notifies :run, 'ruby_block[create_sets]', :delayed
  notifies :run, 'ruby_block[restore_sets]', :delayed
  not_if { node['iptables-ng']['sets'].nil? }
end

ruby_block 'notify-restore-rules' do
  block do
  end
  notifies :create, 'ruby_block[create_rules]', :delayed
  notifies :create, 'ruby_block[restart_iptables]', :delayed
  not_if { node['iptables-ng']['rules'].nil? }
end
