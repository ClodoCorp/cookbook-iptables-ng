iptables_ng_rule 'custom-chain-invalid-output' do
  chain 'FOO!'
  table 'nat'
  rule '--protocol icmp --jump ACCEPT'
  action :create
  notifies :run, 'ruby_block[create_rules]', :delayed
  notifies :run, 'ruby_block[restart_iptables]', :delayed
end
