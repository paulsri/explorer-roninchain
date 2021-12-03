*** Settings ***
Library         REST
Library         JSONLibrary
Library         DebugLibrary
Library         DatabaseLibrary
Library         FakerLibrary
Library         String
Resource        C:/Users/tongh/PycharmProjects/explorer-roninchain/RESOURCE/GlobalKey.robot
Resource        C:/Users/tongh/PycharmProjects/explorer-roninchain/TESTCASE/API/Block.robot
Resource        C:/Users/tongh/PycharmProjects/explorer-roninchain/TESTCASE/API/TokenBanalance.robot
Resource        C:/Users/tongh/PycharmProjects/explorer-roninchain/TESTCASE/API/Transaction&Logs.robot

*** Keywords ***
get latest block from rpc
    ${res}                  REST.post       ${internalRPC}      {"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id" :1}
    ${latestRPC}            get value json and remove string    ${res}       $..result
    ${latestRPC}            convert hex to number               ${latestRPC}
    Set Global Variable     ${latestRPC}

get latest block from es
    ${res}                  REST.get     ${explorer}/blocks?size=1
    set global variable     ${res}
    ${statusCode}           get value from json         ${res}              $..status
    ${statusCode}           get from list               ${statusCode}       0
	set global variable     ${statusCode}
    ${number}               get value json and remove string   ${res}       $..number
    [Return]                ${number}

get latest txs from es
    ${res}                  REST.get     ${explorer}/txs?size=1
    set global variable     ${res}
    ${statusCode}           get value from json         ${res}              $..status
    ${statusCode}           get from list               ${statusCode}       0
	set global variable     ${statusCode}
    ${number}               Get Value From Json    ${res}       $..results..block_number
    ${number}               Get From List    ${number}    0
    [Return]                ${number}

get latest token transfer from es
    ${res}                  REST.get     ${explorer}/tokentxs?size=1
    set global variable     ${res}
    ${statusCode}           get value from json         ${res}              $..status
    ${statusCode}           get from list               ${statusCode}       0
	set global variable     ${statusCode}
    ${number}               get value json and remove string   ${res}       $..results..block_number
    [Return]                ${number}

*** Test Cases ***
real time checker
    FOR     ${i}    IN RANGE    10000
    #   Verify delay block
        ${status}               run keyword and return status    get latest block from rpc
        IF      ${status}==True
            ${latestES}             get latest block from es
            IF  ${statusCode}==200
                ${diff}                 Evaluate    ${latestRPC}-${latestES}
                IF      ${diff}>10
                    push text to discord    ${channelID}    ${botToken}      **[WARNING]** Block ES (${latestES}) delay ${diff} blocks with RPC (${latestRPC})
                END
            END
            ${latestTxs}            get latest txs from es
            IF  ${statusCode}==200
                ${diff}                 Evaluate    ${latestRPC}-${latestES}
                IF      ${diff}>10
                    push text to discord    ${channelID}    ${botToken}      **[WARNING]** Transaction ES (${latestTxs}) delay ${diff} blocks with RPC (${latestRPC})
                END
            END
            ${latestTransfer}       get latest token transfer from es
            IF  ${statusCode}==200
                ${diff}                 Evaluate    ${latestRPC}-${latestTransfer}
                IF      ${diff}>20
                    push text to discord    ${channelID}    ${botToken}      **[WARNING]** Token transfer ES (${latestTransfer}) delay ${diff} blocks with RPC (${latestRPC})
                END
            END
        END
    #   Verify block data
        ${fromNum}              Evaluate       ${latestES}-10
        get data block from es      ${fromNum}
        IF  ${statusCode}==200
            get count txs of block from es  ${fromNum}
            IF  ${statusCode}==200
                ${hexNum}           convert number to hex   ${fromNum}
                ${status}           run keyword and return status    get data block from rpc     ${hexNum}
                IF      ${status}==True
                    IF      ${hashRPC}!=${hash}
                        ${errorText}        Set Variable        **[ERROR]** Hash RPC (${hashRPC}) != Hash ES (${hash}): ${fromNum}
                        push text to discord    ${channelID}    ${botToken}    ${errorText}
                    END
                    IF      ${txsRPC}!=${totalES}
                        ${errorText}        Set Variable        **[ERROR]** Total txs RPC (${txsRPC}) != Total txs ES (${totalES}): ${fromNum}
                        push text to discord    ${channelID}    ${botToken}    ${errorText}
                    END
                    ${random}       Random Int      1       1
                    ${fromNum}      evaluate        ${fromNum}-${random}
                END
            END
        END
    #   Verify token balance
        ${listAddress}          get latest address change from es
        ${random}               Get From List       ${listAddress}       10
        ${random}               Remove String       ${random}       0x
        ${status}       run keyword and return status    get ron balance from rpc       0x${random}
        IF      ${status}==True
            ${ronBalanceES}     get ron balance from es    0x${random}
            IF      ${ronBalanceRPC}!=${ronBalanceES}
                push text to discord    ${channelID}    ${botToken}    **[ERROR]** RON balance wrong: 0x${random}. Should be equal ${ronBalanceRPC}
            END
        END
        Sleep    1s
        ${status}       run keyword and return status    get token balance from rpc        ${axs}      ${random}
        IF      ${status}==True
            ${esCall}    get token balance by address from es    0x${random}    ${axs}
            IF      ${ethCall}!=${esCall}
                push text to discord    ${channelID}    ${botToken}    **[ERROR]** AXS balance wrong: 0x${random}. Should be equal ${ethCall}
            END
        END
        Sleep    1s
        ${status}       run keyword and return status    get token balance from rpc        ${slp}      ${random}
        IF      ${status}==True
            ${esCall}    get token balance by address from es    0x${random}    ${slp}
            IF      ${ethCall}!=${esCall}
                push text to discord    ${channelID}    ${botToken}    **[ERROR]** SLP balance wrong: 0x${random}. Should be equal ${ethCall}
            END
        END
        Sleep    1s
        ${status}       run keyword and return status    get token balance from rpc        ${weth}      ${random}
        IF      ${status}==True
            ${esCall}    get token balance by address from es    0x${random}    ${weth}
            IF      ${ethCall}!=${esCall}
                push text to discord    ${channelID}    ${botToken}    **[ERROR]** WETH balance wrong: 0x${random}. Should be equal ${ethCall}
            END
        END
        Sleep    1s
        ${status}       run keyword and return status    get token balance from rpc        ${usdc}   ${random}
        IF      ${status}==True
            ${esCall}    get token balance by address from es    0x${random}    ${usdc}
            IF      ${ethCall}!=${esCall}
                push text to discord    ${channelID}    ${botToken}    **[ERROR]** USDC balance wrong: 0x${random}. Should be equal ${ethCall}
            END
        END
        Sleep    1s
        ${status}       run keyword and return status    get token balance from rpc        ${axie}   ${random}
        IF      ${status}==True
            ${esCall}    get token balance by address from es    0x${random}    ${axie}
            IF      ${ethCall}!=${esCall}
                push text to discord    ${channelID}    ${botToken}    **[ERROR]** AXIE balance wrong: 0x${random}. Should be equal ${ethCall}
            END
        END
    #   Verify transaction & log
        get txs from es by block        ${fromNum}
        IF      ${statusCode}==200
            FOR     ${i}        IN RANGE        ${length}
                ${hash}         Get From List    ${hashList}    ${i}
                ${status}       run keyword and return status   get txs from rpc by hash     ${hash}
                Set Global Variable             ${i}
                IF      ${status}==True
                    ${hashES}       Get From List           ${hashES}     ${i}
                    ${hashES}       Convert To String       ${hashES}
                    ${hashRPC}      Convert To String       ${hashRPC}
                    IF  ${hashES}!=${hashRPC}
                        push text to discord    ${channelID}    ${botToken}    **[ERROR]** Transaction hash ES (${hashES}) != transaction hash RPC (${hashRPC})
                    END
                END
                ${status}       run keyword and return status   get log from rpc by hash        ${hash}
                IF      ${status}==True
                    get log txs from es by hash  ${hash}
                    IF      ${statusCode}==200
                        ${status}   run keyword and return status       Should Be Equal    ${dataES}    ${dataRPC}
                        IF  ${status}!=True
                            push text to discord    ${channelID}    ${botToken}         **[ERROR]** Log event ES != log event RPC (${hash})
                        END
                    END
                END
            END
        END
        Sleep    60s
        Log To Console    LOOP::${i}/10000
    END