*** Settings ***
Resource        ../../RESOURCE/Library.robot
Resource        ../../RESOURCE/GlobalKey.robot

*** Keywords ***
get total event log from RPC
    ${res}              REST.post       ${internalRPC}
    ...                 {"jsonrpc":"2.0","method":"eth_getLogs","params":[{"fromBlock":"0x${blockHex}","toBlock":"0x${blockHex}"}],"id":1}     loglevel=INFO      timeout=3
    get status code from res    ${res}
    ${totalLogRPC}      Get Value From Json     ${res}    $..result..data
    ${totalLogRPC}      Get Length              ${totalLogRPC}
    Set Global Variable    ${totalLogRPC}

get total event log from PG
    [Arguments]         ${block}
    ${totalLogPG}       Query And Remove String    select count(transaction_hash) from event_logs where transaction_hash in (select hash from transactions where block_number = ${block})
    Set Global Variable    ${totalLogPG}

*** Test Cases ***
compare total event log
    ${block}            Set Variable        9293824
    connect postgres prod
    FOR     ${i}        IN RANGE        10000
        ${blockHex}                 convert number to hex    ${block}
        Set Global Variable         ${blockHex}
        ${status}   run api and make sure success    get total event log from RPC
        IF  ${status}==True
            get total event log from PG     ${block}
            IF  ${totalLogRPC}!=${totalLogPG}
                push text to discord    ${channelID}    ${botToken}
                            ...                     :notepad_spiral: ${block}: Event log PG (${totalLogPG}) != Event log RPC (${totalLogRPC})
            END
            Log To Console    ${block}::${totalLogPG}::${totalLogRPC}
            ${block}    Evaluate    ${block}-1
        END
    END