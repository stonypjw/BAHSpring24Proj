public with sharing class InvoiceController{
    // Variables
    private Id oid;
    public Opportunity o {get;set;} // Exposed to the VF Page with getter and setter. 
    public Decimal totalInvoices {get;set;}
    public Decimal invoiceRemainder {get;set;}
    public List<Invoice__c> newInvoices {get;set;}
    public boolean disableSaveBtn {get; set;}
    public String fontClr {get;set;}
    public Integer numOfPayments {get;set;}    
    public Boolean showMonthly {get;set;}
    
    private Integer numOfInvoicesAlreadyCreated;
    private Integer paymentTerms;
    private List<Invoice__c> existingInvList;

    // Changed some code for demo

    /* @description Load the Opp data and Starting Variable Info
    *  @param pexPages.StandardSetController 
    *  Created by: Dar Wright Feb 20, 2024
    *  Last Updated by: 
    */
    public InvoiceController(ApexPages.StandardSetController ssc) {
        // Getting data from the Opportunity Record we are putting this button/page on
        oid = ApexPages.currentPage().getParameters().get('id');
        
        // Constructors cannot run SOQL, so call a method to get the Opp Details and setup starting variable values
        loadOpportunity();

    }

    /* @description Load the Opp data and Starting Variable Info
    *  Created by: Dar Wright Feb 20, 2024
    *  Last Updated by: 
    */
    private void loadOpportunity(){
        // Get Opp
        o = [SELECT Id, AccountId, Amount, CloseDate, Name, Account.Name FROM Opportunity WHERE Id =: oid LIMIT 1];

        // Set Variables
        totalInvoices = 0;
        disableSaveBtn = true;
        numOfPayments = 4;        
        showMonthly = true;

        // Payment terms will come from account at some point, but for now default to 90/Quarterly
        paymentTerms = 90;

        // Check for Previous Invoices__c should not change until after save() would be called.
        existingInvList = [SELECT Id, Opportunity__c, Account__c, Amount__c, Paid__c, Due_Date__c, Name 
                                        FROM Invoice__c 
                                        WHERE Opportunity__c = : o.Id
                                        ORDER BY Due_Date__c asc];

        numOfInvoicesAlreadyCreated = existingInvList.size();

        // Call method to calc Invoices
        calcInvoices();

    }

    /* @description Save function for the VF Page
    *  Created by: Dar Wright Feb 20, 2024
    *  Last Updated by: 
    */
    public PageReference save(){

        // Holder for invoices to upsert
        List<Invoice__c> invToCreate = new List<Invoice__c>();
        // Check for entries and remove any $0, Unpaid invoices
        List<Invoice__c> invToDelete = new List<Invoice__c>();
        for(Invoice__c i : newInvoices){
            if(i.Amount__c > 0){
                invToCreate.add(i);
            } else if(i.Amount__c == 0 && i.Paid__c == False && i.Id != NULL){
                // Only Delete Unpaid invoices that have already been Inserted into Database
                invToDelete.add(i);
            }
        }

        // update newInvoices --> update to try/catch DML error etc. 
        if(invToCreate.size() > 0){
            upsert invToCreate;
        }

        // Delete $0 Invoices --> update to try/catch DML error etc. 
        if(invToDelete.size() > 0){
            delete invToDelete;

        }

        // Return User to Opp Page
        PageReference pr = new PageReference('/' + oid);
        return pr;
    }

    /* @description Cancel function for the VF Page
    *  Created by: Dar Wright Feb 20, 2024
    *  Last Updated by: 
    */
    public PageReference cancel(){

        // Return User to Opp Page
        PageReference pr = new PageReference('/' + oid);
        return pr;
    }

    // // Update the Payment Summary Section of VF Page
    public void reclacTotalInvoices() {

        if(newInvoices != NULL){
            totalInvoices = 0; // 0 out to make sure math is correct if a value changes after the first load
            disableBtnsAndFontColor();
            for(Invoice__c inv : newInvoices){
                // This can happen on the page if someone erases the Amount on the page and clicks away
                if(inv.Amount__c == NULL){
                    inv.Amount__c = 0;
                }
                totalInvoices += inv.Amount__c;
            }
            invoiceRemainder = (o.Amount - totalInvoices);
            disableBtnsAndFontColor();
        } 
    }

    /* @description Button Action to show Monthly Invoice Payment Plan for the VF Page
    *  Created by: Dar Wright Feb 20, 2024
    *  Last Updated by: 
    */
    public void showMonthly(){
        numOfPayments = 12;
        paymentTerms = 30;
        showMonthly = true;

        // Call method to calc Invoices
        calcInvoices();
    }

    /* @description Button Action to show Quarterly Invoice Payment Plan for the VF Page
    *  Created by: Dar Wright Feb 20, 2024
    *  Last Updated by: 
    */
    public void showQuarterly(){
        numOfPayments = 4;
        paymentTerms = 90;
        showMonthly = false;

        // Call method to calc Invoices
        calcInvoices();
    }

    /* @description if the amounts or anything changes, they need to be recalculated and the Summary values updated
    *  Created by: Dar Wright Feb 20, 2024
    *  Last Updated by: 
    */
    private void calcInvoices(){
        // Clear out previous amounts
        totalInvoices = 0;
        invoiceRemainder = 0;

        if(existingInvList.size() == 0){
            invoiceRemainder = (0 - o.Amount);
            disableBtnsAndFontColor();
            // Handles if no previous invoices and switch Payment Terms
            if(newInvoices == NULL || newInvoices.size() != numOfPayments){
                newInvoices = new List<Invoice__c>();
                for(Integer i = 0; i < numOfPayments; i++){
                    Invoice__c inv = new Invoice__c();
                        inv.Opportunity__c = oid;
                        inv.Account__c = o.AccountId;
                        inv.Amount__c = 0;
                        //inv.Due_Date__c = Date.today();
                    newInvoices.add(inv);
                }
            }
        } else if(existingInvList.size() > numOfPayments){ // If more invoices than 12 per current requirement only 12 invoices allowed.
            System.debug('Too Many Invoices to load');
            // TODO Had popup warning
            // Add pagination or something
        } else {
            newInvoices = new List<Invoice__c>();
            // Add existing Invoice to newInvoices member variable
            for(Integer i = 0; i < existingInvList.size(); i++){
                newInvoices.add(existingInvList[i]);
                if(existingInvList[i].Amount__c == NULL){
                    existingInvList[i].Amount__c = 0;
                } else {
                    totalInvoices += existingInvList[i].Amount__c;
                }              
            }
            // Update Invoice remainder and check buttons/color
            invoiceRemainder = o.Amount - totalInvoices;

            // Create other blank invoices if needed.
            if(newInvoices.size() != numOfPayments){
            for(Integer i = 0; i < (numOfPayments - existingInvList.size()); i++){
                Invoice__c inv = new Invoice__c();
                    inv.Opportunity__c = oid;
                    inv.Account__c = o.AccountId;
                    inv.Amount__c = 0;
                    newInvoices.add(inv);
                }
            }
        }
        // Calculate the starting Due Date for Invoices if an Existing Invoice is present, otherwise set based on Closed Date of Opp
        Date dueDate = NULL;
        for(Integer i = 0; i < newInvoices.size(); i++){   

            if(newInvoices[i].Due_Date__c != NULL){
                if(dueDate < newInvoices[i].Due_Date__c){
                    dueDate = newInvoices[i].Due_Date__c + paymentTerms; // Set the next Due Date to be paymentTerms after the most recent Paid Due Date
                } else if(dueDate == NULL){
                    dueDate = newInvoices[i].Due_Date__c + paymentTerms;
                }
            } else if(dueDate == NULL) {
                dueDate = o.CloseDate + paymentTerms;
            }
        }
        // Set the Due Date on the Invoice based on the calculated Due Date (Which is already paymentTerms days past the most recent existing invoice);
        // Or set it to ClosedDate + i*paymentTerms
        for(Integer i = 0; i < newInvoices.size(); i++){      
            if(newInvoices[i].Due_Date__c == NULL){
                if(i == numOfInvoicesAlreadyCreated && numOfInvoicesAlreadyCreated > 0){
                    newInvoices[i].Due_Date__c = dueDate;
                } else {
                    // To get the right multiplier, have to account for the number of existing Invoices
                    if((numOfInvoicesAlreadyCreated > 0 || numOfInvoicesAlreadyCreated != NULL) && dueDate != NULL){
                        newInvoices[i].Due_Date__c = dueDate + ((i - numOfInvoicesAlreadyCreated) * paymentTerms);
                    }else {
                        // o.CloseDate plus the first paymentTerms days and then the multiple for each month there after
                        newInvoices[i].Due_Date__c = o.CloseDate + (i * paymentTerms) + paymentTerms;
                    }
                    
                }
            }
        }

        // Calculate remainingBalance
        Decimal remainingBalance = o.Amount - totalInvoices;
        
        // Calculate payment amounts 
        Decimal paymentAmount = Math.round((remainingBalance / (numOfPayments - numOfInvoicesAlreadyCreated)) * 100) / 100.0;

        // Have to account for rounding on the last payment to make sure the Amount equals the o.Amount as rounding is often off by a penny or 2
        Decimal roundCheck = 0;
        for(Integer i = 0; i < newInvoices.size(); i++){            
            if(newInvoices[i].Amount__c == 0){
                newInvoices[i].Amount__c = paymentAmount;
            }
            roundCheck += newInvoices[i].Amount__c;
        }

        if(roundCheck != o.Amount){
            if(roundCheck > o.Amount){
                newInvoices[newInvoices.size() -1].Amount__c = paymentAmount - (roundCheck - o.Amount);
            }else if(roundCheck < o.Amount){
             newInvoices[newInvoices.size() -1].Amount__c = paymentAmount + (o.Amount -roundCheck );
            }

        }

        // Update Summary Amounts based on Payment Plan Auto Calcs above
        reclacTotalInvoices();
    }

    /* @description Disable the Save button and change the Font Color of the Variance Amount
    *  Created by: Dar Wright Feb 20, 2024
    *  Last Updated by: 
    */
    public void disableBtnsAndFontColor(){
        if(invoiceRemainder == 0){
            disableSaveBtn = false;
            fontClr = '⌗00ff00'; // Make the Variance font Green if 0. 
        } else{
            disableSaveBtn = true;
            fontClr = '⌗ff0000'; // Make the Variance font Red if not 0.
        }
    }



}