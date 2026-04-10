import csv
import requests
from datetime import datetime, timedelta

# --- CONFIGURATION ---
# Replace 'YOUR_API_KEY_HERE' with the key you generated in Step 1
API_KEY = '8f4719e0f23c56e4023c3535d5e254049d96bede87ae48c5' 

def get_latest_iocs():
    url = "https://urlhaus-api.abuse.ch/v1/urls/recent/"
    headers = {'Auth-Key': API_KEY}
    
    try:
        print(f"Connecting to URLhaus...")
        response = requests.get(url, headers=headers)
        response.raise_for_status()
        data = response.json()
    except requests.exceptions.HTTPError as e:
        print(f"🚨 Authentication Failed: {e}")
        print("Tip: Make sure you updated the API_KEY variable in the script.")
        return []
    
    iocs = []
    expiry = (datetime.utcnow() + timedelta(days=365)).strftime('%Y-%m-%dT%H:%M:%S.0Z')
    
    # Mapping the first 1000 items to Microsoft Defender schema
    for entry in data.get('urls', [])[:1000]:
        iocs.append({
            "indicatorType": "Url",
            "indicatorValue": entry['url'],
            "action": "Audit",
            "title": f"OSINT - {entry['reporter']}",
            "description": f"Threat: {entry.get('threat', 'Malware')} | Added: {entry.get('dateadded')}",
            "expirationTime": expiry,
            "severity": "High" if entry['url_status'] == 'online' else "Medium",
            "recommendedActions": "Check web proxy logs for outbound traffic."
        })
    return iocs

def export_to_csv(iocs, filename):
    if not iocs:
        return
    keys = iocs[0].keys()
    with open(filename, 'w', newline='', encoding='utf-8') as f:
        dict_writer = csv.DictWriter(f, fieldnames=keys)
        dict_writer.writeheader()
        dict_writer.writerows(iocs)

if __name__ == "__main__":
    latest_iocs = get_latest_iocs()
    if latest_iocs:
        export_to_csv(latest_iocs, "Defender_IOC_Import.csv")
        print(f"✅ Success! Created 'Defender_IOC_Import.csv' with {len(latest_iocs)} rows.")
        print(f"🛡🦅🌎⚓Developed By Curtis Jones - Senior Security Architect RDU.")