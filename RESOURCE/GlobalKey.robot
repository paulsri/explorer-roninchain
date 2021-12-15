*** Settings ***
Resource            Library.robot
Resource            Report.robot
Resource            ../Ignore.robot

*** Variables ***
${domain}                   https://explorer.roninchain.com
#${domain}                   https://testnet-explorer.roninchain.com
${timeout}                  10s
${retry}                    10
${sleep}                    5s
${explorer}                 https://explorer.roninchain.com/api-v2
#${explorer}                 https://explorer.roninchain.com/api
#${explorer}                 https://staging.axieinfinity.co/explorer-test
${internalRPC}              https://api-internal.roninchain.com/rpc
${prodRPC}                  https://api.roninchain.com/rpc
${slpTokenAddr}             0xa8754b9fa15fc18bb59458815510e40a12cd2014
${axsTokenAddr}             0x97a9107c1793bc407d6f527b77e7fff4d812bece
${usdcTokenAddr}            0x0b7007c13325c48911f73a2dad5fa5dcbf808adc
${eggTokenAddr}             0x173a2d4fa585a63acd02c107d57f932be0a71bcc
${wethTokenAddr}            0xc99a6a985ed2cac1ef41640596c5a5f9f4e19ef5
${axieTokenAddr}            0x32950db2a7164ae833121501c797d79e7b79d74c

*** Keywords ***
call api success
    ${statusCode}           get value from json         ${res}              $..status
    ${statusCode}           get from list               ${statusCode}       0
	set global variable     ${statusCode}
    should be equal as strings                          ${statusCode}       200

wait and click element
	[Arguments]             ${locator}
	wait until element is visible    ${locator}
	click element           ${locator}

wait and input text
	[Arguments]             ${locator}      ${text}
	wait until element is visible    ${locator}
	input text              ${locator}      ${text}

wait and get text
	[Arguments]             ${locator}
	wait until element is visible    ${locator}
	${text}                 get text        ${locator}
	[Return]                ${text}

wait and get number
	[Arguments]             ${locator}
	wait until element is visible    ${locator}
	${number}               get text        ${locator}
	${number}               remove string   ${number}   ,
	[Return]                ${number}

push error screen and close browser
	push error screen to discord            ${reportChannel}    ${botToken}
	close browser

get value json and remove string
	[Arguments]             ${jsonObject}   ${jsonPath}
	${value}                get value from json     ${jsonObject}   ${jsonPath}
	${value}                convert to string       ${value}
	${value}                remove string           ${value}        [   '   '   ]   ,   ${space}
	[Return]                ${value}

convert number to hex
    [Arguments]         ${number}
    ${hex}              convert to hex          ${number}
    [Return]            ${hex}

convert hex to number
    [Arguments]         ${hex}
    ${number}           convert to integer      ${hex}
    ${number}           convert to string       ${number}
    [Return]            ${number}

convert hex to human number
    [Arguments]         ${hex}
    ${humanNumber}      Convert To Integer      ${hex}
    ${humanNumber}      Evaluate                ${humanNumber}/1000000000000000000
    ${humanNumber}      convert to string       ${humanNumber}
    [Return]            ${humanNumber}

connect postgres v2
    connect to database    psycopg2    axie    postgres    axie    127.0.0.1    dbPort=5432
    
connect postgres prod
    connect to database    psycopg2    axie    hoangtong    hoangtong    127.0.0.1    dbPort=5432

Query And Remove String
    [Arguments]         ${query}
    ${string}           Query                   ${query}
    ${string}           Convert To String       ${string}
    ${string}           Remove String           ${string}       [  ]   (   '    ,   '   )
    [Return]            ${string}

validate whitelist
    [Arguments]         ${address}
    ${whitelist}        Get File                ${EXECDIR}/RESOURCE/WhiteList.json
    ${whitelist}        convert to string       ${whitelist}
	${whitelist}        remove string           ${whitelist}        [   "   ]   ,   \n
    ${status}           Run Keyword And Return Status      Should Contain    ${whitelist}    ${address}
    [Return]            ${status}

get status code from res
    [Arguments]         ${res}
    ${statusCode}       get value from json         ${res}              $..status
    ${statusCode}       get from list               ${statusCode}       0
	set global variable     ${statusCode}

run api and make sure success
    [Arguments]         ${keyword}
    ${status}           Run Keyword And Return Status    ${keyword}
    IF  ${status}==True
        IF  ${statusCode}==200
            ${result}   Set Variable    True
        END
    ELSE
        ${result}   Set Variable    False
    END
    [Return]            ${result}

get latest blocks from postgres
    ${data}             Query And Remove String    select "number" from blocks order by "number" desc limit 1;
    [Return]            ${data}

get latest blocks from node
    ${res}                  REST.post       ${internalRPC}      {"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id" :1}    loglevel=INFO        timeout=3
    ${latestRPC}            get value json and remove string    ${res}       $..result
    ${latestRPC}            convert hex to number               ${latestRPC}
    Set Global Variable     ${latestRPC}

cal diff
    [Arguments]         ${number1}      ${number2}
    ${diff}             Evaluate        ${number1}-${number2}
    [Return]            ${diff}