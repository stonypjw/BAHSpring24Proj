trigger UpdateOpportunityFromAccount on Account (after update) {

    Set<Id> acctIds = new Set<Id>();

    for(Account a : trigger.new){
        if(a.Name != trigger.oldMap.get(a.Id).Name){
            acctIds.add(a.Id);
        }
    }

    List<Opportunity> oppList = [SELECT Id 
                                FROM Opportunity
                                WHERE AccountId In :acctIds];
 
    List<Database.SaveResult> srList = Database.update(oppList, false);
    for(Database.SaveResult sr : srList){
        System.Debug('Success?: ' + sr.isSuccess());
    }

}