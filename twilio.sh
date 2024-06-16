#!/bin/bash

# ACCOUNT SID
twilio_account_sid='AC0898798789789';
# ACCOUNT TOKEN
twilio_account_token='asdf978908908908908908';
# ACCOUNT ORIGINATOR
twilio_originator='+44899989898';

twilio_calls_list_url="https://api.twilio.com/2010-04-01/Accounts/$twilio_account_sid/Calls.json?To=$twilio_originator";
twilio_recording_meta_url="https://api.twilio.com/2010-04-01/Accounts/$twilio_account_sid/Calls/[CSID]/Recordings.json";
twilio_recording_url="https://api.twilio.com/2010-04-01/Accounts/$twilio_account_sid/Recordings/[SID].mp3?RequestedChannels=2";


list_calls() {
    json_response=$(curl -s GET "$twilio_calls_list_url" -u "$twilio_account_sid:$twilio_account_token")
    
    if ! echo "$json_response" | jq empty; then
        echo "Invalid JSON response"
        exit 1
    fi

    count=0
    # echo "$json_response";
    echo "$json_response" | jq -r '.calls[].sid' | while read item; do
        echo "Download call $item"
        fetch_call_details $item $count
        count=$((count + 1))
    done
}

fetch_call_details() {
    local csid=$1
    local count=$2
    local curl_url=$(echo "$twilio_recording_meta_url" | sed "s/\[CSID\]/$csid/")

    json_response=$(curl -s GET "$curl_url" -u "$twilio_account_sid:$twilio_account_token")
    
    echo "$json_response" | jq -r '.recordings[].sid' | while read item; do
        echo "Got SID $item"
        fetch_recording $item $count 
    done
    
}

fetch_recording() {
    local sid=$1
    local count=$2
    local curl_url=$(echo "$twilio_recording_url" | sed "s/\[SID\]/$sid/")
    
    curl "$curl_url" -o "$sid.mp3"
    mv "$sid.mp3" "$count$sid.mp3"
    # echo "$response" > "$sid.mp3"

    
}

echo "List and download calls for +441923961004"

find . -name "*.mp3" -type f -delete

list_calls;

