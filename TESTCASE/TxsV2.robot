*** Settings ***
Library         REST
Library         JSONLibrary
Library         DebugLibrary
Library         DatabaseLibrary
Library         String
Library         FakerLibrary
Resource        ../RESOURCE/GlobalKey.robot

*** Keywords ***
get txs from es by block
    [Arguments]         ${blockNum}
    ${res}              REST.get     ${explorerStgV2}/txs?block=${blockNum}&size=1
    set global variable  ${res}
    call api success
    ${timeES}           get value json and remove string   ${res}       $..seconds
    set global variable     ${timeES}
    ${totalTxsES}         Get Value From Json     ${res}      $..total
    ${totalTxsES}         Convert To List         ${totalTxsES}
    ${hashList}         Get Value From Json     ${res}      $..results..hash
    ${hashList}         Convert To List         ${hashList}
    Set Global Variable     ${hashList}
    ${length}           Get Length    ${hashList}
    Set Global Variable     ${length}
    ${blockHashES}      Get Value From Json    ${res}       $..block_hash
    set global variable     ${blockHashES}
    ${blockNumberES}   Get Value From Json   ${res}       $..block_number
    set global variable     ${blockNumberES}
    ${hashES}          Get Value From Json   ${res}       $..hash
    set global variable     ${hashES}
    ${gasES}           Get Value From Json   ${res}       $..gas
    set global variable     ${gasES}
    ${gasPriceES}      Get Value From Json   ${res}       $..gas_price
    set global variable     ${gasPriceES}
    ${fromES}          Get Value From Json   ${res}       $..from
    set global variable     ${fromES}
    ${toES}            Get Value From Json   ${res}       $..to
    set global variable     ${toES}
    ${txsIndexES}      Get Value From Json   ${res}       $..tx_index
    set global variable     ${txsIndexES}
    ${nonceES}         Get Value From Json   ${res}       $..nonce
    set global variable     ${nonceES}
    ${inputES}         Get Value From Json   ${res}       $..input
    set global variable     ${inputES}
    ${statusES}         Get Value From Json   ${res}       $..status
    set global variable     ${statusES}
    ${gasUsedES}        Get Value From Json   ${res}       $..gas_used
    set global variable     ${gasUsedES}
    ${cumulativeES}     Get Value From Json   ${res}       $..cumulative_gas_used
    set global variable     ${cumulativeES}


get detail txs from rpc by hash
    [Arguments]         ${hash}
    ${res}              REST.post     ${internalRPC}        {"jsonrpc":"2.0","method":"eth_getTransactionByHash","params":["${hash}"],"id" :1}
    set global variable  ${res}
    call api success
    ${timeRPC}          get value json and remove string   ${res}       $..seconds
    set global variable     ${timeRPC}
    ${blockHashRPC}     get value json and remove string   ${res}       $..result.blockHash
    set global variable     ${blockHashRPC}
    ${blockNumberRPC}   get value json and remove string   ${res}       $..result.blockNumber
    ${blockNumberRPC}   convert hex to number              ${blockNumberRPC}
    set global variable     ${blockNumberRPC}
    ${hashRPC}          get value json and remove string   ${res}       $..result.hash
    set global variable     ${hashRPC}
    ${gasRPC}           get value json and remove string   ${res}       $..result.gas
    ${gasRPC}           convert hex to number       ${gasRPC}
    set global variable     ${gasRPC}
    ${gasPriceRPC}      get value json and remove string   ${res}       $..result.gasPrice
    ${gasPriceRPC}      convert hex to number       ${gasPriceRPC}
    set global variable     ${gasPriceRPC}
    ${fromRPC}          get value json and remove string   ${res}       $..result.from
    set global variable     ${fromRPC}
    ${toRPC}            get value json and remove string   ${res}       $..result.to
    set global variable     ${toRPC}
    ${txsIndexRPC}      get value json and remove string   ${res}       $..result.transactionIndex
    ${txsIndexRPC}      convert hex to number       ${txsIndexRPC}
    set global variable     ${txsIndexRPC}
    ${nonceRPC}         get value json and remove string   ${res}       $..result.nonce
    ${nonceRPC}         convert hex to number       ${nonceRPC}
    set global variable     ${nonceRPC}
    ${inputRPC}         get value json and remove string   ${res}       $..result.input
    set global variable     ${inputRPC}

get receipt from rpc by hash
    [Arguments]         ${hash}
    ${res}              REST.post     ${internalRPC}        {"jsonrpc":"2.0","method":"eth_getTransactionReceipt","params":["${hash}"],"id" :1}
    set global variable  ${res}
    call api success
    ${statusRPC}           get value json and remove string   ${res}       $..result.status
    ${statusRPC}           convert hex to number              ${statusRPC}
    set global variable     ${statusRPC}
    ${gasUsedRPC}           get value json and remove string   ${res}       $..result.gasUsed
    ${gasUsedRPC}           convert hex to number              ${gasUsedRPC}
    set global variable     ${gasUsedRPC}
    ${cumulativeRPC}           get value json and remove string   ${res}       $..result.cumulativeGasUsed
    ${cumulativeRPC}           convert hex to number              ${cumulativeRPC}
    set global variable     ${cumulativeRPC}

get count txs of block from rpc
    [Arguments]         ${blockHash}
    ${res}              REST.post       {"jsonrpc":"2.0","method":"eth_getBlockByNumber","params":["${blockHash}"],"id" :1}
    ${totalTxsRPC}            get value json and remove string    ${res}      $..result
    ${totalTxsRPC}          convert hex to number       ${totalTxsRPC}
    set global variable     ${totalTxsRPC}

get from list & compare
    [Arguments]         ${list}     ${compareWith}      ${index}
    ${temp}             Get From List    ${list}     ${index}
    ${temp}             Convert To String    ${temp}
    ${compareWith}      Convert To String    ${compareWith}
    should be equal     ${temp}          ${compareWith}

#   get txs from es by address
#    /txs/:address
#    compare total with rpc

*** Test Cases ***
compare txs v2 with rpc
    ${fromNum}          set variable            8664151
    FOR     ${i}    IN RANGE    10000
        Log To Console                  ${fromNum}
        get txs from es by block        ${fromNum}
        FOR     ${i}        IN RANGE        ${length}
            ${hash}         Get From List    ${hashList}    ${i}
            ${status}       run keyword and return status   get detail txs from rpc by hash     ${hash}
            Set Global Variable             ${i}
            IF      ${status}==True
                Log To Console                  eth_getTransactionByHash: ${fromNum}::${i}::${hash}
                get from list & compare         ${blockHashES}          ${blockHashRPC}     ${i}
                get from list & compare         ${blockNumberES}        ${blockNumberRPC}   ${i}
                get from list & compare         ${hashES}               ${hashRPC}          ${i}
                get from list & compare         ${gasES}                ${gasRPC}           ${i}
                get from list & compare         ${gasPriceES}           ${gasPriceRPC}      ${i}
                get from list & compare         ${fromES}               ${fromRPC}          ${i}
                get from list & compare         ${fromES}               ${fromRPC}          ${i}
                get from list & compare         ${toES}                 ${toRPC}            ${i}
                get from list & compare         ${txsIndexES}           ${txsIndexRPC}      ${i}
                get from list & compare         ${nonceES}              ${nonceRPC}         ${i}
                get from list & compare         ${inputES}              ${inputRPC}         ${i}
            END
            ${status}       run keyword and return status   get receipt from rpc by hash        ${hash}
            IF      ${status}==True
                Log To Console                  eth_getTransactionReceipt: ${fromNum}::${i}::${hash}
                ${statusIndex}                  evaluate                ${i}+1
                get from list & compare         ${statusES}             ${statusRPC}        ${statusIndex}
                get from list & compare         ${gasUsedES}            ${gasUsedRPC}       ${i}
                get from list & compare         ${cumulativeES}         ${cumulativeRPC}    ${i}
            END
        END
        ${status}       run keyword and return status   get count txs of block from rpc     ${blockHashES}
        IF      ${status}==True
            Should Be Equal    ${totalTxsES}    ${totalTxsRPC}
        END
        ${random}       Random Int      1       1
        ${fromNum}      Evaluate    ${fromNum}+${random}
        sleep           2s
    END