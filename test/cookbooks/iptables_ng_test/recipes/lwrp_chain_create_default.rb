iptables_ng_chain 'FORWARD' do
  policy 'DROP [0:0]'
  action :create
  notifies :run, 'ruby_block[create_rules]', :delayed
  notifies :run, 'ruby_block[restart_iptables]', :delayed
end
