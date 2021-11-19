*** Settings ***
Library         REST
Library         JSONLibrary
Library         DebugLibrary
Library         DatabaseLibrary
Library         String
Resource        ../RESOURCE/GlobalKey.robot

*** Keywords ***
get total txs by block
    eth_getBlockTransactionCountByHash

get txs from es by block
    /txs?block=8365081
    compare total with rpc
    compare each txs

get detail txs from rpc by hash
    eth_getTransactionByHash

get txs from es by address
    /txs/:address
    compare total with rpc

get txce from rpc by address
    eth_getTransactionCount

*** Test Cases ***
compare txs v2 with rpc