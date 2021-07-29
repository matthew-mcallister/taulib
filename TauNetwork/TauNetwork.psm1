function Invoke-WakeOnLan {
    param (
        # one or more MACAddresses
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        # mac address must be a following this regex pattern:
        # TODO: Allow omitting - or : separator
        [ValidatePattern('^([0-9A-F]{2}[:-]){5}([0-9A-F]{2})$')]
        [string[]]
        $MacAddress 
    )

    begin {
        $UdpClient = [System.Net.Sockets.UdpClient]::new()
    }
    process {
        foreach ($_ in $MacAddress) {
            try {
                $mac = $_ -split '[:-]' |
                    ForEach-Object { [System.Convert]::ToByte($_, 16) }
                $packet = [byte[]](,0xff * 102)
                6..101 | ForEach-Object {
                    $packet[$_] = $mac[$_ % 6]
                }

                $UdpClient.Connect(([System.Net.IPAddress]::Broadcast), 4000)
                $null = $UdpClient.Send($packet, $packet.Length)
            } catch {
                Write-Warning "Unable to send to ${mac}: $_"
            }
        }
    }
    end {
        $UdpClient.Close()
        $UdpClient.Dispose()
    }
}