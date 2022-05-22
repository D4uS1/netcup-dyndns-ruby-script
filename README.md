# Netcup DynDNS script
This ruby script updates a dns record using your internet ip adress.
It can be used as DynDNS if you automate the script usage periodically.

## Manual usage
You need to get an api key and password to be able to request the netcup api. Read the [netcup api docs](https://www.netcup-wiki.de/wiki/CCP_API) to see how to get a key and password.

You need to provide the following environment variables:
* NETCUP_API_KEY - Your api key for authentication
* NETCUP_API_PASSWORD  - Your api password for authentication
* NETCUP_CUSTOMER_ID - Your customer id
* NETCUP_TOP_LEVEL_DOMAIN - Your domain on which you want to apply the DNS change
* NETCUP_TARGET_HOST - The target host on which you want to apply the DNS change. For example, if you want to apply the change to some subdomain record, type in the subdomain here. If you want to change the top level domains dns, type in * here

Note that your record must exist and will not be created. This script only updates the record.

Example usage:
```
NETCUP_API_KEY=your_api_key NETCUP_API_PASSWORD=your_api_password NETCUP_CUSTOMER_ID=your_customer_id NETCUP_TOP_LEVEL_DOMAIN=your-domain.com NETCUP_TARGET_HOST=target_host ruby netcup_dyndns.rb
``` 
