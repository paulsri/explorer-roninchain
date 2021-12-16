*** Settings ***
Resource        RESOURCE/Report.robot
Library         DateTime

*** Test Cases ***
health check
    ${date}                 Get Current Date        exclude_millis=true
    push text to discord    920876399663910953      ${botToken}     ✅ ${date}: Server still alive.