*** Settings ***
Suite Teardown    Suite_Teardown
Library           Selenium2Library    10    2    run_on_failure=Fail Keyword
Library           String
Library           Collections

*** Variables ***
${screenshots}    ${EMPTY}
${ui_server}      http://www.google.co.uk
${browser}        chrome

*** Test Cases ***
UI_Web_Test
    Google_Search
    #Fileter_Items_by_Week
    #Suite_Teardown

*** Keywords ***
Fail keyword
    log source
    run keyword unless    '${screenshots}' == 'FAIL'    capture page screenshot

Google_Search
    # ----Search for 'Software Testing'
    open browser    ${ui_server}    ${browser}    # go to http://www.google.co.uk
    maximize browser window
    Wait Until Element Is Visible    xpath=//*[@id="hplogo"]    timeout=10
    Title Should Be    Google    # Page should be displayed with 'Google UK' option
    Element Should Contain    xpath=//*[@id="hplogo"]/div    UK    # UK option
    Click Element    id=lst-ib
    Input Text    id=lst-ib    Software Testing    # Input 'Softare Testing' into search bar
    Wait Until Element Is Visible    id=_fZl
    Click Button    id=_fZl    # Click on Google 'Search Icon'
    Sleep    10
    Click Element    xpath=//*[@id="tads"]/ol/li[1]/h3/a[2]    # Click on link for the first result
    Sleep    5
    ${title}=    Get Title    # Obtain any text from the page
    log_to_console    ${title}
    Go Back    # Go back to Search results
    #------------------------------
    Wait Until Element Is Visible    id=hdtb-tls    timeout=10
    Click Element    id=hdtb-tls
    Wait Until Element Is Visible    xpath=//*[@id="hdtbMenus"]//div[./text()='Any time']    timeout=5
    Click Element    xpath=//*[@id="hdtbMenus"]//div[./text()='Any time']
    Wait Until Element Is Visible    xpath=//*[@id="qdr_w"]/a[./text()='Past week']    timeout=5
    Click Element    xpath=//*[@id="qdr_w"]/a[./text()='Past week']
    Sleep    10
    Go To    ${ui_server}

Filter_By_Posted_Past_Week
    # Iterate: If a price is shown next to the time picker, the space is available
    Wait Until Page Contains    ${location}
    @{track-options}=    Create List    A    B    C    # Top three options to iterate
    @{pass-options}=    Create List
    Set Variable    ${pass-options}
    : FOR    ${line}    IN    @{track-options}
    \    Wait Until Element Is Visible    xpath=//a[@track-options="${line}"]    timeout=5
    \    ${get_car_park_name}    Get Text    xpath=//a[@track-options="${line}"]
    \    ${get_price_next_to_car_park_name}    Get Text    //a[@track-options="${line}"]/../../div/span
    \    Click Element    xpath=//a[@track-options="${line}"]
    \    Wait Until Element Is Visible    id=callout-snippet-more-info-link
    \    Sleep    3
    \    Click Element    id=callout-snippet-more-info-link
    \    ${remove_postcode} =    Get Substring    ${get_car_park_name}    0    -6
    \    Wait Until Page Contains    ${remove_postcode}
    \    ${get_price_next_to_time_picker}    Get Text    xpath=//*[@id="content"]//div[@class="subtotal-calculation"]/strong
    \    Run Keyword If    '${get_price_next_to_car_park_name}'=='${get_price_next_to_time_picker}'    Append To List    ${pass-options}    ${remove_postcode} = ${get_price_next_to_time_picker}
    \    Go Back
    \    Sleep    2
    Log List    ${pass-options}
    ${length} =    Get Length    ${pass-options}
    Run Keyword If    ${length} == 0    Fail    msg=There are no parking lots at all
    Run Keyword If    ${length} != 3    Fail    msg=There should have been three parking spaces

Suite_Teardown
    Close All Browsers
