require 'net/http'
require 'json'

# Calls a service to get the internet ip address. 
# Returns the resulting address. If no address was found, nil will be returned.
def internet_ip_address
  uri = URI.parse('https://api.ipify.org?format=json')

  response = Net::HTTP.get_response(uri)
  return nil unless response.code == '200'

  response_body = JSON.parse(response.body)
  response_body['ip']
end

# Calls a request to process the specified action on the netcup api having the
# specified params.
# Returns the responsedata from the requests response json if the request was successfull. 
# Otherwise nil will be returned.
# The customer_id, api_key and session_id are all needed for all requests except the login.
def netcup_action_request(customer_id, api_key, session_id, action, params)
  uri = URI.parse('https://ccp.netcup.net/run/webservice/servers/endpoint.php?JSON')

  # get sure we do not have nil params
  params = params || {}

  # add authentication information for non login actions
  params = params.merge({ apikey: api_key }) if api_key
  params = params.merge({ apisessionid: session_id }) if session_id
  params = params.merge({ customernumber: customer_id }) if customer_id

  header = {'Content-Type': 'application/json'}
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  request = Net::HTTP::Post.new(uri.request_uri, header)
  request.body = {
    action: action,
    param: params
  }.to_json

  response = http.request(request)
  return nil unless response.code == '200'

  response_body = JSON.parse(response.body)
  return nil if response_body['status'] == 'error'

  response_body['responsedata']
end


# Uses the specified customer_id, api_key and api_password to login to
# the netcup api. The session_id needed by following requests will be returned
# if the request was successfull. Otherwise nil will be returned.
def login_to_netcup(customer_id, api_key, api_password)
  login_result = netcup_action_request customer_id, api_key, nil, 'login', { apipassword: api_password }

  return nil unless login_result

  login_result['apisessionid']
end

# Requests and returns all current records for the specified domain.
# If the request was not successfull, nil will be
def current_records(domain, customer_id, api_key, session_id)
  result = netcup_action_request(customer_id, api_key, session_id, 'infoDnsRecords', { domainname: domain })
  return nil unless result

  result['dnsrecords']
end

# Updates the specified records of the specified domain.
# Returns true if the request was successfull. Returns false otherwise.
def update_records(domain, records, customer_id, api_key, session_id)
  return false if !records || records.length == 0
  
  result = netcup_action_request customer_id, api_key, session_id, 'updateDnsRecords',  {
    domainname: domain,
    dnsrecordset: { dnsrecords: records }
  }

  !result.nil?
end

API_KEY = ENV['NETCUP_API_KEY']
API_PASSWORD = ENV['NETCUP_API_PASSWORD']
CUSTOMER_ID = ENV['NETCUP_CUSTOMER_ID']
TOP_LEVEL_DOMAIN = ENV['NETCUP_TOP_LEVEL_DOMAIN']
TARGET_HOST = ENV['NETCUP_TARGET_HOST']

# check inputs
raise 'API key not provided, use NETCUP_API_KEY environment variable to provide API key.' unless API_KEY
raise 'API password not provided, use NETCUP_API_PASSWORD environment variable to provide API password.' unless API_PASSWORD
raise 'Customer ID not provided, use NETCUP_CUSTOMER_ID environment variable to provide customer ID.' unless CUSTOMER_ID
raise 'Top level domain not provided, use NETCUP_TOP_LEVEL_DOMAIN environment variable to provide top level domain.' unless TOP_LEVEL_DOMAIN
raise 'Target host not provided, use NETCUP_TARGET_HOST environment variable to provide target host.' unless TARGET_HOST

# get internet ip address
ip_address = internet_ip_address
raise 'Ip address could not be found.' unless ip_address

# login into netcup api
session_id = login_to_netcup CUSTOMER_ID, API_KEY, API_PASSWORD
raise 'Login failed, no session_id provided.' unless session_id

# get current records, because netcup only allowes to update all records in a domain at once
records = current_records(TOP_LEVEL_DOMAIN, CUSTOMER_ID, API_KEY, session_id)
raise 'No record information provided from netcup.' unless records

# replace correct record entry with ip address
records.each do |record|
  record.tap do |r|
    if r['hostname'] == TARGET_HOST
      r['destination'] = ip_address
    end 
  end
end

# update records
raise 'Records not updated' unless update_records TOP_LEVEL_DOMAIN, records, CUSTOMER_ID, API_KEY, session_id

puts "DNS Update successfull."
