iptables_ng_chain 'EMPTY' do
  notifies :run, 'ruby_block[create_rules]', :delayed
  notifies :run, 'ruby_block[restart_iptables]', :delayed
end
