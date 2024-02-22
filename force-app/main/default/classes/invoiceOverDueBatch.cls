global class invoiceOverDueBatch implements Database.Batchable<sObject> {


    global Database.QueryLocator start (Database.BatchableContext bc){
        Date cutoffDate = Date.today();
        
        String query = 'SELECT ID, Account__c, Opportunity__c, Amount__c, latefeeApplied__c FROM Invoice__c ' +
        'WHERE Due_Date__c > :cutoffDate AND isFee__c = true ' +
        'AND Paid__c = false AND lateFeeApplied__c = false';
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Invoice__c> invs){
        List<Invoice__c> feeInvoices = new List<Invoice__c>();
        for (Invoice__c i : invs){
            i.latefeeApplied__c = true;
            Invoice__c feeInv = new Invoice__c();
                feeInv.Account__c = i.Account__c;
                feeINv.Opportunity__c = i.Opportunity__c;
                feeInv.Amount__c = i.Amount__c / 10;
                feeInv.isFee__c = true;
                feeInv.Due_Date__c = Date.today();
            feeInvoices.add(feeInv);
        }

        Database.insert(feeInvoices,false);
        Database.update(invs,false);
    }

    //Do stuff on completion as needed
    global void finish(Database.BatchableContext bc){
        system.debug('Batch process: '+bc.getJobId() + ' completed');
    }

}