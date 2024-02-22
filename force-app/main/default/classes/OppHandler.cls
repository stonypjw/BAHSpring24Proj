public with sharing class OppHandler {

    // Constants 
    static final String CLOSED_WON = 'Closed Won';

    /* @description Applies the Correct Name to the Opportunity per BUsiness Requirements
    *  @param oppListNew - trigger.New 
    *  Created by: Dar Wright Feb 7, 2024
    *  Last Updated by: 
    */
    public static void applyNamingConventionInsertOrUpdate(List<Opportunity> oppListNew){
        Map<Id, Account> parentAccounts = new Map<Id, Account>();
        Set<Id> parentsIds = new Set<Id>();

        // Get Acc Ids
        for(Opportunity o : oppListNew){
            parentsIds.add(o.AccountId);
        }

        // Get Account Details
        for(Account a : [SELECT Id, Name FROM Account Where Id In :parentsIds WITH SECURITY_ENFORCED]){
            parentAccounts.put(a.Id, a);
        }

        // Update the Opp List with the naming convetion
        for(Opportunity o : oppListNew){
            if(o.CloseDate != NULL || parentAccounts.get(o.AccountId).Name != NULL || o.Type != NULL){
                o.Name = parentAccounts.get(o.AccountId).Name + ' - ' + o.Type  + ' - ' + 
                String.valueOf(o.CloseDate.month())  + '/' + String.valueOf(o.CloseDate.year());
            }
            
        }
    }

    // Create Invoice Trigger to Utility Class methods
    /* @description Creates a Custom Invoice if a New Opportunity Record is created with a Closed Won == True 
    *  @param oppListNew - trigger.New 
    *  Created by: Dar Wright Feb 7, 2024
    *  Last Updated by: 
    */
    public static void createInvoiceFromOppInsert(List<Opportunity> oppListNew){
        List<Invoice__c> invoicesToInsert = new List<Invoice__c>();
        for(Opportunity o: oppListNew){
            if(o.isWon){
                Invoice__c inv = makeInvoice(o);
                invoicesToInsert.add(inv);
            } 
        }

        // Insert Invoices
        if(!invoicesToInsert.isEmpty()){
            List<Database.SaveResult> srList = insertInvoices(invoicesToInsert);
        }
    }

    /* @description Creates a Custom Invoice if an Opportunity Record is updated and the StageName matches the constant: CLOSED_WON
    *  but only 1 invoice should be created per Opportunity
    *  @param oppListNew - trigger.New 
    *  @param oppListNew - trigger.Old 
    *  Created by: Dar Wright Feb 7, 2024
    *  Last Updated by: 
    */
    public static void createInvoiceFromOppUpdate(List<Opportunity> oppListNew, Map<Id, Opportunity> oppListOldMap){
        // Need to check that no Invoice Already exists
        List<Invoice__c> invoicesExist = [SELECT Id FROM Invoice__c WHERE Opportunity__c IN :oppListNew];
        List<Invoice__c> invoicesToInsert = new List<Invoice__c>();
        If(invoicesExist.isEmpty() ){
            for(Opportunity o: oppListNew){
                if (o.StageName != oppListOldMap.get(o.Id).StageName && o.StageName.equals(CLOSED_WON)){
                    Invoice__c inv = makeInvoice(o);
                    invoicesToInsert.add(inv);
                } 
            }
        }
       
        // Insert Invoices
        if(!invoicesToInsert.isEmpty()){
            List<Database.SaveResult> srList = insertInvoices(invoicesToInsert);
        }
    }

    /* @description Runs the DML to insert the Custom Invoices
    *  @param invoicesToInsert 
    *  @return Database.SaveResult 
    *  Created by: Dar Wright Feb 7, 2024
    *  Last Updated by: 
    */
    public static List<DataBase.SaveResult> insertInvoices(List<Invoice__c> invoicesToInsert){
        List<Database.SaveResult> srList = Database.insert(invoicesToInsert, false);
            for(Database.SaveResult sr : srList){
                if(sr.isSuccess() == false){
                    System.debug('This record failed to insert: ' + sr);
                }
            }
            return srList;
    }

    /* @description Creates a CustomInvoice record 
    *  @param Opportunity 
    *  @return Invoice__c 
    *  Created by: Dar Wright Feb 7, 2024
    *  Last Updated by: 
    */
    public static Invoice__c makeInvoice(Opportunity o){
        Invoice__c inv = new Invoice__c();
            inv.Amount__c = o.Amount;
            inv.Due_Date__c = o.CloseDate + 30;
            inv.Account__c = o.AccountId;
            inv.Opportunity__c = o.Id;
    
            return inv;
    }
}