*** Settings ***
Library         SeleniumLibrary

*** Variables ***
${homeUrl}              https://explorer.roninchain.com/
${testGit}              Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJiOWZiZjEyMy1kYWE4LTRhYzMtYTgwNC01Nzg4MmMzZDgwMzMiLCJzY3AiOiJ1c2VyIiwiYXVkIjoid2ViIiwiaWF0IjoxNjA0NjU1NjY1LCJleHAiOjE2MDQ2NTkyNjUsImp0aSI6IjE1MjljOTY3LWI0YjQtNDY0NS05OTdmLTU5YjExMWI5ODI0YiJ9.Z-5YUBLdIDZQZbwky00krS0y80wkitdFWayrYEsS4nA

*** Keywords ***
go to home page
	[Arguments]         ${option}
	open browser        ${homeUrl}      ${option}


*** Test Cases ***
quick test
	go to home page     Chrome
	maximize browser window