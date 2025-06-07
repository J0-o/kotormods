::[Bat To Exe Converter]
::
::fBE1pAF6MU+EWHreyHcjLQlHcA6NL2OvOpET6/326uSTsXE2e9YQSrD29eaxFMUg3mzKUqo502JOjdkJMxhXcBSnZwwglm1Ks2eOMtWg/QT1SSg=
::YAwzoRdxOk+EWAjk
::fBw5plQjdCyDJGyX8VAjFBFbXwyXAE+1BaAR7ebv/NasjXkyZt0SV93k7pG9FMk9zXnwcI45w2hfp8gDAh1UdxG/UQw8rG1Js3a5ecyIsDPoSUeHqEIzFAU=
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
::cxY6rQJ7JhzQF1fEqQJhZko0
::ZQ05rAF9IBncCkqN+0xwdVsFAlXi
::ZQ05rAF9IAHYFVzEqQIbJw9bXkS2OXOuE6cZqMvz6umMp199
::eg0/rx1wNQPfEVWB+kM9LVsJDGQ=
::fBEirQZwNQPfEVWB+kM9LVsJDGQ=
::cRolqwZ3JBvQF1fEqQJQ
::dhA7uBVwLU+EWDk=
::YQ03rBFzNR3SWATElA==
::dhAmsQZ3MwfNWATElA==
::ZQ0/vhVqMQ3MEVWAtB9wSA==
::Zg8zqx1/OA3MEVWAtB9wSA==
::dhA7pRFwIByZRRnk
::Zh4grVQjdCyDJGyX8VAjFBFbXwyXAE+1BaAR7ebv/NasjXkyZt0SV93k7pG9FMk9zXnwcI45w2hfp8gDAh1UdxG/UQw8rG1Js3a5PMiIvB3eXk2R8l4iHlp3j2bThy4pX8U51JJN1ji7nA==
::YB416Ek+ZG8=
::
::
::978f952a14a936cc963da21a135fa983
@echo off
setlocal
:: Target Folder
set "TARGET_FOLDER=override"
:: Powsershell Scripts
set "PS_SCRIPT=.ktc\txchck.ps1"

::Run PowerShell scripts
powershell -NoProfile -ExecutionPolicy Bypass -File "%PS_SCRIPT%" "%TARGET_FOLDER%"

endlocal
