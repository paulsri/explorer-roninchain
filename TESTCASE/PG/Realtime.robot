*** Settings ***
Resource        ../../RESOURCE/Library.robot
Resource        ../../RESOURCE/GlobalKey.robot

*** Keywords ***
get latest transactions
    ${data}             Query And Remove String    select "block_number" from transactions order by "block_number" desc limit 1;
    [Return]            ${data}

get latest token_transfers
    ${data}             Query And Remove String    select "block_number" from token_transfers order by "block_number" desc limit 1;
    [Return]            ${data}

get latest token_balances
    ${data}             Query And Remove String    select "block_number" from token_balances order by "block_number" desc limit 1;
    [Return]            ${data}

get latest event_logs
    ${data}             Query And Remove String    select "block_number" from event_logs order by "block_number" desc limit 1;
    [Return]            ${data}

*** Test Cases ***
realtime checker
    connect postgres prod
    ${diffError}        Set Variable    5
    FOR     ${i}    IN RANGE    10000
        ${status}       Run Keyword And Return Status           get latest blocks from node
        IF  ${status}==True
            ${blockPG}      get latest blocks from postgres
            ${diff}         cal diff        ${latestRPC}    ${blockPG}
            IF  ${diff}>${diffError}
                push text to discord    ${channelID}    ${botToken}    :warning: Delay blocks: ${blockPG} / ${latestRPC} (${diff} block)
            END
            ${txsPG}        get latest transactions
            ${diff}         cal diff        ${latestRPC}    ${txsPG}
            IF  ${diff}>${diffError}
                push text to discord    ${channelID}    ${botToken}    :warning: Delay transactions: ${txsPG} / ${latestRPC} (${diff} block)
            END
            ${transferPG}   get latest token_transfers
            ${diff}         cal diff        ${latestRPC}    ${transferPG}
            IF  ${diff}>${diffError}
                push text to discord    ${channelID}    ${botToken}    :warning: Delay token transfers: ${transferPG} / ${latestRPC} (${diff} block)
            END
            ${balancePG}    get latest token_balances
            ${diff}         cal diff        ${latestRPC}    ${balancePG}
            IF  ${diff}>50
                push text to discord    ${channelID}    ${botToken}    :warning: Delay token balances: ${balancePG} / ${latestRPC} (${diff} block)
            END
            ${eventPG}      get latest event_logs
            ${diff}         cal diff        ${latestRPC}    ${eventPG}
            IF  ${diff}>${diffError}
                push text to discord    ${channelID}    ${botToken}    :warning: Delay event logs: ${eventPG} / ${latestRPC} (${diff} block)
            END
            Log To Console      - RPC: ${latestRPC}\n- Block: ${blockPG}\n- Txs: ${txsPG}\n- Transfer: ${transferPG}\n- Balance: ${balancePG}\n- Log: ${eventPG}
            Sleep    3s
        END
    END