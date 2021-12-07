*** Settings ***
Resource        ../../RESOURCE/Library.robot
Resource        ../../RESOURCE/GlobalKey.robot
Resource        ../../TESTCASE/API/Block.robot
Resource        ../../TESTCASE/API/TokenBanalance.robot
Resource        ../../TESTCASE/API/Transaction&Logs.robot

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

realtime checker
    ${status}               run keyword and return status    get latest block from rpc
        IF      ${status}==True
            ${latestES}             get latest block from es
            Set Global Variable     ${latestES}
            IF  ${statusCode}==200
                ${diff}                 Evaluate    ${latestRPC}-${latestES}
                IF      ${diff}>10
                    push text to discord    ${channelID}    ${botToken}
                    ...                     :warning: Block ES (${latestES}) delay ${diff} blocks with RPC (${latestRPC})
                END
            END
            ${latestTxs}            get latest txs from es
            IF  ${statusCode}==200
                ${diff}                 Evaluate    ${latestRPC}-${latestES}
                IF      ${diff}>10
                    push text to discord    ${channelID}    ${botToken}
                    ...                     :warning: Transaction ES (${latestTxs}) delay ${diff} blocks with RPC (${latestRPC})
                END
            END
            ${latestTransfer}       get latest token transfer from es
            IF  ${statusCode}==200
                ${diff}                 Evaluate    ${latestRPC}-${latestTransfer}
                IF      ${diff}>20
                    push text to discord    ${channelID}    ${botToken}
                    ...                     :warning: Token transfer ES (${latestTransfer}) delay ${diff} blocks with RPC (${latestRPC})
                END
            END
        END

*** Test Cases ***
real time checker
    FOR     ${i}    IN RANGE    10000
        Run Keyword And Continue On Failure     realtime checker
        Run Keyword And Continue On Failure     block checker           ${latestES}
        Run Keyword And Continue On Failure     token balance checker
        Run Keyword And Continue On Failure     txs and log checker     ${latestES}
        Sleep    300s
    END