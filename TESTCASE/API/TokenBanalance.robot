*** Settings ***
Resource        ../../RESOURCE/Library.robot
Resource        ../../RESOURCE/GlobalKey.robot

*** Variables ***
${slp}          0xa8754b9fa15fc18bb59458815510e40a12cd2014
${axs}          0x97a9107c1793bc407d6f527b77e7fff4d812bece
${usdc}         0x0b7007c13325c48911f73a2dad5fa5dcbf808adc
${egg}          0x173a2d4fa585a63acd02c107d57f932be0a71bcc
${weth}         0xc99a6a985ed2cac1ef41640596c5a5f9f4e19ef5
${axie}         0x32950db2a7164ae833121501c797d79e7b79d74c

*** Keywords ***
get ron balance from rpc
    [Arguments]     ${address}
    ${res}          REST.post   ${internalRPC}      {"jsonrpc":"2.0","method":"eth_getBalance","params":["${address}","latest"],"id":1}
    ${ronBalanceRPC}   get value json and remove string    ${res}      $..result
    ${ronBalanceRPC}   convert hex to number    ${ronBalanceRpc}
    Set Global Variable   ${ronBalanceRPC}

get ron balance from es
    [Arguments]     ${address}
    ${res}          REST.get     ${explorer}/address/${address}
    set global variable     ${res}
    ${statusCode}           get value from json         ${res}              $..status
    ${statusCode}           get from list               ${statusCode}       0
	set global variable     ${statusCode}
    ${statusCode}           get value from json         ${res}              $..status
    ${statusCode}           get from list               ${statusCode}       0
	set global variable     ${statusCode}
    ${ronBalanceES}             get value json and remove string      ${res}      $..balance
    ${ronBalanceES}             convert hex to number    ${ronBalanceES}
    [Return]                    ${ronBalanceES}

get token balance from rpc
    [Arguments]     ${contractAddress}       ${address}
    ${res}          REST.post   ${internalRPC}      {"jsonrpc":"2.0","method":"eth_call","params":[{"to":"${contractAddress}","data":"0x70a08231000000000000000000000000${address}"},"latest"],"id":1}
    ${ethCall}      get value json and remove string    ${res}      $..result
    ${ethCall}      convert hex to number    ${ethCall}
    Set Global Variable   ${ethCall}

get random address from es
    ${res}          REST.get     ${explorer}/addresses/wealthiest?from=11&size=21
    set global variable     ${res}
    ${statusCode}           get value from json         ${res}              $..status
    ${statusCode}           get from list               ${statusCode}       0
	set global variable     ${statusCode}
    ${listAddress}          Get Value From Json      ${res}      $..address
    [Return]                ${listAddress}

get latest address change from es
    ${res}          REST.get     ${explorer}/tokentxs?size=100
    set global variable     ${res}
    ${statusCode}           get value from json         ${res}              $..status
    ${statusCode}           get from list               ${statusCode}       0
	set global variable     ${statusCode}
    ${listAddress}          Get Value From Json      ${res}      $..from
    Set Global Variable     ${listAddress}

get address list
    ${res}          REST.get     ${explorer}/txs?size=1
    set global variable     ${res}
    ${statusCode}           get value from json         ${res}              $..status
    ${statusCode}           get from list               ${statusCode}       0
	set global variable     ${statusCode}
    ${randomAddress}         get value json and remove string    ${res}      $..from
    ${randomAddress}        Remove String    ${randomAddress}       0x
    [Return]                ${randomAddress}

get token balance by address from es
    [Arguments]     ${address}  ${tokenAddress}
    ${balance}      Set Variable        0
    ${res}          REST.get    ${explorer}/tokenbalances/${address}
    ${listAddress}         get value from json    ${res}      $..token_address
    ${listBalance}         get value from json    ${res}      $..balance
    ${length}       Get Length    ${listAddress}
    FOR     ${i}    IN RANGE    ${length}
        ${address}       Get From List      ${listAddress}      ${i}
        IF  ${address}==${tokenAddress}
            ${balance}      Get From List      ${listBalance}      ${i}
            Exit For Loop
        END
    END
    ${balance}      convert hex to number    ${balance}
    [Return]        ${balance}

get random address exclude whitelist
    [Arguments]     ${list}
    ${length}       Get Length      ${list}
    ${length}       Evaluate        ${length}-1
    FOR     ${i}    IN RANGE    ${length}
        ${random}       Get From List       ${list}       ${length}
        ${random}       Remove String       ${random}       0x
        ${validate}     validate whitelist      ${random}
        IF  ${validate}==True
            ${length}   Evaluate    ${length}-1
            Log To Console    ${length}::${random}
        ELSE
            Set Global Variable    ${random}
            Log To Console    ${length}::${random}
            Exit For Loop
        END
    END


token balance checker
    ${status}       run api and make sure success          get latest address change from es
    IF  ${status}==True
        get random address exclude whitelist    ${listAddress}
        ${status}       run keyword and return status    get ron balance from rpc       0x${random}
        IF      ${status}==True
            ${ronBalanceES}     get ron balance from es    0x${random}
            IF  ${statusCode}==200
                IF      ${ronBalanceRPC}!=${ronBalanceES}
                    push text to discord    ${channelID}    ${botToken}
                    ...                     :moneybag: RON balance wrong: 0x${random}. Should be equal ${ronBalanceRPC}
                END
            END
        END
        Sleep    1s
        ${status}       run keyword and return status    get token balance from rpc        ${axs}      ${random}
        IF      ${status}==True
            ${esCall}    get token balance by address from es    0x${random}    ${axs}
            IF  ${statusCode}==200
                IF      ${ethCall}!=${esCall}
                    push text to discord    ${channelID}    ${botToken}
                    ...                     :moneybag: AXS balance wrong: 0x${random}. Should be equal ${ethCall}
                END
            END
        END
        Sleep    1s
        ${status}       run keyword and return status    get token balance from rpc        ${slp}      ${random}
        IF      ${status}==True
            ${esCall}    get token balance by address from es    0x${random}    ${slp}
            IF  ${statusCode}==200
                IF      ${ethCall}!=${esCall}
                    push text to discord    ${channelID}    ${botToken}
                    ...                     :moneybag: SLP balance wrong: 0x${random}. Should be equal ${ethCall}
                END
            END
        END
        Sleep    1s
        ${status}       run keyword and return status    get token balance from rpc        ${weth}      ${random}
        IF      ${status}==True
            ${esCall}    get token balance by address from es    0x${random}    ${weth}
            IF  ${statusCode}==200
                IF      ${ethCall}!=${esCall}
                    push text to discord    ${channelID}    ${botToken}
                    ...                     :moneybag: WETH balance wrong: 0x${random}. Should be equal ${ethCall}
                END
            END
        END
        Sleep    1s
        ${status}       run keyword and return status    get token balance from rpc        ${usdc}   ${random}
        IF      ${status}==True
            ${esCall}    get token balance by address from es    0x${random}    ${usdc}
            IF  ${statusCode}==200
                IF      ${ethCall}!=${esCall}
                    push text to discord    ${channelID}    ${botToken}
                    ...                     :moneybag: USDC balance wrong: 0x${random}. Should be equal ${ethCall}
                END
            END
        END
        Sleep    1s
        ${status}       run keyword and return status    get token balance from rpc        ${axie}   ${random}
        IF      ${status}==True
            ${esCall}    get token balance by address from es    0x${random}    ${axie}
            IF  ${statusCode}==200
                IF      ${ethCall}!=${esCall}
                    push text to discord    ${channelID}    ${botToken}
                    ...                     :moneybag: AXIE balance wrong: 0x${random}. Should be equal ${ethCall}
                END
            END
        END
    END

*** Test Cases ***
address v2 compare
    token balance checker