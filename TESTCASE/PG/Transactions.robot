*** Settings ***
Resource        ../../RESOURCE/Library.robot
Resource        ../../RESOURCE/GlobalKey.robot

*** Keywords ***
get total transaction from RPC
    ${res}              REST.post       ${internalRPC}
    ...                 {"jsonrpc":"2.0","method":"eth_getBlockTransactionCountByHash","params":["${blockHash}"],"id":1}     loglevel=INFO      timeout=3
    get status code from res    ${res}
    ${totalTxsRPC}      get value json and remove string    ${res}    $..result
    Set Global Variable    ${totalTxsRPC}

get total transaction from PG
    [Arguments]         ${block}
    ${totalTxsPG}       Query And Remove String    select count(*) from transactions where block_number=${block};
    Set Global Variable    ${totalTxsPG}
    ${blockHash}        Query And Remove String    select hash from blocks where "number"=${block};
    Set Global Variable    ${blockHash}

*** Test Cases ***
compare transations
    ${block}            Set Variable        9298523
    connect postgres prod
    FOR     ${i}        IN RANGE        10000
        get total transaction from PG     ${block}
        ${status}   run api and make sure success    get total transaction from RPC
        IF  ${status}==True
            ${totalTxsRPC}      convert hex to number    ${totalTxsRPC}
            IF  ${totalTxsRPC}!=${totalTxsPG}
                push text to discord    ${channelID}    ${botToken}
                            ...                     :notepad_spiral: ${block}: Event log PG (${totalTxsPG}) != Event log RPC (${totalTxsRPC})
            END
            Log To Console    ${block}::${totalTxsPG}::${totalTxsRPC}
            ${block}    Evaluate    ${block}-1
        END
    END