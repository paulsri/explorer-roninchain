*** Settings ***
Resource        ${exec_dir}/RESOURCE/Home.robot
Resource        ${exec_dir}/RESOURCE/GlobalKey.robot
Library         SeleniumLibrary

*** Test Cases ***
home page chrome
	go to home page         headlessChrome
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