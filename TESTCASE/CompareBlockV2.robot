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
    ${res}              REST.get     ${explorerStgV2}/block/${blockNum}
    set global variable  ${res}
    call api success
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

get data block from rpc
    [Arguments]         ${blockHex}
    dictionary for rpc call block       ${blockHex}
    ${res}              REST.post     ${internalRPC}        {"jsonrpc":"2.0","method":"eth_getBlockByNumber","params":["0x${blockHex}",false ],"id" :1}
    set global variable  ${res}
    call api success
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
    ${txsLength}        get length          ${txsRPC}
    ${txsLength}        evaluate            ${txsLength}/66
    set global variable     ${txsRPC}
    set global variable     ${txsLength}

*** Test Cases ***
compare block v2 with rpc
    ${fromNum}          set variable            8577800
    FOR     ${i}    IN RANGE    10000
        log to console      ${fromNum}
        get data block from es      ${fromNum}
        ${hexNum}           convert number to hex   ${fromNum}
        ${status}           run keyword and return status    get data block from rpc     ${hexNum}
        IF      ${status}==True
            should be equal     ${hash}             ${hashRPC}
            should be equal     ${parentHash}       ${parentHashRPC}
            should be equal     ${miner}            ${minerRPC}
            should be equal     ${txsRoot}          ${txsRootRPC}
            should be equal     ${stateRoot}        ${stateRootRPC}
            should be equal     ${receiptsRoot}     ${receiptsRootRPC}
            should be equal     ${timestamp}        ${timestampRPC}
            should be equal     ${gasLimit}         ${gasLimitRPC}
            should be equal     ${gasUsed}          ${gasUsedRPC}
            should be equal     ${size}             ${sizeRPC}
            should be equal as numbers     ${txs}              ${txsLength}
            ${fromNum}          evaluate            ${fromNum}+1
            sleep               1s
        END
    END