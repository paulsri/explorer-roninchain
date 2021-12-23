*** Settings ***
Resource        ../../RESOURCE/Library.robot
Resource        ../../RESOURCE/GlobalKey.robot

*** Keywords ***
get data block from es
    [Arguments]         ${blockNum}
    ${res}              REST.get     ${explorer}/block/${blockNum}      loglevel=INFO       timeout=2.5
    set global variable  ${res}
    ${timeES}           get value json and remove string   ${res}       $..seconds
    set global variable     ${timeES}
    ${statusCode}           get value from json         ${res}              $..status
    ${statusCode}           get from list               ${statusCode}       0
	set global variable     ${statusCode}
	${hash}             get value json and remove string   ${res}       $..hash
    set global variable     ${hash}
    ${parentHash}       get value json and remove string   ${res}       $..parent_hash
    set global variable     ${parentHash}
    ${miner}            get value json and remove string   ${res}       $..miner
    set global variable     ${miner}
    ${txsRoot}          get value json and remove string   ${res}       $..transaction_root
    set global variable     ${txsRoot}
    ${stateRoot}        get value json and remove string   ${res}       $..state_root
    set global variable     ${stateRoot}
    ${receiptsRoot}     get value json and remove string   ${res}       $..receipts_root
    set global variable     ${receiptsRoot}
    ${timestamp}        get value json and remove string   ${res}       $..timestamp
    set global variable     ${timestamp}
    ${gasLimit}         get value json and remove string   ${res}       $..gas_limit
    set global variable     ${gasLimit}
    ${gasUsed}          get value json and remove string   ${res}       $..gas_used
    set global variable     ${gasUsed}
    ${size}             get value json and remove string   ${res}       $..size
    set global variable     ${size}
    ${txsBlock}         get value json and remove string   ${res}       $..transactions
    set global variable     ${txsBlock}

get data block from rpc
    [Arguments]         ${blockHex}
    ${res}              REST.post       ${internalRPC}
    ...                 {"jsonrpc":"2.0","method":"eth_getBlockByNumber","params":["0x${blockHex}",false ],"id" :1}     loglevel=INFO       timeout=2.5
    set global variable  ${res}
    ${timeRPC}          get value json and remove string   ${res}       $..seconds
    set global variable     ${timeRPC}
    ${statusCode}       get value from json                ${res}              $..status
    ${statusCode}       get from list                      ${statusCode}       0
	set global variable     ${statusCode}
    ${hashRPC}          get value json and remove string   ${res}       $..result.hash
    set global variable     ${hashRPC}
    ${parentHashRPC}    get value json and remove string   ${res}       $..result.parentHash
    set global variable     ${parentHashRPC}
    ${minerRPC}         get value json and remove string   ${res}       $..result.miner
    set global variable     ${minerRPC}
    ${txsRootRPC}       get value json and remove string   ${res}       $..result.transactionsRoot
    set global variable     ${txsRootRPC}
    ${stateRootRPC}     get value json and remove string   ${res}       $..result.stateRoot
    set global variable     ${stateRootRPC}
    ${receiptsRootRPC}  get value json and remove string   ${res}       $..result.receiptsRoot
    set global variable     ${receiptsRootRPC}
    ${timestampRPC}     get value json and remove string   ${res}       $..result.timestamp
    ${timestampRPC}     convert hex to number       ${timestampRPC}
    set global variable     ${timestampRPC}
    ${gasLimitRPC}      get value json and remove string   ${res}       $..result.gasLimit
    ${gasLimitRPC}      convert hex to number       ${gasLimitRPC}
    set global variable     ${gasLimitRPC}
    ${gasUsedRPC}       get value json and remove string   ${res}       $..result.gasUsed
    ${gasUsedRPC}       convert hex to number       ${gasUsedRPC}
    set global variable     ${gasUsedRPC}
    ${sizeRPC}          get value json and remove string   ${res}       $..result.size
    ${sizeRPC}          convert hex to number       ${sizeRPC}
    set global variable     ${sizeRPC}
    ${txsRPC}           get value json and remove string   ${res}       $..result.transactions
    ${txsRPC}           get length          ${txsRPC}
    ${txsRPC}           evaluate            ${txsRPC}/66
    set global variable     ${txsRPC}

get count txs of block from es
    [Arguments]             ${blockNum}
    ${res}                  REST.get     ${explorer}/txs?block=${blockNum}      loglevel=INFO       timeout=2.5
    set global variable     ${res}
    ${statusCode}           get value from json         ${res}              $..status
    ${statusCode}           get from list               ${statusCode}       0
	set global variable     ${statusCode}
    ${totalES}              get value json and remove string   ${res}       $..total
    set global variable     ${totalES}

block checker
    ${status}           run keyword and return status       get data block from es      ${fromNum}
    IF  ${status}==True
        IF      ${statusCode}==200
            ${status}           run keyword and return status       get count txs of block from es  ${fromNum}
            IF  ${status}==True
                IF  ${statusCode}==200
                    ${hexNum}           convert number to hex   ${fromNum}
                    ${status}           run keyword and return status    get data block from rpc     ${hexNum}
                    IF      ${status}==True
                        Log To Console          ${fromNum}::${txsRPC}==${totalES}?
                        ${ran}              Random Int  1     1
                        ${fromNum}          Evaluate    ${fromNum}+${ran}
                        Set Global Variable     ${fromNum}
                        IF      ${hashRPC}!=${hash}
                            push text to discord    ${channelID}    ${botToken}
                            ...                     :package: Hash RPC (${hashRPC}) != Hash ES (${hash}): ${fromNum}
                        END
                        IF      ${txsRPC}!=${totalES}
                            push text to discord    ${channelID}    ${botToken}
                            ...                     :package: Total txs RPC (${txsRPC}) != Total txs ES (${totalES}): ${fromNum}
                        END
                    END
                END
            END
        END
    END

*** Test Cases ***
quick test
    ${fromNum}      Set Variable        9549700
    Set Global Variable    ${fromNum}
    FOR     ${i}        IN RANGE    10000
        block checker
    END