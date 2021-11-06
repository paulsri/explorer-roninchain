# I. OVERVIEW:
- Automation for Ronin wallet on Browser: Chrome & Firefox
- Test case:
> Create wallet  
> Import wallet  
> Redirect screen  
> Send asset  
> Wallet setting
- Report test result to discord: https://discord.gg/e7eKWJKU5S

# II. SET UP:
## 1. Python & Pycharm IDE
## 2. Library
- SeleniumLibrary: pip install robotframework-selenium2library
- RequestsLibrary: pip install robotframework-requests
- REST: pip install RESTinstance
- DebugLibrary: pip install robotframework-debuglibrary
- JSONLibrary: pip install robotframework-jsonlibrary
- Papot execution: pip install robotframework-pabot
- OperatingSystem
- String
- Collections

## 3. Ignore.robot: this file includes secret key
- phrase: 12-word Secret Recovery Phrase to import wallet
- address: send asset
- botToken: bot token to send discord message
- reportChannel: channel where push report message

# III. EXECUTE:
- Run each file: robot file-location
- Run all file: pabot folder-location