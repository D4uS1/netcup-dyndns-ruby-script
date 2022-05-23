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

## Automation Example using Crontab (Debian)
Install Ruby and git if you haven't already.
```
sudo apt-get update
sudo apt-get install ruby git
```

Clone this repository (I clone the repo in the opt directory here using sudo, to get the root user as file owner):
```
cd /opt
sudo git clone https://github.com/D4uS1/netcup-dyndns-ruby-script
```

Restrict access to root user (using 700 works here because we cloned the repo using sudo, hence the root user is the owner of all files):
```
cd /opt/netcup-dyndns-ruby-script/
sudo chmod 700 netcup_dyndns.rb
```

Add the entry to the root users crontab (In this example add the entry to update the dns every day at 5 am):
```
sudo crontab -e


Add the following line (with the correct replacements for your credentials and domain data):

00 05 * * * NETCUP_API_KEY=your_api_key NETCUP_API_PASSWORD=your_api_password NETCUP_CUSTOMER_ID=your_customer_id NETCUP_TOP_LEVEL_DOMAIN=your-domain.com NETCUP_TARGET_HOST=your-target-host ruby /opt/netcup-dyndns-ruby-script/netcup_dyndns.rb
```
Note that you have to add the absolute path to the file here.
If you want to change the dns for your target domain, use * as target_host value.

For sure you should also be able to execute the script as non root. You just have to set other permissions and change the crontab of the user who executes the script. I just took the root here because i think updating the DNS records should be something the admin should be restricted to.
