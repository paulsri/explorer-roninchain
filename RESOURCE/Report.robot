*** Settings ***
Library		RequestsLibrary
Library		REST
Library     SeleniumLibrary
Library     OperatingSystem
Library     DebugLibrary
Library     String
Library     JSONLibrary
Library     Collections
Resource    ${exec_dir}/Ignore.robot
Resource    ${exec_dir}/RESOURCE/GlobalKey.robot

*** Variables ***
${reportStatus}             //*[contains(@onClick,'totalDetailSelected()')]

*** Keywords ***
capture report file
    open browser            ${report_file}          headlesschrome
    set window size         width=875               height=425
    wait until element is visible                   ${reportStatus}
    ${status}               get text                ${reportStatus}
    capture page screenshot                         Report.jpg
    close all browsers
    ${reportImage}          set variable            ${exec_dir}/TRASH/Report.jpg
    set global variable     ${reportImage}
    set global variable     ${status}

push report to discord
	[Arguments]             ${channelID}            ${botToken}
    ${header}               create dictionary       Authorization   ${botToken}
    create session          discord                 https://discordapp.com       headers=${header}      disable_warnings=1
    ${logFile}              get file for streaming upload       ${log_file}
    ${logFile}              create dictionary       files       ${logFile}
    ${reportFile}           get file for streaming upload       ${reportImage}
    ${reportFile}           create dictionary       files       ${reportFile}
    ${res}                  requestslibrary.post on session     discord     /api/channels/${channelID}/messages       files=${reportFile}
    IF      '${status}'!='All tests passed'
        ${res}                  requestslibrary.post on session             discord     /api/channels/${channelID}/messages         files=${logFile}
    END

push error screen to discord
	[Arguments]             ${channelID}            ${botToken}
	${latestFileName}       get latest file name discord    ${channelID}            ${botToken}
	${index}                count file in folder    ${exec_dir}/TRASH      png
	IF  ${index}!=0
		${header}           create dictionary       Authorization   ${botToken}
	    create session      discord                 https://discordapp.com       headers=${header}      disable_warnings=1
	    ${temp}             evaluate                ${index}-1
	    ${currentFileName}  latest file in folder   ${exec_dir}/TRASH      png      ${temp}
	    IF  '${latestFileName}'!='${currentFileName}'
		    ${file}         get file for streaming upload       ${exec_dir}/TRASH/selenium-screenshot-${index}.png
		    ${file}         create dictionary       files       ${file}
		    ${res}          post on session         discord     /api/channels/${channelID}/messages       files=${file}
		END
	END

get latest file name discord
	[Arguments]             ${channelID}            ${botToken}
	rest.set headers        {"Authorization": "${botToken}"}
	${res}                  rest.get                https://discordapp.com/api/channels/${channelID}/messages?limit=1
	set global variable     ${res}
	call api success
	${latestFileName}       get value from json     ${res}                  $..attachments..filename
	${latestFileName}       convert to string       ${latestFileName}
	${latestFileName}       remove string           ${latestFileName}       [   '   '   ]
	[Return]                ${latestFileName}

latest file in folder
	[Arguments]             ${folderPath}           ${fileType}             ${index}
	${fileInFoleder}        list files in directory     ${folderPath}       *.${fileType}
	${fileInFoleder}        get from list           ${fileInFoleder}        ${index}
	${fileInFoleder}        convert to string       ${fileInFoleder}
	${fileInFoleder}        remove string           ${fileInFoleder}        [   '   '   ]
	[Return]                ${fileInFoleder}

count file in folder
	[Arguments]             ${folderPath}           ${fileType}
	${total}                count files in directory    ${folderPath}        *.${fileType}
	[Return]                ${total}

clean error screen
	[Arguments]             ${folderPath}
	${total}                count file in folder    ${folderPath}   png
	FOR     ${i}    IN RANGE   ${total}
		${index}            evaluate        ${i}+1
		remove files        ${exec_dir}/TRASH/selenium-screenshot-${index}.png
	END