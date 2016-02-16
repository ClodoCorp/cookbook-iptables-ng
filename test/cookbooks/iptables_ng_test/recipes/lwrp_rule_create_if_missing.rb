iptables_ng_rule 'ssh' do
  rule '--protocol tcp --dport 22 --match state --state NEW --jump ACCEPT'
  action :create
  notifies :run, 'ruby_block[create_rules]', :delayed
  notifies :run, 'ruby_block[restart_iptables]', :delayed
end

iptables_ng_rule 'ssh' do
  rule '--protocol tcp --dport 80 --match state --state NEW --jump ACCEPT'
  action :create_if_missing
  notifies :run, 'ruby_block[create_rules]', :delayed
  notifies :run, 'ruby_block[restart_iptables]', :delayed
end
