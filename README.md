# I. OVERVIEW:

- Automation for Explorer Roninchain
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
- DatabaseLibrary: pip install robotframework-databaselibrary
- psycopg2: pip install psycopg2-binary
- Fake data: pip install robotframework-faker

## 3. Ignore.robot: this file includes secret key

- phrase: 12-word Secret Recovery Phrase to import wallet
- address: send asset
- botToken: bot token to send discord message
- reportChannel: channel where push report message

# III. EXECUTE:

- Run each file: robot file-location
- Run all file: pabot folder-location