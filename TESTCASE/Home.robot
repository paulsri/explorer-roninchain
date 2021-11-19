*** Settings ***
Resource        ../RESOURCE/Home.robot
Resource        ../RESOURCE/GlobalKey.robot
Library         SeleniumLibrary

*** Test Cases ***
home page chrome
	go to home page         Chrome
	maximize browser window
	overview api response
	overview ui render
	set window size         500     900
	reload page
	overview api response
	overview ui render
	[Teardown]              push error screen and close browser

home page firefox
	go to home page         headlessFirefox
	maximize browser window
	overview api response
	overview ui render
	set window size         500     900
	reload page
	overview api response
	overview ui render
	[Teardown]              push error screen and close browser