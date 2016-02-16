iptables_ng_rule 'ssh' do
  # use defaults
  rule '--protocol tcp --dport 22 --match state --state NEW --jump ACCEPT'
  notifies :run, 'ruby_block[create_rules]', :delayed
  notifies :run, 'ruby_block[restart_iptables]', :delayed
end
