*** Settings ***
Resource    ../RESOURCE/Report.robot

*** Test Cases ***
ronin quick test
	capture report file
	push report to discord     ${reportChannel}      ${botToken}