*** Settings ***
Resource        ../../RESOURCE/Library.robot
Resource        ../../RESOURCE/GlobalKey.robot

*** Keywords ***
get token balance from RPC
    ${res}          REST.post   ${internalRPC}
    ...     {"jsonrpc":"2.0","method":"eth_call","params":[{"to":"${tokenAddr}","data":"0x70a08231000000000000000000000000${address}"},"latest"],"id":1}
    get status code from res    ${res}
    ${tokenBalanceRPC}      get value json and remove string    ${res}    $..result
    ${tokenBalanceRPC}      convert hex to number    ${tokenBalanceRPC}
    Set Global Variable     ${tokenBalanceRPC}

get latest block confirmed
    ${data}             Query And Remove String    select "number" from blocks where confirmed=true order by "number" desc limit 1;
    [Return]            ${data}

get address list in latest block confirmed PG
    [Arguments]         ${block}
    ${addrList}         Query                       select distinct "to",token_address from token_transfers where block_number=${block};
    [Return]            ${addrList}

get token balance from PG
    [Arguments]         ${address}      ${tokenAddress}
    ${tokenBalancePG}       Query And Remove String    select balance from token_balances where address='${address}' and token_address='${tokenAddress}';
    [Return]            ${tokenBalancePG}

*** Test Cases ***
compare token balance
    connect postgres prod
    FOR     ${i}        IN RANGE        1000
        ${latestBlock}      get latest block confirmed
        ${addrList}         get address list in latest block confirmed PG    ${latestBlock}
        Log To Console      ${addrList}
        ${length}           Get Length      ${addrList}
        IF  ${length}>0
            IF  ${length}>3
                ${length}   Set Variable    3
            END
            FOR     ${i}    IN RANGE    ${length}
                ${row}          Get From List       ${addrList}     ${i}
                ${address}      Get From List       ${row}          0
                ${tokenAddr}    Get From List       ${row}          1
                ${whiteList}    validate whitelist    ${address}
                IF  ${whiteList}!=True
                    ${tokenBalancePG}   get token balance from PG   ${address}      ${tokenAddr}
                    ${address}      Split String        ${address}  0x
                    ${address}      Get From List       ${address}  1
                    Set Global Variable    ${address}
                    Set Global Variable    ${tokenAddr}
                    Log To Console    ${i} :: ${address} :: ${tokenAddr}
                    ${status}       run api and make sure success   get token balance from RPC
                    IF      ${status}==True
                        IF      ${tokenBalancePG}!=${tokenBalanceRPC}
                            ${text}     Set Variable    :moneybag: Balance wrong:\\n- Address: 0x${address}\\n- Token address: ${tokenAddr}\\n- Current in PG: ${tokenBalancePG}. Expect: ${tokenBalanceRPC}
                            push text to discord    ${channelID}    ${botToken}     ${text}
                        END
                    END
                END
            END
        END
    END