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
${explorer}                 https://explorer.roninchain.com/api
#${explorer}                 https://staging.axieinfinity.co/explorer-test
${internalRPC}              https://api-internal.roninchain.com/rpc
${prodRPC}                  https://api.roninchain.com/rpc

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
    
validate whitelist
    [Arguments]         ${address}
    ${whitelist}        Get File                ${EXECDIR}/RESOURCE/WhiteList.json
    ${whitelist}        convert to string       ${whitelist}
	${whitelist}        remove string           ${whitelist}        [   "   ]   ,   \n
    ${status}           Run Keyword And Return Status      Should Contain    ${whitelist}    ${address}
    [Return]            ${status}