rules = Mash.new
sets = {}
bag = node['iptables-ng']['data_bag']

unless node['iptables-ng']['data_bags'].nil?
  node['iptables-ng']['data_bags'].each do |item|
    bag_item = begin
      if node['iptables-ng']['secret']
        secret = Chef::EncryptedDataBagItem.load_secret(node['iptables-ng']['secret'])
        Chef::EncryptedDataBagItem.load(bag, item, secret)
      else
        data_bag_item(bag, item)
      end
    rescue => ex
      Chef::Log.info("Data bag #{bag} not found (#{ex}), so skipping")
      {}
    end

    rules = Chef::Mixin::DeepMerge.merge(rules, bag_item['rules'])

    next unless bag_item['sets']

    bag_item['sets'].each do |s|
      sets = Chef::Mixin::DeepMerge.merge(sets, s)
    end
  end

  node.set['iptables-ng']['sets'] = sets
  node.set['iptables-ng']['rules'] = rules
  include_recipe 'iptables-ng'
end
