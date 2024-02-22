public class InvoiceHandler {
    
    public static void shareWithOppOwner(List<Invoice__c> invListNew){

        // Get Opp Ids
        Set<Id> oppIds = new Set<Id>();
        for(Invoice__c i : invListNew){
            oppIds.add(i.Opportunity__c);
        }
        // Make map of Opp Id and Opp Owner Id 
        Map<Id, Id> oppOwnerMap = new Map<Id, Id>();
        for(Opportunity o : [SELECT Id, OwnerId FROM Opportunity WHERE Id IN :oppIds]){
            oppOwnerMap.put(o.Id, o.OwnerId);
        }

        // Get Group Id from Group Object for SVP Customer Service
        Group SVPGroup = [SELECT ID, DeveloperName FROM Group WHERE DeveloperName = 'SVPCustomerServiceSupportA' LIMIT 1]; 

        // Create Invoice Shares
        List<Invoice__Share> invShareList = new List<Invoice__Share>();
        for(Invoice__c i : invListNew){
            Invoice__Share invShare = new Invoice__Share();
                invShare.ParentId = i.Id;
                invShare.UserOrGroupId = oppOwnerMap.get(i.Opportunity__c);
                invShare.AccessLevel = 'Read';
                // invShare.RowCause = 'Manual'; // Standard option available, but we made a custom one so let's use that. 
                invShare.RowCause = Schema.Invoice__Share.RowCause.Opportunity_Owner__c;
            invShareList.add(invShare);
            // If you need to add group Id, you just change the UserOrGroupId from the User to the Group Id. Don't need that for this. 
        }

        if(invShareList.size() > 0){
            insert invShareList;
        }


    }


}