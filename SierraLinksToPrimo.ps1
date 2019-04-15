$sruPattern = '{Your Alma SRU base URL}?version=1.2&operation=searchRetrieve&recordSchema=marcxml&query=alma.mms_originatingSystemId%20all%20{0}*'
$pnxPattern = 'https://api-na.hosted.exlibrisgroup.com/primo/v1/pnxs?q=any,contains,{0}&apikey={your primo api key}'
$permaLinkPattern = '{Your Primo base URL}/primo-explore/fulldisplay?docid={0}&context=L&vid={your primo view code}&search_scope=EVERYTHING&tab=everything&lang=en_US'

function GetBibNumber {
    param([parameter(ValueFromPipeline)]$link)

    process {
        $bib = ""
        if ($link.URL) {
            $bib = $link.URL.Substring($link.URL.IndexOf('=') + 1, 8)
        } 

        $link | Add-Member -MemberType NoteProperty -Name 'BibNumber' -Value $bib

        $link
    }
}

function GetMmsId {
    param([parameter(ValueFromPipeline)]$link)

    begin {
        $ns = @{ srw = 'http://www.loc.gov/zing/srw/' }
    }

    process {

        $mms = ""
        if ($link.BibNumber) {
            
            $sru = $sruPattern -f $link.BibNumber
            $response = New-Object System.Xml.XmlDocument
            $response.Load($sru)

            if ($response.searchRetrieveResponse.numberOfRecords -ne '0') {
                $mms = select-xml -Xml $response -Namespace $ns -XPath "/srw:searchRetrieveResponse/srw:records/srw:record/srw:recordData/record/controlfield[@tag='001']" | Select-Object -First 1 -ExpandProperty Node | Select-Object -ExpandProperty InnerText
            }

        }

        $link | Add-Member -MemberType NoteProperty -Name 'MMS_ID' -Value $mms
        $link
    }
}

function GetPnxId {
    param([parameter(ValueFromPipeline)]$link)

    process {
        $pnx = ""

        if ($link.MMS_ID) {
            $rsp = Invoke-WebRequest -Uri ($pnxPattern -f $link.MMS_ID) | ConvertFrom-Json
            if ($rsp.docs.Length -gt 0) {
                $pnx = $rsp.docs[0].pnxId
            }
        }

        $link | Add-Member -MemberType NoteProperty -Name 'PNX_ID' -Value $pnx
        $link
    }
}

function GetPermalink {
    param([parameter(ValueFromPipeline)]$link)

    process {
        $perm = ""
        if($link.PNX_ID) {
            $perm = $permaLinkPattern -f $link.PNX_ID
        }

        $link | Add-Member -MemberType NoteProperty -Name 'PrimoLink' -Value $perm
        $link
    }
}

$links = Import-Csv 'LibGuideLinks.csv'

$links | GetBibNumber | GetMmsId | GetPnxId | GetPermalink | Export-Csv FixedLinks.csv



