# per http://msdn.microsoft.com/en-us/library/aa349325(v=vs.85).aspx
$w  = [reflection.assembly]::LoadWithPartialName("Microsoft.UpdateServices.Administration")
$ww = [Microsoft.UpdateServices.Administration.AdminProxy]::getUpdateServer()

# for future updates
# $updatescope = New-Object Microsoft.UpdateServices.Administration.UpdateScope

$Configuration   = $ww.GetConfiguration()
$Synchronization = $ww.GetSubscription()
$Rules           = $ww.GetInstallApprovalRules()

# Tells it to Sync from MS
## Change to attribute (true for master/ false for slave)
$Configuration.SyncFromMicrosoftUpdate = $true 

# This tells it not to use every available language
## Change to attribute
$Configuration.AllUpdateLanguagesEnabled = $false

# This sets it just to do English (for multiple languages use collection)
# $language = New-Object -Type System.Collections.Specialized.StringCollection
# $language.Add("en")
$Configuration.SetEnabledUpdateLanguages("en")

# This commits your changes
$Configuration.Save()


# This sets synchronization to be automatic
## Change to attribute
$Synchronization.SynchronizeAutomatically = $true  

# This sets the time, GMT, in 24 hour format (00:00:00) format
$Synchronization.SynchronizeAutomaticallyTimeOfDay = '12:00:00'

# Set the WSUS Server Synchronization Number of Syncs per day 
$Synchronization.NumberOfSynchronizationsPerDay='4'

# Saving to avoid losing changes after Category Sync starts
$Synchronization.save()

# Set WSUS to download available categories
# This can take up to 10 minutes
$Synchronization.StartSynchronizationForCategoryOnly()

# Loop to make sure new products synch up. And a anti-lock to prevent getting stuck.
$lock_prevention = [DateTime]::now.AddMinutes(10)
do{ 
  Start-Sleep -Seconds 20
  # write-host $([datetime]::now) --- $lock_prevention
  $Status = $Synchronization.GetSynchronizationProgress().phase
} until ($Status -like "*NotProcessing*" -or $lock_prevention -lt [datetime]::now) 

## This shows all of the available products
$main_category = $ww.GetUpdateCategories() | where {$_.title -like 'windows'}
    # example of multiple products
$products = $main_category.GetSubcategories() | ? {$_.title -in ('Windows 7','Windows Server 2008 R2','Windows 8.1','Windows Server 2012 R2')}
$products_col = New-Object Microsoft.UpdateServices.Administration.UpdateCategoryCollection
$products_col.AddRange($products)
$Synchronization.SetUpdateCategories($products_col)

# Change Classifications (available classifications)
  # 'Critical Updates',
  # 'Definition Updates',
  # 'Feature Packs',
  # 'Security Updates',
  # 'Service Packs',
  # 'Update Rollups',
  # 'Updates'

$classifications = $ww.GetUpdateClassifications() | ? {$_.title -in ('Critical Updates','Security Updates')}
$classifications_col = New-Object Microsoft.UpdateServices.Administration.UpdateClassificationCollection
$classifications_col.AddRange($classifications)
$Synchronization.SetUpdateClassifications($classifications_col)

# Configure Default Approval Rule - enabled for Critical updates only
$ww.GetInstallApprovalRules()
$rule = $rules | Where {$_.Name -eq "Default Automatic Approval Rule"}
$rule.SetUpdateClassifications($classifications_col)
$rule.Enabled = $True
$rule.Save()

# this saves Synchronization Info
$Synchronization.Save()

# this does the first synchronization from the upstream server instantly.  Comment this out if you want to wait for the first synchronization
# This can take well over an hour. Should probably be a handler or something that wouldnt hang chef run for an hour
# Might also be a good idea to set [datetime]::now during FirstSync() and time it to start a few min after chef run finishes.
$Synchronization.StartSynchronization()

