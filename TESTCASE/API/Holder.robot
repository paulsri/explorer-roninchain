*** Settings ***
Resource        ../../RESOURCE/Library.robot
Resource        ../../RESOURCE/GlobalKey.robot

*** Keywords ***
get balance balance from rpc
    [Arguments]     ${address}
    ${res}          REST.post   ${internalRPC}      {"jsonrpc":"2.0","method":"eth_call","params":[{"to":"0xa7964991f339668107e2b6a6f6b8e8b74aa9d017","data":"0x70a08231000000000000000000000000${address}"},"latest"],"id":1}
    ${ethCall}      get value json and remove string    ${res}      $..result
    ${ethCall}      convert hex to number    ${ethCall}
    Set Global Variable   ${ethCall}

*** Test Cases ***
quick count holder
    ${addrList}     Load JSON From File    ${filePath}
    ${index}        Set Variable        0
    ${count}        Set Variable        0
    FOR    ${i}     IN RANGE    300
        ${addr}     Get From List    ${addrList}    ${index}
        ${addr}     get value json and remove string    ${addr}    $..address
        ${addr}     Split String        ${addr}  0x
        ${addr}     Get From List       ${addr}  1
        ${status}   Run Keyword And Return Status    get balance balance from rpc  ${addr}
        IF  ${status}==True
            IF  ${ethCall}>0
                ${count}    Evaluate    ${count}+1
            ELSE
                Log To Console    ${addr}
            END
            ${index}    Evaluate    ${index}+1
        END
    END