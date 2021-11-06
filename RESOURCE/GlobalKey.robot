*** Settings ***
Library             SeleniumLibrary
Resource            ${exec_dir}/RESOURCE/Report.robot
Resource            ${exec_dir}/Ignore.robot

*** Variables ***
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

push error screen and close browser
	push error screen to discord            ${reportChannel}    ${botToken}
	close browser