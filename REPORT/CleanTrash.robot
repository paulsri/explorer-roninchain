*** Settings ***
Resource    ${exec_dir}/RESOURCE/Report.robot

*** Test Cases ***
ronin quick test
	clean error screen     ${exec_dir}/TRASH