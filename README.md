GoDaddy "DDNS"
==============

Update a domain with your public IP (retrieved from `ipinfo.io`) using GoDaddy API

## Usage
```
./update-ip.ps1 -Key "API KEY" -Secret "API SECRET" -Domain example.com
```

## Parameters
| Parameter | Description               | Default |
| --------- | -------------             | --- |
| Key       | GoDaddy API Key           | (Mandatory) |
| Secret    | GoDaddy API Secret token  | (Mandatory) |
| Endpoint  | GoDaddy API endpoint URL  | `https://api.godaddy.com/v1` |
| Domain    | Your domain name          | (Mandatory) |
| TTL       | TTL for record            | `3600` |
| OverrideIP | Override public IP detection | none |
| ForceUpdate | Update even when IP matches | (not present) |
| RecordType | DNS Record type | `A` |

