*** Settings ***
Resource        ../../RESOURCE/Library.robot
Resource        ../../RESOURCE/GlobalKey.robot

*** Keywords ***
get txs from es by block
    [Arguments]         ${blockNum}
    ${res}              REST.get     ${explorer}/txs?block=${blockNum}&size=1     loglevel=INFO     timeout=3
    set global variable  ${res}
    call api success
    ${statusCode}           get value from json         ${res}              $..status
    ${statusCode}           get from list               ${statusCode}       0
	set global variable     ${statusCode}
    ${timeES}           get value json and remove string   ${res}       $..seconds
    set global variable     ${timeES}
    ${totalTxsES}       Get Value From Json     ${res}      $..total
    ${totalTxsES}       Convert To List         ${totalTxsES}
    ${hashList}         Get Value From Json     ${res}      $..results..hash
    ${hashList}         Convert To List         ${hashList}
    Set Global Variable     ${hashList}
    ${length}           Get Length    ${hashList}
    Set Global Variable     ${length}
    ${blockHashES}      Get Value From Json    ${res}       $..block_hash
    set global variable     ${blockHashES}
    ${blockNumberES}    Get Value From Json   ${res}        $..block_number
    set global variable     ${blockNumberES}
    ${hashES}           Get Value From Json   ${res}        $..hash
    set global variable     ${hashES}
    ${gasES}            Get Value From Json   ${res}        $..gas
    set global variable     ${gasES}
    ${gasPriceES}       Get Value From Json   ${res}        $..gas_price
    set global variable     ${gasPriceES}
    ${fromES}           Get Value From Json   ${res}        $..from
    set global variable     ${fromES}
    ${toES}             Get Value From Json   ${res}        $..to
    set global variable     ${toES}
    ${txsIndexES}       Get Value From Json   ${res}        $..tx_index
    set global variable     ${txsIndexES}
    ${nonceES}          Get Value From Json   ${res}        $..nonce
    set global variable     ${nonceES}
    ${inputES}          Get Value From Json   ${res}        $..input
    set global variable     ${inputES}
    ${statusES}         Get Value From Json   ${res}        $..status
    set global variable     ${statusES}
    ${gasUsedES}        Get Value From Json   ${res}        $..gas_used
    set global variable     ${gasUsedES}
    ${cumulativeES}     Get Value From Json   ${res}        $..cumulative_gas_used
    set global variable     ${cumulativeES}

get log txs from es by hash
    [Arguments]         ${hash}
    ${res}              REST.get     ${explorer}/tx/${hash}     loglevel=INFO
    set global variable     ${res}
    ${statusCode}           get value from json         ${res}              $..status
    ${statusCode}           get from list               ${statusCode}       0
	set global variable     ${statusCode}
    ${timeES}           get value json and remove string   ${res}       $..seconds
    set global variable     ${timeES}
    ${logAddressES}     get value json and remove string   ${res}       $..address
    set global variable     ${logAddressES}
    ${dataES}           get value json and remove string   ${res}       $..data
    set global variable     ${dataES}
    ${topicsES}         get value json and remove string   ${res}       $..topics
    set global variable     ${topicsES}

get txs from rpc by hash
    [Arguments]         ${hash}
    ${res}              REST.post     ${internalRPC}        {"jsonrpc":"2.0","method":"eth_getTransactionByHash","params":["${hash}"],"id" :1}     timeout=3
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

get log from rpc by hash
    [Arguments]         ${hash}
    ${res}              REST.post     ${internalRPC}        {"jsonrpc":"2.0","method":"eth_getTransactionReceipt","params":["${hash}"],"id" :1}     timeout=3
    set global variable  ${res}
    call api success
    ${timeRPC}          get value json and remove string   ${res}           $..seconds
    set global variable     ${timeRPC}
    ${statusRPC}        get value json and remove string   ${res}           $..result.status
    ${statusRPC}        convert hex to number              ${statusRPC}
    set global variable     ${statusRPC}
    ${gasUsedRPC}       get value json and remove string   ${res}           $..result.gasUsed
    ${gasUsedRPC}       convert hex to number              ${gasUsedRPC}
    set global variable     ${gasUsedRPC}
    ${cumulativeRPC}    get value json and remove string   ${res}           $..result.cumulativeGasUsed
    ${cumulativeRPC}    convert hex to number              ${cumulativeRPC}
    set global variable     ${cumulativeRPC}
    ${logAddressRPC}    get value json and remove string   ${res}           $..result..address
    set global variable     ${logAddressRPC}
    ${dataRPC}          get value json and remove string   ${res}           $..data
    ${dataRPC}          Split String                       ${dataRPC}       0x
    ${dataRPC}          Convert To String                  ${dataRPC}
    ${dataRPC}          Remove String                      ${dataRPC}       [   '   '   ]   ,   ${space}
    set global variable     ${dataRPC}
    ${topicsRPC}        get value json and remove string   ${res}           $..topics
    set global variable     ${topicsRPC}

get from list & compare
    [Arguments]         ${list}     ${compareWith}      ${index}
    ${temp}             Get From List    ${list}     ${index}
    ${temp}             Convert To String    ${temp}
    ${compareWith}      Convert To String    ${compareWith}
    should be equal     ${temp}          ${compareWith}

txs and log checker
    [Arguments]         ${fromNum}
    ${status}       run keyword and return status   get txs from es by block        ${fromNum}
    IF        ${status}==True
        IF      ${statusCode}==200
            FOR     ${i}        IN RANGE        ${length}
                ${hash}         Get From List    ${hashList}    ${i}
                ${status}       run keyword and return status   get txs from rpc by hash     ${hash}
                Set Global Variable             ${i}
                IF      ${status}==True
                    ${hashES}       Get From List           ${hashES}     ${i}
                    ${hashES}       Convert To String       ${hashES}
                    Set Global Variable    ${hashES}
                    ${hashRPC}      Convert To String       ${hashRPC}
                    Set Global Variable    ${hashRPC}
                    IF  ${hashES}!=${hashRPC}
                        push text to discord    ${channelID}    ${botToken}
                        ...                     :scroll: Transaction hash ES (${hashES}) != transaction hash RPC (${hashRPC})
                    END
                    ${status}       run keyword and return status   get log from rpc by hash        ${hash}
                    IF      ${status}==True
                        ${status}       run keyword and return status   get log txs from es by hash  ${hash}
                        IF      ${status}==True
                            IF      ${statusCode}==200
                                ${verify}   run keyword and return status       Should Be Equal    ${dataES}    ${dataRPC}
                                IF  ${verify}!=True
                                    push text to discord    ${channelID}    ${botToken}
                                    ...                     :scroll: ${fromNum}: Log event PG != log event RPC (${hash})
                                END
                                Log To Console          ${fromNum}::${hashES}==${hashRPC}?
                                ${ran}              Random Int  333     999
                                ${fromNum}          Evaluate    ${fromNum}-${ran}
                                Set Global Variable     ${fromNum}
                            END
                        END
                    END
                END
            END
        END
    END

*** Test Cases ***
quick test
    ${fromNum}      Set Variable        9318125
    Set Global Variable    ${fromNum}
    FOR     ${i}        IN RANGE    10000
        txs and log checker     ${fromNum}
    END