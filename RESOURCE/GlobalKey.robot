*** Settings ***
Library             SeleniumLibrary
Library             JSONLibrary
Library             String
Library             Collections
Resource            ${exec_dir}/RESOURCE/Report.robot
Resource            ${exec_dir}/Ignore.robot

*** Variables ***
${domain}                   https://explorer.roninchain.com
#${domain}                   https://testnet-explorer.roninchain.com
${timeout}                  10s
${retry}                    10
${sleep}                    5s

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
	${value}                remove string           ${value}        [   '   '   ]
	[Return]                ${value}