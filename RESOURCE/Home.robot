*** Settings ***
Library         SeleniumLibrary
Library         RequestsLibrary
Library         DebugLibrary
Library         JSONLibrary
Resource        ../RESOURCE/GlobalKey.robot

*** Variables ***
${homeUrl}              https://explorer.roninchain.com/
${overviewAPI}          /_next/data/bxaCNniKrQ6ZsQL2NYqYL/index.json
${totalBlockEle}        css=.flex-col.mb-12 > .mb-12 .font-semibold
${blockTimeEle}         css=.mb-12.flex-col > div:nth-of-type(2) .font-semibold
${totalTxsEle}          css=.flex.home-card > div:nth-of-type(2) > .mb-12 .font-semibold
${totalAddressEle}      css=.flex.home-card > div:nth-of-type(2) > div:nth-of-type(2) .font-semibold

*** Keywords ***
go to home page
	[Arguments]         ${option}
	open browser        ${homeUrl}          ${option}

overview api response
	create session      overview            ${domain}       disable_warnings=1
	${res}              get on session      overview        ${overviewAPI}      expected_status=200
	${response}         set variable        ${res.json()}
	${blockTime}        get value json and remove string    ${response}         $..blockTime
	${totalAddresses}   get value json and remove string    ${response}         $..totalAddresses
	${totalBlocks}      get value json and remove string    ${response}         $..totalBlocks
	${totalTxs}         get value json and remove string    ${response}         $..totalTxs
	set global variable     ${blockTime}
	set global variable     ${totalAddresses}
	set global variable     ${totalBlocks}
	set global variable     ${totalTxs}

overview ui render
	${temp}                 wait and get number     ${blockTimeEle}
	should be equal as strings      ${temp}         ~${blockTime} secs
	${temp}                 wait and get number     ${totalTxsEle}
	should be true          ${temp}>=${totalTxs}
	${temp}                 wait and get number     ${totalAddressEle}
	should be true          ${temp}>=${totalAddresses}
	${temp}                 wait and get number     ${totalBlockEle}
	should be true          ${temp}>=${totalBlocks}