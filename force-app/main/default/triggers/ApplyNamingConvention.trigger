trigger ApplyNamingConvention on Opportunity (before insert, before update) {
    
    Map<Id, Account> parentAccounts = new Map<Id, Account>();
    Set<Id> parentsIds = new Set<Id>();
    for(Opportunity o : trigger.new){
        parentsIds.add(o.AccountId);
    }

    for(Account a : [SELECT Id, Name FROM Account Where Id In :parentsIds]){
        parentAccounts.put(a.Id, a);
    }

    for(Opportunity o : trigger.new){
        o.Name = parentAccounts.get(o.AccountId).Name + ' - ' + o.Type  + ' - ' + 
            String.valueOf(o.CloseDate.month())  + '/' + String.valueOf(o.CloseDate.year());
    }


    

}