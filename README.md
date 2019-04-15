# Scripts
This repo will be used to share scripts and other code snippets that we have found useful and want to share.

## Sierra Links to Primo Links Script
This PowerShell script was written to convert permalinks targeting records in III Sierra that have been migrated to ExLibris Alma/Primo.  The script requires you to configure and enable the SRU endpoint in the Alma configuration.  The workflow for converting a link from Sierra to Primo is: 
1. Look up the Alma MMS ID by searching for the Sierra Bib Number in the Originating System ID index in Alma
2. Lookup the Primo PNX ID using the MMS ID from step 1
3. Construct the new Primo "deep link" using the PNX ID from step 2
