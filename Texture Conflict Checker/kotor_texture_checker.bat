::[Bat To Exe Converter]
::
::fBE1pAF6MU+EWHreyHcjLQlHcA6NL2OvOpET6/326uSTsXE2e9YQSrD29eaxFMUg3mzKUqo502JOjdkJMxhXcBSnZwwglm1Ks2eOMtWgpxfiQkuCqFsjSgU=
::YAwzoRdxOk+EWAjk
::fBw5plQjdCyDJGyX8VAjFBFbXwyXAE+1BaAR7ebv/NasjXkyZt0SV93k7pG9FMk9zXnwcI45w2hfp8gDAh1UdxG/UQw8rG1Js3a5I8KEsAfkSUPH70g/ew==
::YAwzuBVtJxjWCl3EqQJgSA==
::ZR4luwNxJguZRRnk
::Yhs/ulQjdF+5
::cxAkpRVqdFKZSTk=
::cBs/ulQjdF+5
::ZR41oxFsdFKZSDk=
::eBoioBt6dFKZSDk=
::cRo6pxp7LAbNWATEpSI=
::egkzugNsPRvcWATEpSI=
::dAsiuh18IRvcCxnZtBJQ
::cRYluBh/LU+EWAnk
::YxY4rhs+aU+IeA==
::cxY6rQJ7JhzQF1fEqQJgZko0
::ZQ05rAF9IBncCkqN+0xwdVsEAlXi
::ZQ05rAF9IAHYFVzEqQJQ
::eg0/rx1wNQPfEVWB+kM9LVsJDGQ=
::fBEirQZwNQPfEVWB+kM9LVsJDGQ=
::cRolqwZ3JBvQF1fEqQJQ
::dhA7uBVwLU+EWDk=
::YQ03rBFzNR3SWATElA==
::dhAmsQZ3MwfNWATElA==
::ZQ0/vhVqMQ3MEVWAtB9wSA==
::Zg8zqx1/OA3MEVWAtB9wSA==
::dhA7pRFwIByZRRnk
::Zh4grVQjdCyDJGyX8VAjFBFbXwyXAE+1BaAR7ebv/NasjXkyZt0SV93k7pG9FMk9zXnwcI45w2hfp8gDAh1UdxG/UQw8rG1Js3a5PMiIvB3eXk2R8l4iHlp3j2bThy4pX8U51JNN1ji7nA==
::YB416Ek+ZG8=
::
::
::978f952a14a936cc963da21a135fa983
@echo off
setlocal

REM Set your target folder here (or leave empty to prompt)
set "TARGET_FOLDER=override"

REM Set your PowerShell scripts
set "PS_SCRIPT=txchck.ps1"

REM Run the first PowerShell script to generate the lists
powershell -NoProfile -ExecutionPolicy Bypass -File "%PS_SCRIPT%" "%TARGET_FOLDER%"


endlocal
