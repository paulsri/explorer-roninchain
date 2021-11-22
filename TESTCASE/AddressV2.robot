*** Settings ***
Library         REST
Library         JSONLibrary
Library         DebugLibrary
Library         DatabaseLibrary
Library         FakerLibrary
Library         String
Library         Collections
Resource        ../RESOURCE/GlobalKey.robot

*** Variables ***
${slp}          0xa8754b9fa15fc18bb59458815510e40a12cd2014
${axs}          0x97a9107c1793bc407d6f527b77e7fff4d812bece
${usdc}         0x0b7007c13325c48911f73a2dad5fa5dcbf808adc
${egg}          0x173a2d4fa585a63acd02c107d57f932be0a71bcc
${weth}         0xc99a6a985ed2cac1ef41640596c5a5f9f4e19ef5
${axie}         0x32950db2a7164ae833121501c797d79e7b79d74c

*** Keywords ***
eth call
    [Arguments]     ${contractAddress}       ${address}
    ${res}          REST.post   ${internalRPC}      {"jsonrpc":"2.0","method":"eth_call","params":[{"to":"${to}","data":"0x70a08231000000000000000000000000${address}"},"latest"],"id":1}
    ${ethCall}      get value json and remove string    ${res}      $..result
    ${ethCall}      convert hex to number    ${ethCall}
    [Return]        ${ethCall}

get token balance by address
    [Arguments]     ${address}  ${tokenAddress}
    ${res}          REST.get    ${explorerProd}/tokenbalances/${address}
    ${listAddress}         get value from json    ${res}      $..token_address
    ${listBalance}         get value from json    ${res}      $..balance
    ${length}       Get Length    ${listAddress}
    FOR     ${i}    IN RANGE    ${length}
        ${address}       Get From List      ${listAddress}      ${i}
        IF  ${address}==${tokenAddress}
            ${balance}      Get From List      ${listBalance}      ${i}
        END
    END
    [Return]        ${balance}

*** Test Cases ***
address v2 compare
    ${a}    eth call        ${axs}      ed4a9f48a62fb6fdcfb45bb00c9f61d1a436e58c
    ${b}    get token balance by address    0xed4a9f48a62fb6fdcfb45bb00c9f61d1a436e58c    ${axs}
    Should Be Equal     ${a}     ${b}
    Log To Console      ${a}::${b}