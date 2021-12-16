*** Settings ***
Resource        ../../RESOURCE/Library.robot
Resource        ../../RESOURCE/GlobalKey.robot

*** Keywords ***
get latest block from rpc
    ${res}                  REST.post       ${internalRPC}      {"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id" :1}    loglevel=INFO        timeout=3
    ${latestRPC}            get value json and remove string    ${res}       $..result
    ${latestRPC}            convert hex to number               ${latestRPC}
    Set Global Variable     ${latestRPC}

get latest block from es
    ${res}                  REST.get     ${explorer}/blocks?size=1          loglevel=INFO       timeout=3
    get status code from res    ${res}
    ${latestBlockES}        get value json and remove string   ${res}       $..number
    Set Global Variable     ${latestBlockES}

get latest txs from es
    ${res}                  REST.get     ${explorer}/txs?size=1             loglevel=INFO       timeout=3
    get status code from res    ${res}
    ${latestTxsES}          Get Value From Json    ${res}       $..results..block_number
    ${latestTxsES}          Get From List    ${latestTxsES}    0
    Set Global Variable     ${latestTxsES}

get latest token transfer from es
    ${res}                  REST.get     ${explorer}/tokentxs?size=1        loglevel=INFO       timeout=3
    get status code from res    ${res}
    ${latestTransferES}     get value json and remove string   ${res}       $..results..block_number
    Set Global Variable     ${latestTransferES}

get token balance from es
    ${changeCount}          Set Variable        0
    ${latestBalBefore}      Load JSON From File     ${EXECDIR}/RESOURCE/WhaleBalance.json
    ${res}                  REST.get     ${explorer}/tokenbalances/0xb32e9a84ae0b55b8ab715e4ac793a61b277bafa3        loglevel=INFO       timeout=10
    ${tokenAddr}            Get Value From Json    ${res}    $..results..token_address
    ${length}               Get Length    ${tokenAddr}
    FOR         ${i}        IN RANGE    ${length}
        ${token}            get value json and remove string    ${res}       $..results[${i}]..token_symbol
        ${balance}          get value json and remove string    ${res}       $..results[${i}]..balance
        ${balance}          Convert To Integer    ${balance}
        ${oldBalance}       get value json and remove string    ${latestBalBefore}       $..${token}
        ${latestBalBefore}  update value to json        ${latestBalBefore}     $..${token}       ${balance}
        IF  ${balance}!=${oldBalance}
            ${changeCount}   Evaluate    ${changeCount}+1
        END
    END
    ${latestBalBefore}      Convert To String    ${latestBalBefore}
    ${latestBalBefore}      Replace String    ${latestBalBefore}    '    "
    Create File             ${EXECDIR}/RESOURCE/WhaleBalance.json   ${latestBalBefore}  UTF-8
    Set Global Variable     ${changeCount}

realtime checker
    ${status}               run keyword and return status    get latest block from rpc
    ${diffError}            Set Variable    3
    ${count500Error}        Set Variable        0
    IF      ${status}==True
        ${status}           run api and make sure success    get latest block from es
        IF  ${status}==True
            ${diff}                 Evaluate    ${latestRPC}-${latestBlockES}
            IF      ${diff}>${diffError}
                push text to discord    ${channelID}    ${botToken}
                ...                     :package: Block ES (${latestBlockES}) delay ${diff} blocks with RPC (${latestRPC})
            END
        ELSE
                ${count500Error}    Evaluate    ${count500Error}+1
        END
        ${status}           run api and make sure success    get latest txs from es
        IF  ${status}==True
            ${diff}                 Evaluate    ${latestRPC}-${latestTxsES}
            IF      ${diff}>${diffError}
                push text to discord    ${channelID}    ${botToken}
                ...                     ::scroll: Transaction ES (${latestTxsES}) delay ${diff} blocks with RPC (${latestRPC})
            END
        ELSE
                ${count500Error}    Evaluate    ${count500Error}+1
        END
        ${status}           run api and make sure success    get latest token transfer from es
        IF  ${status}==True
            ${diff}                 Evaluate    ${latestRPC}-${latestTransferES}
            IF      ${diff}>${diffError}
                push text to discord    ${channelID}    ${botToken}
                ...                     :notepad_spiral: Token transfer ES (${latestTransferES}) delay ${diff} blocks with RPC (${latestRPC})
            END
        ELSE
                ${count500Error}    Evaluate    ${count500Error}+1
        END
        ${status}           run api and make sure success    get token balance from es
        IF  ${status}==True
            IF  ${changeCount}<1
                push text to discord    ${channelID}    ${botToken}
                ...                     :moneybag: Token balance ES don't update: 0xb32e9a84ae0b55b8ab715e4ac793a61b277bafa3
            END
        ELSE
                ${count500Error}    Evaluate    ${count500Error}+1
        END
    END
    IF      ${count500Error}>1
        push text to discord    ${channelID}    ${botToken}     :alarm_clock: Realtime checker: ES api got exception ${count500Error}/3 times
    END

*** Test Cases ***
realtime checker
    realtime checker