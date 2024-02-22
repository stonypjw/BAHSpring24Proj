trigger CreateInvoiceFromOpportunity on Opportunity (after insert, after update) {

    // Constants 
    static final String CLOSED_WON = 'Closed Won';

    // List to hold new Invs
    List<Invoice__c> invoicesToInsert = new List<Invoice__c>();

    // Iterate Opps and create Inv's as needed.
    for(Opportunity o : trigger.new){
        if(trigger.isInsert){
            if(o.isWon){
                Invoice__c inv = makeInvoice(o);
                invoicesToInsert.add(inv);
            }
        }else if (o.StageName != trigger.oldMap.get(o.Id).StageName && o.StageName.equals(CLOSED_WON)){
            Invoice__c inv = makeInvoice(o);
            invoicesToInsert.add(inv);
        }
    }
    // Insert Invoices
    if(!invoicesToInsert.isEmpty()){
        List<Database.SaveResult> srList = Database.insert(invoicesToInsert, false);
        for(Database.SaveResult sr : srList){
            if(sr.isSuccess() == false){
                System.debug('This record failed to insert: ' + sr);
            }
        }
    }
    
    
    public Invoice__c makeInvoice(Opportunity o){
        Invoice__c inv = new Invoice__c();
            inv.Amount__c = o.Amount;
            inv.Due_Date__c = o.CloseDate + 30;
            inv.Account__c = o.AccountId;
            inv.Opportunity__c = o.Id;
    
            return inv;
    }
}