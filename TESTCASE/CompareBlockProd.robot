*** Settings ***
Library         REST
Library         JSONLibrary
Library         DebugLibrary
Library         DatabaseLibrary
Library         String
Resource        ../RESOURCE/GlobalKey.robot

*** Keywords ***
get data block from es
    [Arguments]         ${blockNum}
    ${res}              REST.get     ${explorerProd}/block/${blockNum}
    set global variable  ${res}
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
    ${txs}              get value json and remove string   ${res}       $..transactions
    set global variable     ${txs}

get count txs of block from es
    [Arguments]         ${blockNum}
    ${res}              REST.get     ${explorerProd}/txs?block=${blockNum}
    set global variable  ${res}
    ${statusCode}           get value from json         ${res}              $..status
    ${statusCode}           get from list               ${statusCode}       0
	set global variable     ${statusCode}
    ${total}             get value json and remove string   ${res}       $..total
    set global variable     ${total}

dictionary for rpc call block
    [Arguments]         ${blockHex}
    ${rpcCall}          create dictionary       jsonrpc     2.0
    ${rpcCall}          set to dictionary       ${rpcCall}  method      eth_getBlockByNumber
    ${rpcCall}          set to dictionary       ${rpcCall}  params      ["0x${blockHex}",true]
    ${rpcCall}          set to dictionary       ${rpcCall}  id          1
    set global variable     ${rpcCall}

get data block from rpc
    [Arguments]         ${blockHex}
    dictionary for rpc call block       ${blockHex}
    ${res}              REST.post       ${prodRPC}        {"jsonrpc":"2.0","method":"eth_getBlockByNumber","params":["0x${blockHex}",false ],"id" :1}
    set global variable  ${res}
    ${statusCode}           get value from json         ${res}              $..status
    ${statusCode}           get from list               ${statusCode}       0
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

*** Test Cases ***
compare data
    ${fromNum}          set variable            8300000
    FOR     ${i}    IN RANGE    10000
        log to console      ${fromNum}
        get data block from es      ${fromNum}
        IF  ${statusCode}==200
            get count txs of block from es  ${fromNum}
            IF  ${statusCode}==200
                IF      ${total}!=${txs}
                    log to console      /block & /txs?block=========================>>${fromNum}
                END
                ${hexNum}           convert number to hex   ${fromNum}
                ${status}           run keyword and return status    get data block from rpc     ${hexNum}
                IF      ${status}==True
                    IF      ${hash}!=${hashRPC}
                        log to console      /block & /rpc=========================>>${fromNum}
                    END
                    ${fromNum}      evaluate        ${fromNum}+1
                END
            END
        END
    END