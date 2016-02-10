source 'https://api.berkshelf.com'
metadata

group :integration do
  cookbook 'minitest-handler'
  cookbook 'iptables_ng_test', path: 'test/cookbooks/iptables_ng_test'

  cookbook 'repos',
    git: 'ssh://git@stash.clodo.ru/cook/cookbook-repos.git',
    ref: 'master'

  cookbook 'platform_packages',
    git: 'https://github.com/ClodoCorp/chef-platform_packages.git',
    ref: 'master'
end
