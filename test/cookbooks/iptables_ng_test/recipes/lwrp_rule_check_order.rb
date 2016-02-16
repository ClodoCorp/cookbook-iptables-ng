iptables_ng_rule '99-last' do
  rule '--protocol tcp --dport 99 --jump ACCEPT'
  notifies :run, 'ruby_block[create_rules]', :delayed
  notifies :run, 'ruby_block[restart_iptables]', :delayed
end

iptables_ng_rule '20-second' do
  rule '--jump ACCEPT --protocol udp --dport 20'
  notifies :run, 'ruby_block[create_rules]', :delayed
  notifies :run, 'ruby_block[restart_iptables]', :delayed
end

iptables_ng_rule '10-first' do
  rule '--protocol tcp --jump ACCEPT --sport 110'
  notifies :run, 'ruby_block[create_rules]', :delayed
  notifies :run, 'ruby_block[restart_iptables]', :delayed
end

iptables_ng_rule '51-medium-2' do
  rule '--jump ACCEPT --protocol tcp --dport 51'
  notifies :run, 'ruby_block[create_rules]', :delayed
  notifies :run, 'ruby_block[restart_iptables]', :delayed
end

iptables_ng_rule '50-medium-1' do
  rule '--protocol udp --dport 50 --jump ACCEPT'
  notifies :run, 'ruby_block[create_rules]', :delayed
  notifies :run, 'ruby_block[restart_iptables]', :delayed
end

iptables_ng_rule '98-almost-last' do
  rule '--jump ACCEPT --protocol tcp --dport 998'
  notifies :run, 'ruby_block[create_rules]', :delayed
  notifies :run, 'ruby_block[restart_iptables]', :delayed
end
