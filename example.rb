require 'dropbox_sdk'
require 'yaml'
require 'launchy'
require 'pp'

config = YAML.load_file('config.yml')
flow = DropboxOAuth2FlowNoRedirect.new(config['app_key'], config['app_secret'])
authorize_url = flow.start()

puts '1. Go to: ' + authorize_url
puts '2. Click "Allow" (you might have to log in first)'
puts '3. Copy the authorization code'
print 'Enter the authorization code here: '

Launchy.open(authorize_url)
code = gets.strip
access_token, user_id = flow.finish(code)

client = DropboxClient.new(access_token)
puts 'linked account:', client.account_info().inspect

# save session
open('./credential.yml', 'w') { |f| f.puts(client.to_yaml) }

# restore session
client = YAML.load_file('./credential.yml')

response = client.put_file('/Gemfile', open('./Gemfile'))
pp response

pp client.metadata('/')

meta = client.shares('/Gemfile')
pp meta
Launchy.open(meta['url'])
