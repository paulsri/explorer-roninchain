*** Settings ***
Resource        ../../RESOURCE/Library.robot
Resource        ../../RESOURCE/GlobalKey.robot
#Resource        ../../TESTCASE/API/Block.robot
#Resource        ../../TESTCASE/API/TokenBanalance.robot
#Resource        ../../TESTCASE/API/Transaction.robot

*** Keywords ***
get latest block from rpc
    ${res}                  REST.post       ${internalRPC}      {"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id" :1}    loglevel=INFO        timeout=3
    ${latestRPC}            get value json and remove string    ${res}       $..result
    ${latestRPC}            convert hex to number               ${latestRPC}
    Set Global Variable     ${latestRPC}

get status pg
    ${res}                  REST.get     ${explorer}/status                 loglevel=INFO       timeout=3
    get status code from res    ${res}
    ${latestBlockES}        get value json and remove string                ${res}              $..block
    ${latestTransactionES}  get value json and remove string                ${res}              $..transaction
    ${latestTransferES}     get value json and remove string                ${res}              $..transfer
    ${latestBalanceES}      get value json and remove string                ${res}              $..balance

get latest block from es
    ${res}                  REST.get     ${explorer}/blocks?size=1          loglevel=INFO       timeout=3
    get status code from res    ${res}
    ${latestBlockES}        get value json and remove string   ${res}       $..number
    Set Global Variable     ${latestBlockES}

get latest block from pg
    ${res}                  REST.get     ${explorer}/blocks/latest          loglevel=INFO       timeout=3
    get status code from res    ${res}
    ${latestBlockPG}        get value json and remove string   ${res}       $..number
    Set Global Variable     ${latestBlockPG}

get latest txs from es
    ${res}                  REST.get     ${explorer}/txs?size=1             loglevel=INFO       timeout=3
    get status code from res    ${res}
    ${number}               Get Value From Json    ${res}       $..results..block_number
    ${number}               Get From List    ${number}    0
    [Return]                ${number}

get latest token transfer from es
    ${res}                  REST.get     ${explorer}/tokentxs?size=1        loglevel=INFO       timeout=3
    get status code from res    ${res}
    ${number}               get value json and remove string   ${res}       $..results..block_number
    [Return]                ${number}

realtime checker
    ${status}               run keyword and return status    get latest block from rpc
    ${count500Error}        Set Variable        0
    IF      ${status}==True
        get latest block from es
        IF  ${statusCode}==200
            ${diff}                 Evaluate    ${latestRPC}-${latestBlockES}
            IF      ${diff}>10
                push text to discord    ${channelID}    ${botToken}
                ...                     :alarm_clock: Block ES (${latestBlockES}) delay ${diff} blocks with RPC (${latestRPC})
            END
        ELSE
                ${count500Error}    Evaluate    ${count500Error}+1
        END
        ${latestTxs}            get latest txs from es
        IF  ${statusCode}==200
            ${diff}                 Evaluate    ${latestRPC}-${latestES}
            IF      ${diff}>10
                push text to discord    ${channelID}    ${botToken}
                ...                     :alarm_clock: Transaction ES (${latestTxs}) delay ${diff} blocks with RPC (${latestRPC})
            END
        ELSE
                ${count500Error}    Evaluate    ${count500Error}+1
        END
        ${latestTransfer}       get latest token transfer from es
        IF  ${statusCode}==200
            ${diff}                 Evaluate    ${latestRPC}-${latestTransfer}
            IF      ${diff}>15
                push text to discord    ${channelID}    ${botToken}
                ...                     :alarm_clock: Token transfer ES (${latestTransfer}) delay ${diff} blocks with RPC (${latestRPC})
            END
        ELSE
                ${count500Error}    Evaluate    ${count500Error}+1
        END
    ELSE
                push text to discord    ${channelID}    ${botToken}     :alarm_clock: Realtime checker: RPC api got 500 error
    END
    IF      ${count500Error}>1
        push text to discord    ${channelID}    ${botToken}     :alarm_clock: Realtime checker: ES api got 500 error ${count500Error}/3 times
    END

realtime block checker
    FOR     ${i}    IN RANGE        100
        ${status}               run keyword and return status    get latest block from rpc
        IF      ${status}==True
            ${status}               run keyword and return status    get latest block from es
            IF  ${status}==True
                IF  ${statusCode}==200
                    ${status}               run keyword and return status    get latest block from pg
                    IF      ${status}==True
                        IF  ${statusCode}==200
                            ${diff}                 Evaluate    ${latestRPC}-${latestBlockES}
                            IF      ${diff}>2
                                push text to discord    ${channelID}    ${botToken}
                                ...                     :package: Block ES (${latestBlockES}) delay ${diff} blocks with RPC (${latestRPC}). Block PG = ${latestBlockPG}
                            END
                        Log To Console      ${latestRPC}::${latestBlockPG}::${latestBlockES}
                        Exit For Loop
                        END
                    END
                END
            END
        END
    END