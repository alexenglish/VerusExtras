#Powershell re-write of Alex English's python script 'decodeunlockheight.py', by zpajk February 2019
#This script comes with no warranty whatsoever. Use at your own risk.

#This script takes as a first (and only) argument the complete script hex string for a CLTV OP_RETURN script as was used for locking the VRSC mining rewards above 192

#There is NO ERROR CHECKING - this assumes well-formed input

#Example use - .\decodeunlockheight.ps1 -hex 6a2a010381cd0cb1752103a6c289dbed0e8dce5c90109989a6443f7ad990facc0ec5db58576c48cb5b5c36ac
#Prints 839041 to standard output

[CmdletBinding()]
param(
    [Parameter(Position=0,mandatory=$true)]
    [string]$hex
)

process {
    $heightbytes=$hex.Substring(6,2)

    for($i=1;$i -le $heightbytes;$i++) {
        $offset=6+(2*($i))
        $heighthex=$hex.Substring($offset,2) + $heighthex
    }
    
    #Write-Host "Unlockheight`nHex: $heighthex`nInt: $([Convert]::ToInt32($heighthex,16))"
    Write-Host ([Convert]::ToInt32($heighthex,16))
}
